//
//  Region+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Region)
public final class Region: NSManagedObject, NSManagedObjectFetchable {

    public convenience init?(json: JSONObject, in context: NSManagedObjectContext) {
        guard let latitude = json["latitude"] as? CGFloat,
            let longitude = json["longitude"] as? CGFloat,
            let radius = json["radius"] as? Double,
            let identifier = json["id"] as? String else {
                return nil
        }
        self.init(context: context)
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
}
