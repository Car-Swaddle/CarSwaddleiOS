//
//  AddVehicleCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/26/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

final class AddVehicleCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var vehicleNameTextField: UITextField!
    @IBOutlet private weak var vehicleLicensePlateTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    private var isAddButtonEnabled: Bool {
        return vehicleNameTextField.text?.isEmpty == false && vehicleLicensePlateTextField.text?.isEmpty == false
    }
    
    @IBAction func nameTextDidChange(_ textField: UITextField) {
        addButton.isEnabled = isAddButtonEnabled
    }
    
    @IBAction func licensePlateTextDidChange(_ textField: UITextField) {
        addButton.isEnabled = isAddButtonEnabled
    }
    
    @IBAction func didSelectAdd(_ textField: UITextField) {
        resignFirstResponder()
        guard let name = vehicleNameTextField.text,
            let plateNumber = vehicleLicensePlateTextField.text else { return }
        let vehicle = Vehicle(name: name, licensePlate: plateNumber, user: User.currentUser(context: store.mainContext)!, context: store.mainContext)
        store.mainContext.persist()
        vehicleNameTextField.text = nil
        vehicleLicensePlateTextField.text = nil
    }
    
    
    
}
