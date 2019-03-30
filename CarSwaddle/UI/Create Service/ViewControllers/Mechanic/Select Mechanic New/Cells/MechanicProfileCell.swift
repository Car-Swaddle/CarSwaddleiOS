//
//  MechanicProfileCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

final class MechanicProfileCell: FocusedCollectionViewCell, NibRegisterable {

    func configure(with mechanic: Mechanic) {
        mechanicProfileView.configure(with: mechanic)
    }
    
    private lazy var mechanicProfileView: MechanicProfileHeaderView = {
        let mechanicView = MechanicProfileHeaderView.viewFromNib()
        mechanicView.backgroundColor = .clear
        return mechanicView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(mechanicProfileView)
        mechanicProfileView.pinFrameToSuperViewBounds()
        mechanicProfileView.layer.cornerRadius = defaultCornerRadius
//
//        layer.shadowOpacity = 0.3
//        layer.shadowOffset = CGSize(width: 2, height: 2)
//        layer.shadowRadius = 4
//
//        clipsToBounds = false
//        layer.masksToBounds = false
    }

}
