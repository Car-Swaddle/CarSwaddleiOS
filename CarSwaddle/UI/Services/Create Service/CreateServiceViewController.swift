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
        case date
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
            case .date:
                let cell: CreateServiceDateCell = tableView.dequeueCell()
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
            guard let fetchedService  = AutoService.fetch(with: identifier, in: store.mainContext) else {
                return
            }
            autoService = fetchedService
        } else {
            let newAutoService = AutoService.createWithDefaults(context: store.mainContext)
            newAutoService.type = .oilChange
            newAutoService.vehicle = self.getVehicle()
            if let user = User.currentUser(context: store.mainContext) {
                newAutoService.creator = user
            }
            autoService = newAutoService
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
        tableView.register(CreateServiceDateCell.self)
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
            let viewController = SelectMechanicViewController.viewControllerFromStoryboard()
            navigationController?.show(viewController, sender: self)
        case .vehicle:
            let viewController = SelectVehicleViewController.create(autoService: autoService)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .date:
            let viewController = SelectDateViewController.viewControllerFromStoryboard()
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

extension CreateServiceViewController: SelectOilTypeViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController) {
        autoService.oilChange?.oilType = oilType
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
    
}

