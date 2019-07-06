//
//  Price+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

typealias PriceValues = (identifier: String, totalPrice: Int, taxes: Int, subtotal: Int, processingFee: Int, bookingFee: Int, distance: Int, oilChange: Int, couponDiscount: Int?)

@objc(Price)
public final class Price: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Price.values(from: json) else { return nil }
        self.init(context: context)
        configure(from: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Price.values(from: json) else { throw StoreError.invalidJSON }
        configure(from: values, json: json)
    }
    
    private static func values(from json: JSONObject) -> PriceValues? {
        guard let id = json.identifier,
            let totalPrice = json["total"] as? Int,
            let processingFee = json["processingFee"] as? Int,
            let bookingFee = json["bookingFee"] as? Int,
            let distance = json["distance"] as? Int,
            let oilChange = json["oilChange"] as? Int,
            let taxes = json["taxes"] as? Int,
            let subtotal = json["subtotal"] as? Int else { return nil }
        
        return (id, totalPrice, taxes, subtotal, processingFee, bookingFee, distance, oilChange, json["couponDiscount"] as? Int)
    }
    
    private func configure(from values: PriceValues, json: JSONObject)  {
        self.identifier = values.identifier
        self.total = values.totalPrice
        self.taxes = values.taxes
        self.processingFee = values.processingFee
        self.bookingFee = values.bookingFee
        self.distanceCost = values.distance
        self.oilChangeCost = values.oilChange
        self.subtotal = values.subtotal
        
        guard let context = managedObjectContext else { return }
        
        if let autoServiceID = json["autoServiceID"] as? String {
            self.autoService = AutoService.fetch(with: autoServiceID, in: context)
        }
    }
    
    public var totalDollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(total) / 100.0)
    }
    
    
    private let couponDiscountKey = "couponDiscount"
    
    @NSManaged private var primitiveCouponDiscount: NSNumber?
    
    public var couponDiscount: Int? {
        set {
            willChangeValue(forKey: couponDiscountKey)
            if let newValue = newValue {
                primitiveCouponDiscount = NSNumber(value: newValue)
            } else {
                primitiveCouponDiscount = nil
            }
            didChangeValue(forKey: couponDiscountKey)
        }
        get {
            willAccessValue(forKey: couponDiscountKey)
            let value = primitiveCouponDiscount
            didAccessValue(forKey: couponDiscountKey)
            
            return value?.intValue
        }
    }
    
}
