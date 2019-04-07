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
import CarSwaddleUI

//
//protocol SelectMechanicTableViewControllerDelegate: class {
//
////    func didSelect(location: Location, viewController: SelectLocationViewController)
////    func willBeDismissed(viewController: SelectMechanicTableViewController)
//}

final class SelectMechanicTableViewController: UIViewController, StoryboardInstantiating {

    public static func create(with location: CLLocationCoordinate2D) -> SelectMechanicTableViewController {
        let viewController = SelectMechanicTableViewController.viewControllerFromStoryboard()
        viewController.location = location
        return viewController
    }
    
    
    @IBOutlet private weak var tableView: UITableView!
    public weak var delegate: SelectMechanicDelegate?
    
    @IBOutlet private weak var actionButton: ActionButton!
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    private var selectedStartTime: Int? {
        didSet {
            updateActionButtonEnabled()
        }
    }
    
    private var dayDate: Date = Date().dateByAdding(days: 1).startOfDay {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func updateActionButtonEnabled() {
        actionButton.isEnabled = isActionButtonEnabled
    }
    
    private var isActionButtonEnabled: Bool {
        return selectedStartTime != nil
    }
    
    private enum Row: CaseIterable {
        case selectMechanic
        case selectMechanicDay
        case selectMechanicHour
    }
    
    private var rows: [Row] = Row.allCases
    private var selectedMechanic: Mechanic? {
        didSet {
            selectedStartTime = nil
            tableView.reloadData()
        }
    }
    
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
            
            selectedMechanic = mechanics.first
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        updateMechanics()
        insetAdjuster.positionActionButton()
        insetAdjuster.includeTabBarInKeyboardCalculation = false
        
        actionButton.addTarget(self, action: #selector(SelectMechanicTableViewController.didSelectConfirmMechanic), for: .touchUpInside)
        
        updateActionButtonEnabled()
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
                }
            }
        }
    }
    
    @objc private func didSelectConfirmMechanic() {
        guard let selectedMechanic = selectedMechanic,
            let startTime = selectedStartTime,
            let scheduledDate = Calendar.current.date(bySettingHour: startTime.secondsToHours, minute: startTime.secondsToMinutes % 60, second: startTime % 60, of: dayDate) else {
            return
        }
        
        delegate?.didSaveMechanic(mechanic: selectedMechanic, date: scheduledDate, viewController: self)
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
            if cell.selectedMechanic == nil {
                cell.selectedMechanic = mechanics.first
            }
            cell.delegate = self
            return cell
        case .selectMechanicDay:
            let cell: SelectMechanicDayCell = tableView.dequeueCell()
//            if let mechanic = selectedMechanic {
//                cell.configure(with: mechanic)
//            } else {
//                cell.configureForEmpty()
//            }
            cell.updateHeight = { [weak self] in
                guard let self = self else { return }
                tableView.performBatchUpdates({
                    self.tableView.layoutIfNeeded()
                }, completion: nil)
            }
            cell.didSelectDay = { [weak self] dayDate in
                self?.dayDate = dayDate
                self?.selectedStartTime = nil
            }
            return cell
        case .selectMechanicHour:
            let cell: SelectMechanicHourCell = tableView.dequeueCell()
            cell.configure(with: dayDate, mechanicID: selectedMechanic?.identifier, selectedStartTime: selectedStartTime)
            cell.updateHeight = { [weak self] in
                guard let self = self else { return }
                tableView.performBatchUpdates({
                    self.tableView.layoutIfNeeded()
                }, completion: nil)
            }
            cell.didSelectStartTime = { [weak self] startTime in
                self?.selectedStartTime = startTime
            }
            if selectedStartTime == nil {
                cell.selectedStartTime = nil
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 391
        case 1: return 193
        case 2: return 241
        default: return 200
        }
        
//        return 1000
    }
    
}

extension SelectMechanicTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedMechanic = mechanics[indexPath.item]
    }
    
}


extension SelectMechanicTableViewController: SelectMechanicProfileCellDelegate {
    
    func didSelect(mechanic: Mechanic, cell: SelectMechanicProfileCell) {
        print("selected mech")
        selectedMechanic = mechanic
    }
    
}
