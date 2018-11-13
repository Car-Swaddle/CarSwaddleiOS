//
//  Mechanic+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

@objc(Mechanic)
public final class Mechanic: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let identifier = json.identifier,
            let isActive = json["isActive"] as? Bool else { return nil }
        
        self.init(context: context)
        self.identifier = identifier
        self.isActive = isActive
    }

    public static func currentLoggedInMechanic(in context: NSManagedObjectContext) -> Mechanic? {
        return User.currentUser(context: context)?.mechanic
    }
    
    public func deleteAllCurrentScheduleTimeSpans() {
        for timespan in scheduleTimeSpans {
            managedObjectContext?.delete(timespan)
        }
    }
    
}
