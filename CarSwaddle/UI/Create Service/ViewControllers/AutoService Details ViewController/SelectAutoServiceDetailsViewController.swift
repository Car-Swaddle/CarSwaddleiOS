//
//  SelectAutoServiceDetailsViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store


protocol SelectAutoServiceDetailsViewControllerDelegate: class {
    func didSelect(vehicle: Vehicle, oilType: OilType, viewController: SelectAutoServiceDetailsViewController)
    func willBeDismissed(viewController: SelectAutoServiceDetailsViewController)
}

class SelectAutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {
    
    weak var delegate: SelectAutoServiceDetailsViewControllerDelegate?
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    private enum Row: CaseIterable {
        case vehicle
        case oilType
    }
    
    private var rows: [Row] = Row.allCases
    private var vehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        insetAdjuster.positionActionButton()
        
        requestVehicles()
    }
    
    private func setupTableView() {
        tableView.register(SelectVehicleCell.self)
        tableView.register(SelectOilTypeCell.self)
        tableView.tableFooterView = UIView()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    private var isPayButtonEnabled: Bool {
        return true
    }
    
    private func requestVehicles(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.vehicleNetwork.requestVehicles(limit: 10, offset: 0, in: privateContext) { vehicles, error in
                store.mainContext { mainContext in
                    self?.tableView.reloadData()
                    completion()
                }
            }
        }
    }
    
}


extension SelectAutoServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.item]
        switch row {
        case .vehicle:
            let cell: SelectVehicleCell = tableView.dequeueCell()
            cell.delegate = self
            return cell
        case .oilType:
            let cell: SelectOilTypeCell = tableView.dequeueCell()
            return cell
        }
    }
    
}

extension SelectAutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


extension SelectAutoServiceDetailsViewController: SelectVehicleCellDelegate, AddVehicleViewControllerDelegate {
    
    func didSelectAdd(cell: SelectVehicleCell) {
        let addVehicleViewController = AddVehicleViewController.viewControllerFromStoryboard()
        let navigationController = addVehicleViewController.inNavigationController()
        addVehicleViewController.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
    
    func didCreateVehicle(vehicle: Vehicle, viewController: AddVehicleViewController) {
        requestVehicles()
        tableView.reloadData()
    }
    
}
