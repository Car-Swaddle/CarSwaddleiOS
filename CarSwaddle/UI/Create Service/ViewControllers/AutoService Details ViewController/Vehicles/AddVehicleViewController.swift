//
//  AddVehicleViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store

protocol AddVehicleViewControllerDelegate: AnyObject {
    func didCreateVehicle(vehicle: Vehicle, viewController: AddVehicleViewController)
}

class AddVehicleViewController: UIViewController, StoryboardInstantiating {

    weak var delegate: AddVehicleViewControllerDelegate?
    
    private enum Row: CaseIterable {
        case name
        case licensePlate
    }
    
    private var rows: [Row] = Row.allCases
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    private lazy var insetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    private var vehicleNetwork: VehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    private var vehicleName: String?
    private var licensePlate: String?
    
    private var licensePlateTextField: UITextField?
    private var vehicleNameTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        actionButton.addTarget(self, action: #selector(AddVehicleViewController.didTapSave), for: .touchUpInside)
        
        insetAdjuster.includeTabBarInKeyboardCalculation = false
        insetAdjuster.showActionButtonAboveKeyboard = true
        insetAdjuster.positionActionButton()
    }
    
    private func setupTableView() {
        tableView.register(TextInputCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func didTapSave() {
        guard let name = vehicleName, let licensePlate = licensePlate else {
            return
        }
        
        actionButton.isLoading = true
        
        store.privateContext { [weak self] privateContext in
            self?.vehicleNetwork.createVehicle(name: name, licensePlate: licensePlate, in: privateContext) { newVehicleObjectID, error in
                store.mainContext { mainContext in
                    guard let self = self else { return }
                    self.actionButton.isLoading = false
                    if error == nil,
                        let newVehicleObjectID = newVehicleObjectID,
                        let vehicle = mainContext.object(with: newVehicleObjectID) as? Vehicle {
                        if let delegate = self.delegate {
                            delegate.didCreateVehicle(vehicle: vehicle, viewController: self)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}


extension AddVehicleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextInputCell = tableView.dequeueCell()
        switch rows[indexPath.row] {
        case .name:
            cell.labeledTextField.textField.placeholder = NSLocalizedString("e.g., Ford Explorer 1996", comment: "Example of a ame of the vehicle")
            cell.labeledTextField.labelText = NSLocalizedString("Vehicle name", comment: "Name of the vehicle")
            cell.labeledTextField.textField.autocapitalizationType = .words
            
            vehicleNameTextField = cell.labeledTextField.textField
        case .licensePlate:
            cell.labeledTextField.textField.placeholder = NSLocalizedString("e.g., 2GAT123", comment: "Example of a license plate")
            cell.labeledTextField.labelText = NSLocalizedString("License plate", comment: "License plate of a vehicle")
            cell.labeledTextField.textField.autocapitalizationType = .allCharacters
            licensePlateTextField = cell.labeledTextField.textField
        }
        
        cell.labeledTextField.labelTextExistsFont = UIFont.appFont(type: .regular, size: 15)
        cell.labeledTextField.labelTextNotExistsFont = UIFont.appFont(type: .semiBold, size: 15)
        cell.labeledTextField.textField.addTarget(self, action: #selector((AddVehicleViewController.textDidChange(_:))), for: .editingChanged)
        cell.labeledTextField.textField.autocorrectionType = .no
        cell.labeledTextField.textField.spellCheckingType = .no
        
        return cell
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if textField == licensePlateTextField {
            licensePlate = textField.text
        } else if textField == vehicleNameTextField {
            vehicleName = textField.text
        }
    }
    
}

extension AddVehicleCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

