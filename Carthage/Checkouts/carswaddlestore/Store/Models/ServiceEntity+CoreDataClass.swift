//
//  ServiceEntity+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 11/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ServiceEntity)
final public class ServiceEntity: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public enum EntityType: String, CaseIterable {
        case oilChange = "OILCHANGE"
    }
    
    /// Must set actual eneity relationship on your own. It is not set here and does not require it.
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let id = json.identifier,
            let autoServiceID = json["autoServiceID"] as? String,
            let autoService = AutoService.fetch(with: autoServiceID, in: context) else { return nil }
        
        self.init(context: context)
        self.identifier = id
        self.autoService = autoService
    }
    
    
    public convenience init(autoService: AutoService, oilChange: OilChange, context: NSManagedObjectContext) {
        self.init(context: context)
        self.autoService = autoService
        self.oilChange = oilChange
        self.entityType = .oilChange
    }
    
    private let entityTypeKey = "entityType"
    @NSManaged private var primitiveEntityType: String
    
    public var entityType: EntityType {
        set {
            willChangeValue(forKey: entityTypeKey)
            primitiveEntityType = newValue.rawValue
            didChangeValue(forKey: entityTypeKey)
        }
        get {
            willAccessValue(forKey: entityTypeKey)
            let enumValue = EntityType(rawValue: primitiveEntityType) ?? .oilChange
            didAccessValue(forKey: entityTypeKey)
            return enumValue
        }
    }
    
}
