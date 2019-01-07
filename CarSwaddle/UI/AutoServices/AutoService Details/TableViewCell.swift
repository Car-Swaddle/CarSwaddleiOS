//
//  TableViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class TableViewCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    
}
