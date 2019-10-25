//
//  LabeledHeaderView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/18/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class LabeledHeaderView: UIView, NibInstantiating {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.titleStyled()
    }
    
}
