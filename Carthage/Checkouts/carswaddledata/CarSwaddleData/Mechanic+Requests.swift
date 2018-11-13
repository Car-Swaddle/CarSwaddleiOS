//
//  Mechanic+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData
import Store
import CarSwaddleNetworkRequest
import CoreLocation


public final class MechanicNetwork: Network {
    
    private lazy var mechanicService = MechanicService(serviceRequest: self.serviceRequest)
    
    @discardableResult
    public func getNearestMechanics(limit: Int, coordinate: CLLocationCoordinate2D, maxDistance: Double, in context: NSManagedObjectContext, completion: @escaping (_ mechanicIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return getNearestMechanics(limit: limit, latitude: coordinate.latitude, longitude: coordinate.longitude, maxDistance: maxDistance, in: context, completion: completion)
    }
    
    @discardableResult
    public func getNearestMechanics(limit: Int, latitude: Double, longitude: Double, maxDistance: Double, in context: NSManagedObjectContext, completion: @escaping (_ mechanicIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return mechanicService.getNearestMechanics(limit: limit, latitude: latitude, longitude: longitude, maxDistance: maxDistance) { [weak self] jsonArray, error in
            context.perform {
                var mechanicIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicIDs, error)
                    }
                }
                guard let jsonArray = jsonArray else { return }
                
                for json in jsonArray {
                    guard let mechanic = self?.createModel(from: json, in: context) else { continue }
                    do {
                        try context.obtainPermanentIDs(for: [mechanic])
                        mechanicIDs.append(mechanic.objectID)
                    } catch { print("unable to obtain permanent id") }
                }
                
                context.persist()
            }
        }
    }
    
    private func createModel(from json: JSONObject, in context: NSManagedObjectContext) -> Mechanic? {
        var regionJSON: JSONObject = json
        regionJSON["id"] = json["regionID"] as? String
        
        let region = Region.fetchOrCreate(json: regionJSON, context: context)
        
        let mechanic = Mechanic.fetchOrCreate(json: json, context: context)
        mechanic?.serviceRegion = region
        
        var userJSON: JSONObject = json
        userJSON["id"] = json["userID"] as? String
        
        let user = User.fetchOrCreate(json: userJSON, context: context)
        user?.mechanic = mechanic
        
        return mechanic
    }
    
}
