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
//import CarSwaddleUI

protocol SelectVehicleViewControllerDelegate: class {
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController)
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
        viewController.selectedVehicle = autoService.vehicle ?? AutoService.fetchMostRecentlyUsed(forUserID: User.currentUserID!, in: store.mainContext)?.vehicle ?? Vehicle.fetchFirstVehicle(forUserID: User.currentUserID!, in: store.mainContext)
        return viewController
    }
    
    weak var delegate: SelectVehicleViewControllerDelegate?
    
    @IBOutlet private weak var tableView: UITableView!
    private var vehicles: [Vehicle] = []
    private var selectedVehicle: Vehicle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userID = User.currentUserID {
            vehicles = Vehicle.fetchVehicles(forUserID: userID, in: store.mainContext)
        }
        setupTableView()
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
        
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequestRecentlyCreated(forUserID: User.currentUserID!)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            fatalError("Could not performFetch on FetchedResultsController, error: \(error.localizedDescription)")
        }
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
            print("vehicles")
            let vehicle = vehicles[indexPath.row]
            selectedVehicle = vehicle
//            tableView.reloadData()
            delegate?.didSelectVehicle(vehicle: vehicle, viewController: self)
        case .addVehicle:
            print("add vehicle")
        }
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
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
