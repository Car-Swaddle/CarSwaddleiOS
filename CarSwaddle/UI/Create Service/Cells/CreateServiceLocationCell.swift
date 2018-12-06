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

class CreateServiceLocationCell: UITableViewCell, NibRegisterable, AutoServiceConfigurable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with service: AutoService) {
        textLabel?.text = "Location"
    }
    
}
