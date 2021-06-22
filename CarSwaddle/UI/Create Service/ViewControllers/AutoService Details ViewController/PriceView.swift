//
//  PriceView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 4/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleStore


//private let Label = NSLocalizedString("Labor", comment: "Price part key")
private let oilFilterLabel = NSLocalizedString("Oil filter", comment: "Price part key")
private let travelLabel = NSLocalizedString("Travel", comment: "Price part key")
//private let Label = NSLocalizedString("Oil", comment: "Price part key")
private let subtotalLabel = NSLocalizedString("Subtotal", comment: "Price part key")
private let bookingFeeLabel = NSLocalizedString("Booking fee", comment: "Price part key")
private let processingFeeLabel = NSLocalizedString("Processing fee", comment: "Price part key")
//private let Label = NSLocalizedString("Oil change high mileage", comment: "Price part key")
private let oilChangeLabel = NSLocalizedString("Oil change", comment: "Price part key")
private let feeLabel = NSLocalizedString("Fees", comment: "Price part key")
private let feesAndTaxesLabel = NSLocalizedString("Fees and tax", comment: "Price part key")
private let discountLabel = NSLocalizedString("Coupon", comment: "Price part key")
//private let bookingFeeDiscountLabel = NSLocalizedString("Booking fee discount", comment: "Price part key")
//private let Label = NSLocalizedString("Synthetic oil change", comment: "Price part key")
//private let Label = NSLocalizedString("Conventional oil change", comment: "Price part key")
//private let Label = NSLocalizedString("Blend oil change", comment: "Price part key")

final class PriceView: UIView, NibInstantiating {
    
    @IBOutlet private weak var priceStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
    }
    
    func configure(with service: AutoService) {
        for arrangedSubview in priceStackView.arrangedSubviews {
            priceStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        guard let price = service.price else { return }
        
//        addPricePartView(label: oilChangeLabel, cents: price.oilChangeCost)
//        addPricePartView(label: travelLabel, cents: price.distanceCost)
//        addSeparatorView()
//        addPricePartView(label: subtotalLabel, cents: price.subtotal)
//        addPricePartView(label: processingFeeLabel, cents: price.processingFee + price.bookingFee)
        
        addPricePartView(label: oilChangeLabel, cents: price.subtotal)
//        addPricePartView(label: feeLabel, cents: price.fees)
        addPricePartView(label: feesAndTaxesLabel, cents: price.feesAndTaxes)
        
        if let discount = price.totalDiscount, discount != 0 {
            addPricePartView(label: discountLabel, cents: discount)
        }
        addSeparatorView()
        
        let pricePartView = PricePartView.viewFromNib()
        pricePartView.configure(with: price)
        priceStackView.addArrangedSubview(pricePartView)
    }
    
    private func separatorView() -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: UIView.hairlineLength).isActive = true
        view.backgroundColor = .opaqueSeparator
        return view
    }
    
    private func addSeparatorView() {
        priceStackView.addArrangedSubview(separatorView())
    }
    
    private func addPricePartView(label: String, cents: Int) {
        let pricePartView = PricePartView.viewFromNib()
        pricePartView.configure(label: label, numberOfCents: cents)
        priceStackView.addArrangedSubview(pricePartView)
    }
    
}


extension Price {
    
    var totalDiscount: Int? {
        guard couponDiscount != nil || bookingFeeDiscount != nil else { return nil }
        
        var discount = 0
        
        
        if let couponDiscount = couponDiscount {
            discount += couponDiscount
        }
        
        if let bookingFeeDiscount = bookingFeeDiscount {
            discount += bookingFeeDiscount
        }
        
        return discount
    }
    
}

extension Price {
    
    var subtotalAndFees: Int {
        return subtotal + processingFee + bookingFee
    }
    
    var fees: Int {
        return processingFee + bookingFee
    }
    
}
