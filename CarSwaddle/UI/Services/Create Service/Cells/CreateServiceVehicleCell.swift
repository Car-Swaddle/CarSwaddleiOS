//
//  CreateServiceLocationCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

class CreateServiceVehicleCell: UITableViewCell, NibRegisterable, AutoServiceConfigurable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with service: AutoService) {
        textLabel?.text = "Vehicle"
        if let vehicle = service.vehicle {
            if let licensePlate = vehicle.licensePlate {
                detailTextLabel?.text = "\(vehicle.name), \(licensePlate)"
            } else {
                detailTextLabel?.text = "\(vehicle.name)"
//                detailTextLabel?.text = "\(vehicle.name), \(vehicle.licensePlate)"
            }
        }
    }
    
}
