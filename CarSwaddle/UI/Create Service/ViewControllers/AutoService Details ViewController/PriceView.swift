//
//  PriceView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 4/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Store

final class PriceView: UIView, NibInstantiating {
    
    @IBOutlet private weak var priceStackView: UIStackView!
//    @IBOutlet private weak var totalPriceStackView: UIStackView!
//    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with service: AutoService) {
        for arrangedSubview in priceStackView.arrangedSubviews {
            priceStackView.removeArrangedSubview(arrangedSubview)
        }
        
//        let subtotals = (service.price?.parts ?? []).sorted { lp, rp -> Bool in
//            if lp.isPartOfSubtotal != rp.isPartOfSubtotal {
//                return lp.isPartOfSubtotal && !rp.isPartOfSubtotal
//            } else if lp.isPartOfSubtotal {
//                return true
//            } else {
//                return false
//            }
//        }
        
        let sortedPriceParts = service.price?.parts ?? []
        
        var nonSubtotalIndex = 0
        for pricePart in sortedPriceParts {
            if pricePart.isPartOfSubtotal == false {
                let pricePartView = PricePartView.viewFromNib()
                pricePartView.configure(with: pricePart)
                priceStackView.insertArrangedSubview(pricePartView, at: nonSubtotalIndex)
                nonSubtotalIndex += 1
            }
        }
        
        let separatorView1 = self.separatorView()
        priceStackView.addArrangedSubview(separatorView1)
        nonSubtotalIndex += 1
        
        var subtotalIndex = 0
        for pricePart in sortedPriceParts {
            if pricePart.isPartOfSubtotal == true {
                let pricePartView = PricePartView.viewFromNib()
                pricePartView.configure(with: pricePart)
                priceStackView.insertArrangedSubview(pricePartView, at: subtotalIndex+nonSubtotalIndex)
                subtotalIndex += 1
            }
        }
        
        let separatorView2 = self.separatorView()
        priceStackView.addArrangedSubview(separatorView2)
        nonSubtotalIndex += 1
        
        if let price = service.price {
//            totalPriceLabel.text = currencyFormatter.string(from: price.totalDollarValue)
            let pricePartView = PricePartView.viewFromNib()
            pricePartView.configure(with: price)
            priceStackView.addArrangedSubview(pricePartView)
        } else {
//            totalPriceLabel.text = nil
        }
    }
    
    private func separatorView() -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: UIView.hairlineLength).isActive = true
        view.backgroundColor = .gray3
        return view
    }
    
}
