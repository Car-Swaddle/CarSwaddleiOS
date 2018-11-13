//
//  DateExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns the day of the week from the current `Date` instance.
    /// 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
    var dayOfWeek: Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
}
