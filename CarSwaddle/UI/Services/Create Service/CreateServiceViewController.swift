//
//  CreateServiceViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

extension CreateServiceViewController {
    
    enum Row: CaseIterable {
        case location
        case mechanic
        case vehicle
        case oilType
        case price
        
        func cell(from tableView: UITableView) -> CreateServiceCell {
            switch self {
            case .location:
                let cell: CreateServiceLocationCell = tableView.dequeueCell()
                return cell
            case .mechanic:
                let cell: CreateServiceMechanicCell = tableView.dequeueCell()
                return cell
            case .vehicle:
                let cell: CreateServiceVehicleCell = tableView.dequeueCell()
                return cell
            case .oilType:
                let cell: CreateServiceOilTypeCell = tableView.dequeueCell()
                return cell
            case .price:
                let cell: CreateServicePriceCell = tableView.dequeueCell()
                return cell
            }
        }
        
    }
    
}


final class CreateServiceViewController: UIViewController, StoryboardInstantiating {
    
    static func create(autoServiceID: String?) -> CreateServiceViewController {
        let viewController = CreateServiceViewController.viewControllerFromStoryboard()
        viewController.autoServiceID = autoServiceID
        return viewController
    }
    
    private var autoServiceID: String? {
        didSet {
            fulfillAutoService()
        }
    }
    
    private var autoService: AutoService!
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var rows: [Row] = Row.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func fulfillAutoService() {
        if let identifier = autoServiceID {
            guard let fetchedService  = AutoService.fetch(with: identifier, in: store.mainContext) else { return }
            autoService = fetchedService
        } else {
            let context = store.mainContext
            let newAutoService = AutoService.createWithDefaults(context: context)
            let oilChange = OilChange(context: context)
            oilChange.identifier = OilChange.tempID
            oilChange.oilType = OilChange.defaultOilType
            let newServiceEntity = ServiceEntity(autoService: newAutoService, oilChange: oilChange, context: context)
            newAutoService.serviceEntities.insert(newServiceEntity)
            newAutoService.vehicle = getVehicle()
            if let user = User.currentUser(context: store.mainContext) {
                newAutoService.creator = user
            }
            autoService = newAutoService
            context.persist()
        }
    }
    
    private func getVehicle()  -> Vehicle? {
        let recentlyUsedAutoService = AutoService.fetchMostRecentlyUsed(forUserID: User.currentUserID!, in: store.mainContext)?.vehicle
        let firstVehicle = Vehicle.fetchFirstVehicle(forUserID: User.currentUserID!, in: store.mainContext)
        return  recentlyUsedAutoService ?? firstVehicle
    }
    
    private func setupTableView() {
        tableView.register(CreateServiceLocationCell.self)
        tableView.register(CreateServiceMechanicCell.self)
        tableView.register(CreateServiceVehicleCell.self)
        tableView.register(CreateServicePriceCell.self)
        tableView.register(CreateServiceOilTypeCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func didTapCancel() {
        store.mainContext.delete(autoService)
        store.mainContext.persist()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapRequest() {
        print("Request!")
        guard let service = try? autoService.toJSON() else {
            print("invalid json")
            return
        }
        print("autoService: \(service))")
    }
    
}

extension CreateServiceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.row(from: indexPath)
        let cell = row.cell(from: tableView)
        
        cell.configure(with: autoService)
        return cell
    }
    
    private func row(from indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}

extension CreateServiceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.row(from: indexPath)
        switch row {
        case .location:
            let viewController = SelectLocationViewController.create(delegate: self, autoService: autoService, location: autoService.location)
            navigationController?.show(viewController, sender: self)
        case .mechanic:
            let viewController = SelectMechanicViewController.create(with: autoService.location!.coordinate)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .vehicle:
            let viewController = SelectVehicleViewController.create(autoService: autoService)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .oilType:
            let viewController = SelectOilTypeViewController.create(with: autoService)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .price:
            break
        }
    }
    
}

extension CreateServiceViewController: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        self.autoService.location = location
        store.mainContext.persist()
        navigationController?.popViewController(animated: true)
    }
    
}

extension CreateServiceViewController: SelectMechanicDelegate {
    
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: SelectMechanicViewController) {
        self.autoService.mechanic = mechanic
        autoService.scheduledDate = date
        store.mainContext.persist()
        navigationController?.popViewController(animated: true)
    }
    
}

extension CreateServiceViewController: SelectOilTypeViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController) {
        autoService.firstOilChange?.oilType = oilType
        store.mainContext.persist()
        let indexPath = IndexPath(row: rows.index(of: .oilType) ?? 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
        navigationController?.popViewController(animated: true)
    }
    
}

extension CreateServiceViewController: SelectVehicleViewControllerDelegate {
    
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
        autoService.vehicle = vehicle
        store.mainContext.persist()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    func didDeselectVehicle(viewController: SelectVehicleViewController) {
        autoService.vehicle = nil
        store.mainContext.persist()
        tableView.reloadData()
    }
    
}


struct StoreError: Error {
    let rawValue: String
    
    static let invalidJSON = StoreError(rawValue: "invalidJSON")
    
}

extension AutoService {
    
    func toJSON() throws -> JSONObject {
        var json: JSONObject = [:]
        
//        json["locationID"] = location.identifier
        
//        if let locationID = location?.identifier {
//            json["locationID"] = location.identifier
//        } else {
        if let location = location {
            json["location"] = location.toJSON
        } else {
            throw StoreError.invalidJSON
        }
//        }
        
        if let mechanic = mechanic {
            json["mechanicID"] = mechanic.identifier
        } else {
            throw StoreError.invalidJSON
        }
        
        if let scheduledDate = scheduledDate {
            json["scheduledDate"] = scheduledDate
        } else {
            throw StoreError.invalidJSON
        }
        
        let jsonArray = serviceEntities.toJSONArray
        if jsonArray.count > 0 {
            json["serviceEntities"] = serviceEntities.toJSONArray
        } else {
            throw StoreError.invalidJSON
        }
        
        return json
    }
    
    var firstOilChange: OilChange? {
        return serviceEntities.first(where: { entity -> Bool in
            return entity.entityType == .oilChange
        })?.oilChange
    }
    
}

extension Sequence where Iterator.Element == ServiceEntity {
    
    var toJSONArray: [JSONObject] {
        var jsonArray: [JSONObject] = []
        for entity in self {
            jsonArray.append(entity.toJSON)
        }
        return jsonArray
    }
    
}

extension ServiceEntity {
    
    var toJSON: JSONObject {
        var entityJSON: JSONObject = [:]
        switch entityType {
        case .oilChange:
            if let oilChange = oilChange {
                entityJSON = oilChange.toJSON()
            }
        }
        return entityJSON
    }
    
}

extension OilChange {
    
    func toJSON(includeID: Bool = false) -> JSONObject {
        var json: JSONObject = [:]
        json["oilType"] = oilType.rawValue
        if includeID {
            json["identifier"] = identifier
        }
        return json
    }
    
}


extension Location {
    
    var toJSON: JSONObject {
        var json: JSONObject = [:]
        
        json["latitude"] = latitude
        json["longitude"] = longitude
//        json["identifier"] = identifier
        
        return json
    }
    
}
