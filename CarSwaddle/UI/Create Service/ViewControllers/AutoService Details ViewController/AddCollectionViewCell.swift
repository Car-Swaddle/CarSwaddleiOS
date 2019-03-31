//
//  AddCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class AddCollectionViewCell: UICollectionViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = defaultCornerRadius
    }

}
