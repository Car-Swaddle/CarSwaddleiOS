//
//  DateCardView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 4/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

let dayOfWeekDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return formatter
}()

let timeOfDayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE h:mm a"
    formatter.amSymbol = NSLocalizedString("am", comment: "symbol for AM. Lowercase preferred")
    formatter.pmSymbol = NSLocalizedString("pm", comment: "symbol for PM. Lowercase preferred")
    return formatter
}()

let dayOfMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    return formatter
}()

let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
}()

final class DateCardView: UIView, NibInstantiating {
    
    @IBOutlet private weak var dayOfMonthLabel: UILabel!
    @IBOutlet private weak var dayOfWeekLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!
    
    func configure(with date: Date) {
        dayOfMonthLabel.text = dayOfMonthFormatter.string(from: date)
        dayOfWeekLabel.text = dayOfWeekDateFormatter.string(from: date)
        monthLabel.text = monthFormatter.string(from: date)
        timeLabel.text = timeOfDayDateFormatter.string(from: date)
    }
    
    private func dayOfMonth(from date: Date) -> String? {
        if let dayOfMonth = date.dayOfMonth {
            let formatString = NSLocalizedString("%i", comment: "day of month")
            return String(format: formatString, dayOfMonth)
        } else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dayOfMonthLabel.font = UIFont.appFont(type: .regular, size: 40, scaleFont: false)
        dayOfWeekLabel.font = UIFont.appFont(type: .regular, size: 15, scaleFont: false)
        timeLabel.font = UIFont.appFont(type: .regular, size: 15, scaleFont: false)
        monthLabel.font = UIFont.appFont(type: .regular, size: 15, scaleFont: false)
    }
    
}

final class DateCardViewWrapper: UIView {
    
    lazy var view: DateCardView = DateCardView.viewFromNib()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        addSubview(view)
        view.pinFrameToSuperViewBounds()
    }
    
}
