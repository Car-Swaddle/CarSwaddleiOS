//
//  SelectMechanicHourCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store
import CarSwaddleData


let hourThing: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd HH:mm z"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter
}()

final class SelectMechanicHourCell: UITableViewCell, NibRegisterable {

    func configure(with dayDate: Date?, mechanicID: String?, selectedStartTime: Int?) {
        self.dayDate = dayDate
        self.mechanicID = mechanicID
        self.selectedStartTime = selectedStartTime
        
        updateTimeSlots()
    }
    
    var updateHeight: () -> Void = {  }
    var didSelectStartTime: (_ startTime: Int) -> Void = { _ in }
    
    var selectedStartTime: Int?
    
    private var dayDate: Date?
    private var mechanicID: String?
    
    @IBOutlet private weak var collectionView: HourCollectionView!
    
    @IBOutlet private weak var hourStackView: HourStackView!
    
    @IBOutlet private weak var noTimesAvailableLabel: UILabel!
    @IBOutlet private weak var headerLabel: UILabel!
    
    private var templateTimeSpans: [TemplateTimeSpan] = []
    private var scheduledAutoServices: [AutoService] = []
    
    private var task: URLSessionDataTask? {
        willSet {
            task?.cancel()
        }
    }
    
    private var startDate: Date? {
        return dayDate?.startOfDay
    }
    
    private var endDate: Date? {
        return dayDate?.endOfDay
    }
    
    private var templateTimeSpanNetwork = TemplateTimeSpanNetwork(serviceRequest: serviceRequest)
    private var autoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var startTimes: [Int] = [] {
        didSet {
            hourStackView.startTimes = startTimes
            noTimesAvailableLabel.isHiddenInStackView = startTimes.count != 0
            updateHeight()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        hourStackView.didSelectStartTime = { [weak self] startTime in
            self?.selectedStartTime = startTime
            self?.didSelectStartTime(startTime)
        }
        
        noTimesAvailableLabel.font = UIFont.appFont(type: .regular, size: 15)
        headerLabel.font = UIFont.appFont(type: .semiBold, size: 17)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    private func updateTimeSlots() {
        loadData { [weak self] in
            guard let self = self else { return }
            self.updateTimeSlotsWithLocalData()
        }
    }
    
    private func updateTimeSlotsWithLocalData() {
        guard let dayDate = dayDate, let dayOfWeek = dayDate.dayOfWeek else {
            startTimes = []
            return
        }
        
        var timeSlotDict: [Int: Bool] = [:]
        
        for timeSpan in templateTimeSpans where timeSpan.weekday.rawValue == dayOfWeek - 1 {
            timeSlotDict[Int(timeSpan.startTime)] = true
        }
        
        for autoService in scheduledAutoServices {
            guard let scheduledDate = autoService.scheduledDate else { continue }
            let startTime = scheduledDate.secondsSinceMidnight
            timeSlotDict.removeValue(forKey: startTime)
        }
        
        self.startTimes = timeSlotDict.keys.sorted { (lhs, rhs) -> Bool in
            return lhs < rhs
        }
    }
    
    private func loadData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        requestAutoServices {
            group.leave()
        }
        
        group.enter()
        requestSchedule {
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func requestAutoServices(completion: @escaping () -> Void) {
        guard let mechanicID = mechanicID,
            let startDate = self.startDate,
            let endDate = self.endDate  else {
                completion()
                return
        }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServices(mechanicID: mechanicID, startDate: startDate, endDate: endDate, filterStatus: [.inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
                store.mainContext{ mainContext in
                    let autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
                    self?.scheduledAutoServices = autoServices
                    completion()
                }
            }
        }
    }
    
    private func requestSchedule(completion: @escaping () -> Void) {
        guard let mechanicID = mechanicID else {
            completion()
            return
        }
        store.privateContext { [weak self] context in
            self?.task = self?.templateTimeSpanNetwork.getTimeSpans(ofMechanicWithID: mechanicID, in: context) { objectIDs, error in
                store.mainContext { mainContext in
                    self?.templateTimeSpans = TemplateTimeSpan.fetchObjects(with: objectIDs, in: mainContext)
                    completion()
                }
            }
        }
    }
    
}


class HourStackView: UIStackView {
    
    var startTimes: [Int] = [] {
        didSet {
            for arrangedView in arrangedSubviews {
                removeArrangedSubview(arrangedView)
                arrangedView.removeFromSuperview()
            }
            hourDisplayViews.removeAll()
            configureForStartTimes()
        }
    }
    
    var didSelectStartTime: (_ startTime: Int) -> Void = { _ in }
    
    var selectedStartTime: Int? {
        didSet {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            updateForSelectedStartTime()
        }
    }
    
    private var hourDisplayViews: [Int: HourDisplayView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        axis = .vertical
        spacing = 16
        alignment = .center
        distribution = .equalCentering
    }
    
    private func configureForStartTimes() {
        let chunkedStartTimes = startTimes.chunked(by: 4)
        for row in chunkedStartTimes {
            let rowView = self.createRow(from: row)
            addArrangedSubview(rowView)
        }
    }
    
    private func createRow(from startTimes: [Int]) -> UIStackView {
        var views: [UIView] = []
        for startTime in startTimes {
            let view = hourDisplayView(with: startTime)
            views.append(view)
            hourDisplayViews[startTime] = view
        }
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.axis = .horizontal
        return stackView
    }
    
    private func hourDisplayView(with startTime: Int) -> HourDisplayView {
        let view = HourDisplayView.viewFromNib()
        view.configure(with: startTime)
        view.didSelectHour = { [weak self]  in
            self?.selectedStartTime = startTime
            self?.didSelectStartTime(startTime)
        }
        hourDisplayViews[startTime] = view
        return view
    }
    
    private func updateForSelectedStartTime() {
        for hourDisplayViewKey in hourDisplayViews.keys {
            hourDisplayViews[hourDisplayViewKey]?.styleAsUnselected()
        }
        if let selectedStartTime = selectedStartTime {
            hourDisplayViews[selectedStartTime]?.styleAsSelected()
        }
    }
    
}


protocol HourCollectionViewDelegate: AnyObject {
    func didSelectCell()
}

@IBDesignable
class HourCollectionView: DynamicCollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBInspectable
    var startTimes: [Int] = [] {
        didSet {
            reloadData()
            layoutIfNeeded()
        }
    }
    
    weak var hourDelegate: HourCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        register(TimeSlotCollectionViewCell.self)
        dataSource = self
        delegate = self
        flowLayout?.estimatedItemSize = CGSize(width: 150, height: 100)
        flowLayout?.minimumLineSpacing = 4
        flowLayout?.minimumInteritemSpacing = 4
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        startTimes = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16].map { $0.hoursInSeconds }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return startTimes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TimeSlotCollectionViewCell = dequeueCell(for: indexPath)
        cell.configure(with: startTimes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        hourDelegate?.didSelectCell()
    }
    
}




open class DynamicCollectionView: UICollectionView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}


extension Int {
    
    var secondsToHours: Int {
        return secondsToMinutes / 60
    }
    
    var secondsToMinutes: Int {
        return self / 60
    }
    
    var hoursInSeconds: Int {
        return minutesInSeconds * 60
    }
    
    var minutesInSeconds: Int {
        return self * 60
    }
    
}


extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
