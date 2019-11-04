//
//  VehicleCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

class VehicleCollectionViewCell: FocusedCollectionViewCell, NibRegisterable {

    @IBOutlet private weak var vehicleNameLabel: UILabel!
    @IBOutlet private weak var licensePlateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .content
        
        vehicleNameLabel.font = UIFont.appFont(type: .regular, size: 17)
        licensePlateLabel.font = UIFont.appFont(type: .regular, size: 17)
    }
    
    func configure(with vehicle: Vehicle) {
        vehicleNameLabel.text = vehicle.name
        licensePlateLabel.text = vehicle.licensePlate
    }

}
