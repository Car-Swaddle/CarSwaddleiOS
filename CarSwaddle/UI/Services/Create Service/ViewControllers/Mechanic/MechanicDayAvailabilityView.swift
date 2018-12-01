//
//  MechanicDayAvailabilityView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI
import CarSwaddleData
import CoreData


protocol MechanicDateAvailabilityDelegate: AnyObject {
    func didChangeDate(date: Date?, view: MechanicDayAvailabilityView)
}

enum AvailabilityState {
    case available
    case reserved
    case timeOff
    case currentlyScheduled
}

private let dateFormatter: DateFormatter = {
    let d = DateFormatter()
    d.dateFormat = "EEEE, MMM d"
    return d
}()

final class MechanicDayAvailabilityView: UIView, NibInstantiating {
    
    public func configure(with mechanic: Mechanic) {
        self.mechanic = mechanic
        let string = NSLocalizedString("%@'s availability", comment: "Title of view that displays a mechanics schedule")
        titleLabel.text = String(format: string, mechanic.user?.displayName ?? "")
        updateSchedule()
        requestAutoServices()
    }
    
    weak var delegate: MechanicDateAvailabilityDelegate?
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    
    private var mechanic: Mechanic!
    private var availabilityService = TemplateTimeSpanNetwork(serviceRequest: serviceRequest)
    
    private var scheduledAutoServices: [AutoService] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var task: URLSessionDataTask? {
        willSet {
            task?.cancel()
        }
    }
    
    private var timeSlots: [Int] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    private var templateTimeSpans: [TemplateTimeSpan] = [] {
        didSet {
            updateCurrentWeekdayTimeSpans()
            collectionView.reloadData()
        }
    }
    
    /// The currentWeekday of the availability calendar
    private var currentWeekday: Weekday {
        guard let dayOfWeek = currentCalendarDate.dayOfWeek,
            let weekday = Weekday(rawValue: Int16(dayOfWeek-1)) else { return .sunday }
        return weekday
    }
    
    private var currentCalendarDate: Date! {
        didSet {
            updateCurrentWeekdayTimeSpans()
            dayLabel.text = dateFormatter.string(from: currentCalendarDate)
        }
    }
    private var scheduledDate: Date? {
        didSet {
            collectionView.reloadData()
            delegate?.didChangeDate(date: scheduledDate, view: self)
        }
    }
    
    private var timespansForCurrentWeekday: [TemplateTimeSpan] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var startDate: Date {
        var dateComponents = Calendar.current.dateComponents(in: .current, from: currentCalendarDate)
        dateComponents.hour = 0
        return dateComponents.date ?? Date()
    }
    
    private var endDate: Date {
        var dateComponents = Calendar.current.dateComponents(in: .current, from: currentCalendarDate)
        dateComponents.hour = 24
        return dateComponents.date ?? Date()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentCalendarDate = Date(timeIntervalSinceNow: .day)
        
        setupCollectionView()
    }
    
    
    @IBAction func didTapPrevious() {
        currentCalendarDate = Date(timeInterval: -.day, since: currentCalendarDate)
        requestAutoServices()
    }
    
    @IBAction func didTapNext() {
        currentCalendarDate = Date(timeInterval: .day, since: currentCalendarDate)
        requestAutoServices()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HourCollectionViewCell.self)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func updateCurrentWeekdayTimeSpans() {
        timespansForCurrentWeekday = fetchTimeSpans(for: currentWeekday)
    }
    
    private func weekdayOfTomorrow() -> Weekday {
        let tomorrowsDate = Date(timeIntervalSinceNow: .day)
        let dayOfWeek = tomorrowsDate.dayOfWeek ?? 1
        return Weekday(rawValue: Int16(dayOfWeek-1))!
    }
    
    private func requestAutoServices() {
        let mechanicID = mechanic.identifier
        
        let startDate = self.startDate
        let endDate = self.endDate
        
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServices(mechanicID: mechanicID, startDate: startDate, endDate: endDate, status: [.inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
                store.mainContext{ mainContext in
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
                    self?.scheduledAutoServices = autoServices
                }
            }
        }
    }
    
