//
//  SelectMechanicTableViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import MapKit
import CarSwaddleData

final class SelectMechanicTableViewController: UIViewController, StoryboardInstantiating {

    public static func create(with location: CLLocationCoordinate2D) -> SelectMechanicTableViewController {
        let viewController = SelectMechanicTableViewController.viewControllerFromStoryboard()
        viewController.location = location
        return viewController
    }
    
    
    @IBOutlet private weak var tableView: UITableView!
    public weak var delegate: SelectMechanicDelegate?
    
    private enum Row: CaseIterable {
        case selectMechanic
        case selectMechanicDay
        case selectMechanicHour
    }
    
    private var rows: [Row] = Row.allCases
    private var selectedMechanic: Mechanic?
    
    private let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var location: CLLocationCoordinate2D!
    private var mechanics: [Mechanic] = [] {
        didSet {
//            if let firstMechanic = mechanics.first {
//                let firstViewController = MechanicViewController.create(mechanic: firstMechanic)
////                firstViewController.delegate = self
//                mechanicPageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
//            }
//            mechanicPageViewController.dataSource = nil
//            mechanicPageViewController.dataSource = self
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        updateMechanics()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    @IBAction private func didSelectSave() {
//        guard let mechanic = currentSelectedMechanic, let scheduledDate = scheduledDate else { return }
//        delegate?.didSaveMechanic(mechanic: mechanic, date: scheduledDate, viewController: self)
    }
    
    private func setupTableView() {
        tableView.register(SelectMechanicProfileCell.self)
        tableView.register(SelectMechanicDayCell.self)
        tableView.register(SelectMechanicHourCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func updateMechanics() {
        guard let location = self.location else { return }
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, coordinate: location, maxDistance: 1_000_000, in: context) { mechanicIDs, error in
                store.mainContext { mainContext in
                    self?.mechanics = Mechanic.fetchObjects(with: mechanicIDs, in: mainContext)
                    // Update saved enabledness
                }
            }
        }
    }
    
}


extension SelectMechanicTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .selectMechanic:
            let cell: SelectMechanicProfileCell = tableView.dequeueCell()
            cell.mechanics = mechanics
            cell.selectedMechanic = mechanics.first
            cell.delegate = self
            return cell
        case .selectMechanicDay:
            let cell: SelectMechanicDayCell = tableView.dequeueCell()
            if let mechanic = selectedMechanic {
                cell.configure(with: mechanic)
            } else {
                cell.configureForEmpty()
            }
            cell.updateHeight = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return cell
        case .selectMechanicHour:
            let cell: SelectMechanicHourCell = tableView.dequeueCell()
            if let mechanic = selectedMechanic {
                cell.configure(with: mechanic)
            } else {
                cell.configureForEmpty()
            }
            return cell
        }
    }
    
}

extension SelectMechanicTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


extension SelectMechanicTableViewController: SelectMechanicProfileCellDelegate {
    
    func didSelect(mechanic: Mechanic, cell: SelectMechanicProfileCell) {
        print("selected mech")
    }
    
}
