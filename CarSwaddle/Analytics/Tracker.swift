//
//  Tracking.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/19/20.
//  Copyright © 2020 CarSwaddle. All rights reserved.
//

import Foundation
//import Firebase

let tracker = Tracker()

class Tracker {
    
    struct Name {
        let rawValue: String
        
        static let checkoutOption = Name(rawValue: "set_checkout_option")
        static let checkoutProgress = Name(rawValue: "set_checkout_progress")
        static let viewItem = Name(rawValue: "view_item")
        static let ecommercePurchase = Name(rawValue: "ecommerce_purchase")
        static let beginCheckout = Name(rawValue: "begin_checkout")
        static let signUp = Name(rawValue: "sign_up")
        static let login = Name(rawValue: "login")
        static let selectContent = Name(rawValue: "select_content")
    }
    
    struct Parameter: Hashable {
        let rawValue: String
        
        static let checkoutOption = Parameter(rawValue: "checkout_option")
        static let checkoutStep = Parameter(rawValue: "checkout_step")
        static let itemList = Parameter(rawValue: "item_list")
        static let price = Parameter(rawValue: "price")
        static let startDate = Parameter(rawValue: "start_date")
        static let currency = Parameter(rawValue: "currency")
        static let contentType = Parameter(rawValue: "content_type")
        static let method = Parameter(rawValue: "method")
        static let distanceTo = Parameter(rawValue: "oilChangeDistanceToCurrentUserLocation")
        static let userLocation = Parameter(rawValue: "userLocation")
        static let oilType = Parameter(rawValue: "oilType")
        static let vehicle = Parameter(rawValue: "vehicle")
        static let errorMessage = Parameter(rawValue: "errorMessage")

    }
    
    func configure() {
//        FirebaseConfiguration.shared.setLoggerLevel(.max)
//        FirebaseApp.configure()
    }
    
    func logEvent(name: String, parameters: [String: Any]?) {
//        Analytics.logEvent(name, parameters: parameters)
    }
    
    func logEvent(trackerName: Name, trackerParameters: [Parameter: Any]?) {
        logEvent(name: trackerName.rawValue, parameters: trackerParameters?.toStringAny())
    }
    
    func logEvent(trackerName: Name, parameters: [String: Any]?) {
        logEvent(name: trackerName.rawValue, parameters: parameters)
    }
    
}


private extension Dictionary where Key == Tracker.Parameter, Value == Any {
    
    func toStringAny() -> [String: Any] {
        var dict: [String: Any] = [:]
        for key in keys {
            dict[key.rawValue] = self[key]
        }
        return dict
    }
    
}

