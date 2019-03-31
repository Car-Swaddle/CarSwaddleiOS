//
//  AutoServiceCreation.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store

final class AutoServiceCreation {
    
    public var pocketController: PocketController!
    
    private var autoService: AutoService
    
    init() {
        assert(Thread.isMainThread, "Must be on main")
        
        self.autoService = AutoService.createWithDefaults(context: store.mainContext)
        store.mainContext.persist()
        
        let pocketController = PocketController(rootViewController: selectLocationViewController, bottomViewController: progressViewController)
        pocketController.bottomViewControllerHeight = 120
        
        self.pocketController = pocketController
    }
    
    private lazy var progressViewController: AutoServiceCreationProgressViewController = {
        let progressViewController = AutoServiceCreationProgressViewController.viewControllerFromStoryboard()
        return progressViewController
    }()
    
    private lazy var selectLocationViewController: SelectLocationViewController = {
        let selectLocationViewController = SelectLocationViewController.create(delegate: self, autoService: autoService, location: nil)
        return selectLocationViewController
    }()
    
}

extension AutoServiceCreation: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        
        progressViewController.currentState = .mechanic
        
        autoService.location = location
//        let selectMechanic = SelectMechanicViewController.create(with: location.coordinate)
//        selectMechanic.delegate = self
        
        let selectMechanic = SelectMechanicTableViewController.create(with: location.coordinate)
        selectMechanic.delegate = self
        pocketController.show(selectMechanic, sender: self)
    }
    
    func willBeDismissed(viewController: SelectLocationViewController) {
        
    }
    
}

extension AutoServiceCreation: SelectMechanicDelegate {
    
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: UIViewController) {
        print("mechanic")
        progressViewController.currentState = .details
        
        autoService.mechanic = mechanic
        autoService.scheduledDate = date
        
//        let vehicleSelect: SelectVehicleViewController = SelectVehicleViewController.create(autoService: autoService)
//        vehicleSelect.delegate = self
        let detailsSelect = SelectAutoServiceDetailsViewController.viewControllerFromStoryboard()
        detailsSelect.delegate = self
        pocketController.show(detailsSelect, sender: self)
    }
    
    func willBeDismissed(viewController: UIViewController) {
        progressViewController.currentState = .location
    }
    
}

extension AutoServiceCreation: SelectAutoServiceDetailsViewControllerDelegate {
    
//    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
    
        
//        let selectOilType: SelectOilTypeViewController = SelectOilTypeViewController.create(with: autoService)
//        selectOilType.delegate = self
        
//        pocketController.show(selectOilType, sender: self)
//    }
    
    func didSelect(vehicle: Vehicle, oilType: OilType, viewController: SelectAutoServiceDetailsViewController) {
        progressViewController.currentState = .payment
    }
    
    func willBeDismissed(viewController: SelectAutoServiceDetailsViewController) {
        progressViewController.currentState = .mechanic
    }
    
//    func willBeDismissed(viewController: SelectVehicleViewController) {
//        progressViewController.currentState = .mechanic
//    }
    
}

extension AutoServiceCreation: SelectVehicleViewControllerDelegate {
    
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
        progressViewController.currentState = .payment
        
        let selectOilType: SelectOilTypeViewController = SelectOilTypeViewController.create(with: autoService)
        selectOilType.delegate = self
        
        pocketController.show(selectOilType, sender: self)
    }
    
    func didDeselectVehicle(viewController: SelectVehicleViewController) {
        
    }
    
    func willBeDismissed(viewController: SelectVehicleViewController) {
        progressViewController.currentState = .mechanic
    }
    
}

extension AutoServiceCreation: SelectOilTypeViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController) {
        print("oil type")
        // show price
    }
    
    func willBeDismissed(viewController: SelectOilTypeViewController) {
        progressViewController.currentState = .details
    }
    
}
