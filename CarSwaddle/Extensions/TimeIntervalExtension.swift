//
//  TimeIntervalExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = .minute*60
    static let day: TimeInterval = .hour*24
    static let week: TimeInterval = .day*7
    
}
