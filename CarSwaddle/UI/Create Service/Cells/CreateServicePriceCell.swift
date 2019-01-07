//
//  CreateServiceLocationCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

class CreateServicePriceCell: UITableViewCell, NibRegisterable, AutoServiceConfigurable {

    @IBOutlet private weak var priceStackView: UIStackView!
    @IBOutlet private weak var totalPriceStackView: UIStackView!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(with service: AutoService) {
        for arrangedSubview in priceStackView.arrangedSubviews {
            if arrangedSubview != totalPriceStackView {
                priceStackView.removeArrangedSubview(arrangedSubview)
            }
        }
        
        var nonSubtotalIndex = 0
        for pricePart in service.price?.parts ?? [] {
            if pricePart.isPartOfSubtotal == false {
                let pricePartView = PricePartView.viewFromNib()
                pricePartView.configure(with: pricePart)
                priceStackView.insertArrangedSubview(pricePartView, at: nonSubtotalIndex)
                nonSubtotalIndex += 1
            }
        }
        
        var subtotalIndex = 0
        for pricePart in service.price?.parts ?? [] {
            if pricePart.isPartOfSubtotal == true {
                let pricePartView = PricePartView.viewFromNib()
                pricePartView.configure(with: pricePart)
                priceStackView.insertArrangedSubview(pricePartView, at: subtotalIndex+nonSubtotalIndex)
                subtotalIndex += 1
            }
        }
        
        if let price = service.price {
            totalPriceLabel.text = currencyFormatter.string(from: price.totalDollarValue)
        } else {
            totalPriceLabel.text = nil
        }
    }
    
}
