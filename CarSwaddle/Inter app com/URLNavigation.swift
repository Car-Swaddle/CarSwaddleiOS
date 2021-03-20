//
//  URLNAvigation.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/20/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import Foundation

public struct URLNavigation {
    
    public let baseURL: String
    
    public var carSwaddleAppStorePath: String {
        return baseURL + "/appstore"
    }
    
    public var carSwaddleAppStoreURL: URL {
        return URL(string: carSwaddleAppStorePath)!
    }
    
}
