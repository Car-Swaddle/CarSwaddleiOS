//
//  PaymentMethodCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 7/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Stripe
import CarSwaddleUI


private let noPaymentMethoSelected = NSLocalizedString("Select Payment Method", comment: "Select how to pay for auto service")

class PaymentMethodCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    @IBOutlet weak var paymentMethodImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        paymentMethodLabel.font = UIFont.appFont(type: .regular, size: 17)
        paymentMethodLabel.text = noPaymentMethoSelected
        paymentMethodImageView.tintColor = .gray4
    }
    
    func configure(with paymentMethod: STPPaymentOption?) {
        if let paymentMethod = paymentMethod {
            paymentMethodLabel.text = paymentMethod.label
            paymentMethodImageView.image = paymentMethod.templateImage
        } else {
            paymentMethodLabel.text = noPaymentMethoSelected
            paymentMethodLabel.text = noPaymentMethoSelected
            paymentMethodImageView.image = nil
        }
    }
    
}
