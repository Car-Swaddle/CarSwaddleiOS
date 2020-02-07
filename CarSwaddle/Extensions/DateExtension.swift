//
//  DateExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation


extension Date {
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self, wrappingComponents: false)!
    }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self, wrappingComponents: false)!
    }
    
    func dateByAdding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self, wrappingComponents: false)!
    }
    
    func dateByAdding(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self, wrappingComponents: false)!
    }
    
    func dateByAdding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self, wrappingComponents: false)!
    }
    
    func dateByAdding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self, wrappingComponents: false)!
    }
    
    /// Returns the day of the week from the current `Date` instance.
    /// 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
    var dayOfWeek: Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    var dayOfMonth: Int? {
        return Calendar.current.dateComponents([.day], from: self).day
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    static func with(secondsFromMidnight: Int) -> Date {
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let seconds = secondsFromMidnight % 60
        let minutes = (secondsFromMidnight / 60) % 60
        let hours = secondsFromMidnight / (60*60)
        return cal.date(bySettingHour: hours, minute: minutes, second: seconds, of: date)!
    }
    
    var timeIntervalSinceMidnight: TimeInterval {
        return self.timeIntervalSince(startOfDay)
    }
    
    var secondsSinceMidnight: Int {
        return Int(timeIntervalSinceMidnight)
    }
    
}



extension TimeInterval {
    
    public var days: Int {
        return Int(self.hours / 24)
    }
    
    public var minutes: Int {
        return Int(self / 60.0)
    }
    
    public var hours: Int {
        return self.minutes / Int(60.0)
    }
    
}
