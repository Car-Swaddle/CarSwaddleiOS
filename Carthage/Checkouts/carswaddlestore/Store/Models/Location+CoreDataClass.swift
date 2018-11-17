//
//  Location+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(Location)
public final class Location: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let id = json.identifier,
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double else { return nil }
        
        self.init(context: context)
        self.identifier = id
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public convenience init(context: NSManagedObjectContext, autoService: AutoService, coordinate: CLLocationCoordinate2D) {
        self.init(context: context)
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.autoService = autoService
    }

}
