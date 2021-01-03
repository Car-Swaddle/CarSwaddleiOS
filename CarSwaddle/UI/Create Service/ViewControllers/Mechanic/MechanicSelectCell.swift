//
//  MechanicSelectCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/3/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore

final class MechanicSelectCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with mechanic: Mechanic) {
        textLabel?.text = mechanic.user?.firstName
    }
    
}
