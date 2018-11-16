//
//  TemplateTimeSpan+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData



public enum Weekday: Int16, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

@objc(TemplateTimeSpan)
public final class TemplateTimeSpan: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let identifier = json["id"] as? String,
            let duration = json["duration"] as? Double,
            let weekdayInt = json["weekDay"] as? Int16,
            let mechanicID = json["mechanicID"] as? String,
            let mechanic = Mechanic.fetch(with: mechanicID, in: context),
            let weekday = Weekday(rawValue: weekdayInt),
            let dateString = json["startTime"] as? String,
            let date = TemplateTimeSpan.dateFormatter.date(from: dateString) else { return nil }
        
        self.init(context: context)
        self.identifier = identifier
        self.duration = duration
        self.startTime = Int64(date.secondsSinceMidnight())
        self.weekday = weekday
        self.mechanic = mechanic
    }
    
    
    private let weekdayKey = "weekday"
    
    public var weekday: Weekday {
        set {
            willChangeValue(forKey: weekdayKey)
            setPrimitiveValue(newValue.rawValue, forKey: weekdayKey)
            didChangeValue(forKey: weekdayKey)
        }
        get {
            willAccessValue(forKey: weekdayKey)
            let primitiveWeekday = primitiveValue(forKey: weekdayKey) as! Int16
            let value = Weekday(rawValue: primitiveWeekday)!
            didAccessValue(forKey: weekdayKey)
            return value
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    public var toJSON: JSONObject {
        return ["startTime": startTime, "duration": duration, "weekDay": weekday.rawValue]
    }
    
    public var startTimeStringFormat: String {
        return startTime.timeOfDayFormattedString
    }
    
    public static func fetch(with weekday: Weekday, mechanicID: String, in context: NSManagedObjectContext) -> [TemplateTimeSpan] {
        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
        
        let mechanicPredicate = TemplateTimeSpan.predicate(forMechanicID: mechanicID)
        let weekdayPredicate = TemplateTimeSpan.predicate(for: weekday)
        let predicates: [NSPredicate] = [mechanicPredicate, weekdayPredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    public static func predicate(forMechanicID mechanicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID)
    }
    
    public static func predicate(for weekday: Weekday) -> NSPredicate {
        return NSPredicate(format: "weekday == %i", weekday.rawValue)
    }

}


