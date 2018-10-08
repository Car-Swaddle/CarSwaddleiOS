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

class OilTypeCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var oilTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    var isSelectedOilType: Bool = false {
        didSet {
            if isSelectedOilType {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }
    
    func configure(with oilType: OilType) {
        oilTypeLabel.text = oilType.localizedString
    }
    
}
