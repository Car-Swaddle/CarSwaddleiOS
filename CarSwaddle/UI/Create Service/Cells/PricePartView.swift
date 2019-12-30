//
//  PricePartView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 12/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI


final class PricePartView: UIView, NibInstantiating {
    
    @IBOutlet private weak var partDescriptionLabel: UILabel!
    @IBOutlet private weak var partPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        partDescriptionLabel.font = UIFont.appFont(type: .regular, size: 15, scaleFont: false)
        partPriceLabel.font = UIFont.appFont(type: .semiBold, size: 17, scaleFont: false)
        backgroundColor = .clear
    }
    
    func configure(label: String, numberOfCents: Int) {
        partDescriptionLabel.text = label
        partPriceLabel.text = currencyFormatter.string(from: numberOfCents.centsToDollars)
    }
    
    func configure(with price: Price) {
        partDescriptionLabel.text = NSLocalizedString("Total", comment: "total price")
        partPriceLabel.text = currencyFormatterWithDollarSign.string(from: price.totalDollarValue)
    }
    
}


public extension Price {
    
    var totalDollarValue: NSDecimalNumber {
        return total.centsToDollars
    }
    
}

public extension Int {
    
    var centsToDollars: NSDecimalNumber {
        return NSDecimalNumber(value: Float(self) / 100.0)
    }
    
}
