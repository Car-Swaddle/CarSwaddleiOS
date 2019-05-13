//
//  HeaderCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 5/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell, NibRegisterable {

    var title: String? {
        get { return headerView.label.text }
        set { headerView.label.text = newValue }
    }
    
    private lazy var headerView: ServiceHeaderView = ServiceHeaderView.viewFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(headerView)
        headerView.pinFrameToSuperViewBounds()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
