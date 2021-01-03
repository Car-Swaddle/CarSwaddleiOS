//
//  AddVehicleCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/26/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleStore
//import CarSwaddleUI

protocol AddVehicleCellDelegate: AnyObject {
    func didSelectAdd(name: String, licensePlate: String, cell: AddVehicleCell)
}

final class AddVehicleCell: UITableViewCell, NibRegisterable {

    weak var delegate: AddVehicleCellDelegate?
    
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
    
    @IBAction private func nameTextDidChange(_ textField: UITextField) {
        addButton.isEnabled = isAddButtonEnabled
    }
    
    @IBAction private func licensePlateTextDidChange(_ textField: UITextField) {
        addButton.isEnabled = isAddButtonEnabled
    }
    
    @IBAction private func didSelectAdd(_ textField: UITextField) {
        guard let name = vehicleNameTextField.text,
            let plateNumber = vehicleLicensePlateTextField.text else { return }
        resignFirstResponder()
        delegate?.didSelectAdd(name: name, licensePlate: plateNumber, cell: self)
    }
    
}