    private func updateSchedule() {
        let mechanicID = mechanic.identifier
        store.privateContext { [weak self] context in
            self?.task = self?.availabilityService.getTimeSpans(ofMechanicWithID: mechanicID, in: context) { objectIDs, error in
                store.mainContext { mainContext in
                    self?.templateTimeSpans = TemplateTimeSpan.fetchObjects(with: objectIDs, in: mainContext)
                }
            }
        }
    }
    
    private func fetchTimeSpans(for weekday: Weekday) -> [TemplateTimeSpan] {
        guard let mechanicID = mechanic?.identifier else { return [] }
        return TemplateTimeSpan.fetch(with: weekday, mechanicID: mechanicID, in: store.mainContext)
    }
    
}

extension MechanicDayAvailabilityView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HourCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        let timeSlot = timeSlots[indexPath.row]
        let state = self.availabilityState(forTimeSlot: timeSlot)
        cell.configure(with: timeSlot, state: state)
        return cell
    }
    
    private func availabilityState(forTimeSlot timeSlot: Int) -> AvailabilityState {
        let timeSpan = timespansForCurrentWeekday.first {
            return $0.startTime == timeSlot * Int(TimeInterval.hour)
        }
        if timeSpan == nil {
            return .timeOff
        } else {
            if let scheduledDate = scheduledDate {
                let scheduledDateComponents = Calendar.current.dateComponents(in: .current, from: scheduledDate)
                let calendarDateComponents = Calendar.current.dateComponents(in: .current, from: currentCalendarDate)
                
                if scheduledDateComponents.day == calendarDateComponents.day && scheduledDateComponents.hour == timeSlot {
                    return .currentlyScheduled
                } else {
                    if isScheduledForTimeSlot(timeSlot: timeSlot) {
                        return .reserved
                    } else {
                        return .available
                    }
                }
            } else {
                if isScheduledForTimeSlot(timeSlot: timeSlot) {
                    return .reserved
                } else {
                    return .available
                }
            }
        }
    }
    
    private func isScheduledForTimeSlot(timeSlot: Int) -> Bool {
        for a in scheduledAutoServices {
            guard let scheduledDate = a.scheduledDate else { continue }
            let scheduledDateComponents = Calendar.current.dateComponents(in: .current, from: scheduledDate)
            let calendarDateComponents = Calendar.current.dateComponents(in: .current, from: currentCalendarDate)
            
            if scheduledDateComponents.hour == timeSlot && scheduledDateComponents.day == calendarDateComponents.day {
                return true
            }
        }
        return false
    }
    
}

extension MechanicDayAvailabilityView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let timeSlot = timeSlots[indexPath.row]
        
        guard self.availabilityState(forTimeSlot: timeSlot) == .available else { return }
        scheduledDate = Calendar.current.date(bySettingHour: timeSlot, minute: 0, second: 0, of: currentCalendarDate)
    }
    
}


final class MechanicDayAvailabilityViewWrapper: UIView {
    
    lazy var view: MechanicDayAvailabilityView = MechanicDayAvailabilityView.viewFromNib()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        addSubview(view)
        view.pinFrameToSuperViewBounds()
    }
    
}





//extension TemplateTimeSpan {
//
//    static func fetch(with weekday: Weekday, mechanicID: String, in context: NSManagedObjectContext) -> [TemplateTimeSpan] {
//        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
//
//        let mechanicPredicate = TemplateTimeSpan.predicate(forMechanicID: mechanicID)
//        let weekdayPredicate = TemplateTimeSpan.predicate(for: weekday)
//        let predicates: [NSPredicate] = [mechanicPredicate, weekdayPredicate]
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        fetchRequest.predicate = compoundPredicate
//
//        return (try? context.fetch(fetchRequest)) ?? []
//    }
//
//    static func predicate(forMechanicID mechanicID: String) -> NSPredicate {
//        return NSPredicate(format: "%K == %@", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID)
//    }
//
//    static func predicate(for weekday: Weekday) -> NSPredicate {
//        return NSPredicate(format: "weekday == %i", weekday.rawValue)
//    }
//
//}

