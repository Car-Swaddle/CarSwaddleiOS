//
//  VehicleCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/26/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

final class VehicleCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var isSelectedVehicle: Bool = false {
        didSet {
            if isSelectedVehicle {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }
    
    func configure(with vehicle: Vehicle) {
        textLabel?.text = vehicle.name
        if let plateNumber = vehicle.licensePlate {
            detailTextLabel?.text = NSLocalizedString("License plate: \(plateNumber)", comment: "")
        }
    }
    
}
