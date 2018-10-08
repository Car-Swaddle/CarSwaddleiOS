//
//  OilTypeCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

final class CreateServiceOilTypeCell: UITableViewCell, NibRegisterable, AutoServiceConfigurable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with service: AutoService) {
        textLabel?.text = "Oil type"
        detailTextLabel?.text = service.oilChange?.oilType.localizedString ?? ""
    }
    
}
