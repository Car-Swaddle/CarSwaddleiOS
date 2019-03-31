//
//  OilTypeCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Store

class OilTypeCollectionViewCell: FocusedCollectionViewCell, NibRegisterable {

    @IBOutlet private weak var oilTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        oilTypeLabel.font = UIFont.appFont(type: .regular, size: 17)
    }
    
    func configure(with oilType: OilType) {
        oilTypeLabel.text = oilType.localizedString
    }

}
