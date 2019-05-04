//
//  ServiceHeaderView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 5/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

private let heightProxyView: ServiceHeaderView = ServiceHeaderView.viewFromNib()

final class ServiceHeaderView: UIView, NibInstantiating {
    
    static func height(for string: String, width: CGFloat) -> CGFloat {
        heightProxyView.label.text = string
        let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = heightProxyView.systemLayoutSizeFitting(size).height
        return height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ServicesViewController.tableBackgroundColor
    }
    
    @IBOutlet weak var label: UILabel!
}
