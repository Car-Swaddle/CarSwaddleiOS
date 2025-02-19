//
//  HourCollectionViewCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h a"
    return dateFormatter
}()

private var dateComponents: DateComponents = {
    var dateComponents = DateComponents()
    return dateComponents
}()

private let calendar = Calendar.current

final class HourCollectionViewCell: UICollectionViewCell, NibRegisterable {
    
    @IBOutlet private weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hourLabel.layer.borderColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        hourLabel.layer.cornerRadius = 3.0
        hourLabel.clipsToBounds = true
    }
    
    func configure(with hour: Int, state: AvailabilityState) {
        dateComponents.hour = hour
        if let date = calendar.date(from: dateComponents) {
            hourLabel.text = dateFormatter.string(from: date).lowercased()
        }
        hourLabel.textColor = self.textColor(for: state)
        configureLabel(for: state)
    }
    
    private func configureLabel(for state: AvailabilityState) {
        hourLabel.layer.borderWidth = self.borderWidth(for: state)
        hourLabel.layer.borderColor = self.borderColor(for: state).cgColor
        hourLabel.textColor = self.textColor(for: state)
        hourLabel.backgroundColor = self.backgroundColor(for: state)
    }
    
    private func backgroundColor(for state: AvailabilityState) -> UIColor {
        switch state {
        case .reserved:
            return UIColor(white: 0.95, alpha: 1.0)
        case .timeOff:
            return .white
        case .available:
            return .white
        case .currentlyScheduled:
            return UIColor(red: 0.1, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }
    
    private func textColor(for state: AvailabilityState) -> UIColor {
        switch state {
        case .reserved:
            return UIColor(white: 0.8, alpha: 1.0)
        case .timeOff:
            return UIColor(white: 0.8, alpha: 1.0)
        case .available:
            return UIColor(white: 0.0, alpha: 1.0)
        case .currentlyScheduled:
            return UIColor(white: 1.0, alpha: 1.0)
        }
    }
    
    private func borderWidth(for state: AvailabilityState) -> CGFloat {
        switch state {
        case .reserved, .timeOff:
            return 0.0
        case .available:
            return 0.0
        case .currentlyScheduled:
            return 1.0
        }
    }
    
    private func borderColor(for state: AvailabilityState) -> UIColor {
        switch state {
        case .reserved, .timeOff, .available:
            return .white
        case .currentlyScheduled:
            return UIColor(red: 0.4, green: 0.8, blue: 0.7, alpha: 1.0)
        }
    }
    
}

//extension Date {
//
//    public func secondsSinceMidnight() -> Int {
//        let units: Set<Calendar.Component>  = [.hour, .minute, .second]
//        let components = Calendar.current.dateComponents(units, from: self)
//        let hoursInSeconds = 60 * 60 * (components.hour ?? 0)
//        let minutesInSeconds = 60 * (components.minute ?? 0)
//        return hoursInSeconds + minutesInSeconds + (components.second ?? 0)
//    }
//
//}
//
//public extension Int64 {
//
//    public var numberOfDigits: Int {
//        var numberOfDigits: Int = 0
//        var dividedValue = self
//        while dividedValue > 0 {
//            dividedValue = dividedValue / 10
//            numberOfDigits += 1
//        }
//        return numberOfDigits
//    }
//
//    public var timeOfDayFormattedString: String {
//        let hours = self / (60*60)
//        let minutes = (self / 60) % 60
//        let seconds = self % 60
//
//        var hoursString: String = String(hours)
//        if hours.numberOfDigits < 2 {
//            hoursString = "0" + hoursString
//        }
//        var minutesString: String = String(minutes)
//        if minutes.numberOfDigits < 2 {
//            minutesString = "0" + minutesString
//        }
//        var secondsString: String = String(seconds)
//        if seconds.numberOfDigits < 2 {
//            secondsString = "0" + secondsString
//        }
//
//        return hoursString + ":" + minutesString + ":" + secondsString
//    }
//
//}
