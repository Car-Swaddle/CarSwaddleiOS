//
//  SelectMechanicDayCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleStore
import FSCalendar


let monthYearDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
}()



final class SelectMechanicDayCell: UITableViewCell, NibRegisterable {

    var updateHeight: () -> Void = { }
    
    var didSelectDay: (_ dayDate: Date) -> Void = { _ in }
    
    @IBOutlet private weak var weekViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var weekView: FSCalendar!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var minDate: Date = Date().dateByAdding(days: 1).startOfDay
    private lazy var maxDate: Date = minDate.dateByAdding(days: 7)
    
    private var dayDate: Date = Date().dateByAdding(days: 1).startOfDay {
        didSet {
            updateDateLabel()
            didSelectDay(dayDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        weekView.delegate = self
        weekView.dataSource = self
        weekView.setScope(.week, animated: false)
        weekView.appearance.weekdayFont = UIFont.appFont(type: .semiBold, size: 14)
        weekView.appearance.titleFont = UIFont.appFont(type: .semiBold, size: 16)
        
        titleLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        dateLabel.font = UIFont.appFont(type: .semiBold, size: 15)
        
        weekView.select(dayDate)
        updateDateLabel()
    }
    
    private func updateDateLabel() {
        dateLabel.text = monthYearDateFormatter.string(from: dayDate)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        weekView.reloadData()
    }
    
}

extension SelectMechanicDayCell: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if let selectedDayOfWeek = calendar.selectedDate?.dayOfWeek {
            let newDate = calendar.currentPage.dateByAdding(days: selectedDayOfWeek-1)
            if isAvailableDate(newDate)  {
                dayDate = newDate
                weekView.select(newDate)
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dayDate = date
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return isAvailableDate(date)
    }
    
    private func isAvailableDate(_ date: Date) -> Bool {
        return date >= minDate && date <= maxDate
    }
    
}

extension SelectMechanicDayCell: FSCalendarDataSource {
    
//    func minimumDate(for calendar: FSCalendar) -> Date {
////        return minDate.dateByAdding(days: -)
//    }
//
//    func maximumDate(for calendar: FSCalendar) -> Date {
//        return maxDate
//    }
    
}

extension SelectMechanicDayCell: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return .alternateSelectionColor
        } else if !isAvailableDate(date) {
            return .disabledText
        } else {
            return .text
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .white
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        weekViewHeightConstraint.constant = bounds.height
        layoutIfNeeded()
        updateHeight()
    }
    
}
