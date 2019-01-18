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
        
    }
        
    func configure(with pricePart: PricePart) {
        partDescriptionLabel.text = pricePart.localizedKey ?? pricePart.key
        partPriceLabel.text = currencyFormatter.string(from: pricePart.dollarValue)
    }
    
}

public extension PricePart {
    
    var dollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(value) / 100.0)
    }
    
}

public extension Price {
    
    var totalDollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(totalPrice) / 100.0)
    }
    
}
