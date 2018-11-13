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


enum AvailabilityState {
    case vacant
    case reserved
    case timeOff
}

final class MechanicDayAvailabilityView: UIView, NibInstantiating {
    
    public func configure(with mechanic: Mechanic) {
        self.mechanic = mechanic
        let string = NSLocalizedString("%@'s schedule", comment: "Title of view that displays a mechanics schedule")
        titleLabel.text = String(format: string, mechanic.user?.displayName ?? "")
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    
    private var mechanic: Mechanic! {
        didSet {
            startingWeekday = weekdayOfTomorrow()
            currentWeekday = startingWeekday
            updateSchedule()
        }
    }
    
    private var availabilityService = TemplateTimeSpanNetwork(serviceRequest: serviceRequest)
    
    private var timeSlots: [Int] = [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23]
    private var templateTimeSpans: [TemplateTimeSpan] = [] {
        didSet {
            updateCurrentWeekdayTimeSpans()
            collectionView.reloadData()
        }
    }
    
    private var startingWeekday: Weekday!
    private var currentWeekday: Weekday! {
        didSet {
            updateCurrentWeekdayTimeSpans()
        }
    }
    
    private var currentWeekdayTimeSpans: [TemplateTimeSpan] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HourCollectionViewCell.self)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func updateCurrentWeekdayTimeSpans() {
        currentWeekdayTimeSpans = fetchTimeSpans(for: currentWeekday)
    }
    
    private func weekdayOfTomorrow() -> Weekday {
        let tomorrowsDate = Date(timeIntervalSinceNow: .day)
        let dayOfWeek = tomorrowsDate.dayOfWeek ?? 1
        return Weekday(rawValue: Int16(dayOfWeek-1))!
    }
    
    private func updateSchedule() {
        let mechanicID = mechanic.identifier
        
        let ts = TemplateTimeSpan.fetchAllObjects(with: [NSSortDescriptor(key: "identifier", ascending: true)], in: store.mainContext)
        
        for d in ts {
            store.mainContext.delete(d)
        }
        store.mainContext.persist()
        
        store.privateContext { [weak self] context in
            self?.availabilityService.getTimeSpans(ofMechanicWithID: mechanicID, in: context) { objectIDs, error in
                store.mainContext { mainContext in
                    self?.templateTimeSpans = TemplateTimeSpan.fetchObjects(with: objectIDs, in: mainContext)
                }
            }
        }
    }
    
    private func fetchTimeSpans(for weekday: Weekday) -> [TemplateTimeSpan] {
        return TemplateTimeSpan.fetch(with: weekday, mechanicID: mechanic.identifier, in: store.mainContext)
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
        let timeSpan = currentWeekdayTimeSpans.first {
            print("startTime: \($0.startTime), hour: \(timeSlot * Int(TimeInterval.hour))")
            return $0.startTime == timeSlot * Int(TimeInterval.hour)
        }
        if timeSpan == nil {
            return .timeOff
        } else {
            return .vacant
        }
    }
    
}

extension MechanicDayAvailabilityView: UICollectionViewDelegate {
    
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





extension TemplateTimeSpan {
    
    static func fetch(with weekday: Weekday, mechanicID: String, in context: NSManagedObjectContext) -> [TemplateTimeSpan] {
        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
        
        let mechanicPredicate = TemplateTimeSpan.predicate(forMechanicID: mechanicID)
        let weekdayPredicate = TemplateTimeSpan.predicate(for: weekday)
        let predicates: [NSPredicate] = [mechanicPredicate, weekdayPredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    static func predicate(forMechanicID mechanicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID)
    }
    
    static func predicate(for weekday: Weekday) -> NSPredicate {
        return NSPredicate(format: "weekday == %i", weekday.rawValue)
    }
    
}

