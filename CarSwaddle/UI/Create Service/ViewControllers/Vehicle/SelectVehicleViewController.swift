//
//  SelectLocationViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CoreData
import CarSwaddleData
//import CarSwaddleUI

protocol SelectVehicleViewControllerDelegate: class {
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController)
    func didDeselectVehicle(viewController: SelectVehicleViewController)
    func willBeDismissed(viewController: SelectVehicleViewController)
}

extension SelectVehicleViewController {
    
    enum Section: Int, CaseIterable {
        case vehicles
        case addVehicle
    }
    
}

final class SelectVehicleViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(autoService: AutoService) -> SelectVehicleViewController {
        let viewController = SelectVehicleViewController.viewControllerFromStoryboard()
        viewController.selectedVehicle = SelectVehicleViewController.fetchVehicle(with: autoService)
        return viewController
    }
    
    private class func fetchVehicle(with autoService: AutoService) -> Vehicle? {
        if let previousVehicle = autoService.vehicle {
            return previousVehicle
        } else {
            guard let currentUserID = User.currentUserID else { return nil }
            if let recentlyUsed = AutoService.fetchMostRecentlyUsed(forUserID: currentUserID, in: store.mainContext)?.vehicle {
                return recentlyUsed
            } else if let firstVehicle = Vehicle.fetchFirstVehicle(forUserID: currentUserID, in: store.mainContext) {
                return firstVehicle
            }
            return nil
        }
    }
    
    weak var delegate: SelectVehicleViewControllerDelegate?
    
    private var vehicleNetwork: VehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var tableView: UITableView!
//    private var vehicles: [Vehicle] = []
    private var vehicles: [Vehicle] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    private var selectedVehicle: Vehicle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let userID = User.currentUserID {
//            vehicles = Vehicle.fetchVehicles(forUserID: userID, in: store.mainContext)
//        }
        setupTableView()
        
        store.privateContext { [weak self] privateContext in
            
//            let vehicles = User.currentUser(context: privateContext)?.vehicles
//
//            for vehicle in vehicles ?? [] {
//                privateContext.delete(vehicle)
//            }
//            privateContext.persist()
            
            
//            let v = Vehicle.fetchAllObjects(with: [NSSortDescriptor(key: "identifier", ascending: true)], in: privateContext)
//
//            for d in v {
//                privateContext.delete(d)
//            }
//            privateContext.persist()
            
            self?.vehicleNetwork.requestVehicles(limit: 15, offset: 0, in: privateContext) { vehicleIDs, error in }
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    private func setupTableView() {
        tableView.register(VehicleCell.self)
        tableView.register(AddVehicleCell.self)
        tableView.tableFooterView = UIView()
    }
    
    lazy private var fetchedResultsController: NSFetchedResultsController<Vehicle> = {
        return createFetchedResultsController()
    }()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Vehicle> {
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequestRecentlyCreated(forUserID: User.currentUserID ?? "")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            fatalError("Could not performFetch on FetchedResultsController, error: \(error.localizedDescription)")
        }
    }
    
    private func selectVehicle(_ vehicle: Vehicle) {
        selectedVehicle = vehicle
        delegate?.didSelectVehicle(vehicle: vehicle, viewController: self)
    }
    
}


extension SelectVehicleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section(forSection: section) {
        case .vehicles:
            return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        case .addVehicle:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.section(forSection: indexPath.section) {
        case .vehicles:
            let cell: VehicleCell = tableView.dequeueCell()
            let vehicle = fetchedResultsController.object(at: indexPath)
            cell.configure(with: vehicle)
            cell.isSelectedVehicle = selectedVehicle == vehicle
            return cell
        case .addVehicle:
            let cell: AddVehicleCell = tableView.dequeueCell()
            cell.delegate = self
            return cell
        }
    }
    
    private func section(forSection section: Int) -> Section {
        switch section {
        case Section.vehicles.rawValue:
            return .vehicles
        case Section.addVehicle.rawValue:
            return .addVehicle
        default:
            fatalError("Redo number of sections to match")
        }
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch self.section(forSection: indexPath.section) {
        case .vehicles:
            return indexPath
        case .addVehicle:
            return nil
        }
    }
    
}

extension SelectVehicleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.section(forSection: indexPath.section)
        switch section {
        case .vehicles:
            let vehicle = vehicles[indexPath.row]
            selectVehicle(vehicle)
        case .addVehicle: break
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        actions.append(deleteAction(indexPath: indexPath))
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    private func deleteAction(indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "Delete a vehicle")
        let vehicleID = vehicles[indexPath.row].identifier
        let action = UIContextualAction(style: .destructive, title: title) { [weak self] action, view, handler in
            guard let _self = self else { return }
            if let selectedVehicle = self?.selectedVehicle,
                indexPath.row == self?.vehicles.firstIndex(of: selectedVehicle) {
                self?.delegate?.didDeselectVehicle(viewController: _self)
            }
            store.privateContext { context in
                self?.vehicleNetwork.deleteVehicle(vehicleID: vehicleID, in: context) { error in
                    DispatchQueue.main.async {
                        if self?.selectedVehicle?.identifier == vehicleID {
                            self?.selectedVehicle = nil
                        }
                        handler(error == nil)
                    }
                }
            }
        }
        return action
    }
    
}



extension SelectVehicleViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.reloadRows(at: [indexPath, newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .none)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.insertRows(at: [newIndexPath], with: .none)
        @unknown default:
            fatalError("new type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


extension SelectVehicleViewController: AddVehicleCellDelegate {
    
    func didSelectAdd(name: String, licensePlate: String, cell: AddVehicleCell) {
        store.privateContext { [weak self] context in
            self?.vehicleNetwork.createVehicle(name: name, licensePlate: licensePlate, in: context) { [weak self] objectID, error in
                DispatchQueue.main.async {
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
//                store.mainContext{ mainContext in
//                    guard let objectID = objectID,
//                        let vehicle = mainContext.object(with: objectID) as? Vehicle else { return }
//                    self?.selectVehicle(vehicle)
//                    self?.tableView.reloadData()
//                    let indexPath = IndexPath(row: index, section: 0)
//                    self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//                }
            }
        }
    }
    
}
