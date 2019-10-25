//
//  Links.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/20/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

public let urlNavigation = URLNavigation.shared

public struct URLNavigation {
    
    public static let shared: URLNavigation = URLNavigation(baseURL: "https://go.carswaddle.com")
    
    public let baseURL: String
    
    public var carSwaddleAppStoreURL: URL {
        return URL(string: baseURL + "/appstore")!
    }
    
}
