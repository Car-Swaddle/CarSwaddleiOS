//
//  RedeemCouponCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 7/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleNetworkRequest

private let successfullyRedeemedString = NSLocalizedString("Successfully redeemed coupon!", comment: "")
private let incorrectErrorMessage = NSLocalizedString("This coupon code is invalid", comment: "")
private let expiredErrorMessage = NSLocalizedString("This coupon code is expired", comment: "")
private let depletedRedemptionsErrorMessage = NSLocalizedString("This coupon code has already been redeemed", comment: "")
private let incorrectMechanicErrorMessage = NSLocalizedString("This coupon code is only valid for another mechanic", comment: "")
private let failedToRedeemString = NSLocalizedString("This coupon code is invalid", comment: "")

final class RedeemCouponCell: UITableViewCell, NibRegisterable {
    
    enum CouponRedemptionState {
        case none
        case success
        case failure(priceError: PriceError?)
    }

    var didTapRedeemCoupon: (_ code: String?) -> Void = { _ in }
    var didUpdateHeight: () -> Void = {}
//    var didSelectReturn: () -> Void = {}
    
    var isRedeemingCoupon: Bool = false {
        didSet {
            updateUIForIsRedeeming()
        }
    }
    
    var couponRedemptionState: CouponRedemptionState = .none {
        didSet {
            updateUIForCurrentCouponRedemptionState()
        }
    }
    
    private func updateUIForIsRedeeming() {
        if isRedeemingCoupon {
            redeemCouponButton.isHidden = true
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false
            couponCodeTextField.isEnabled = false
        } else {
            redeemCouponButton.isHidden = false
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
            couponCodeTextField.isEnabled = true
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var couponCodeTextField: UITextField!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var redeemCouponButton: UIButton!
    @IBOutlet private weak var couponRedemptionStateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        couponCodeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
        updateUIForIsRedeeming()
        updateUIForCurrentCouponRedemptionState()
        
        selectionStyle = .none
        
        titleLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        couponCodeTextField.font = UIFont.appFont(type: .regular, size: 17)
        couponRedemptionStateLabel.font = UIFont.appFont(type: .regular, size: 15)
        
        couponCodeTextField.delegate = self
    }
    
    private func updateUIForCurrentCouponRedemptionState() {
        switch couponRedemptionState {
        case .none:
            couponRedemptionStateLabel.isHidden = true
            couponRedemptionStateLabel.textColor = .black
            couponRedemptionStateLabel.text = nil
        case .success:
            couponRedemptionStateLabel.isHidden = false
            couponRedemptionStateLabel.textColor = .appGreen
            couponRedemptionStateLabel.text = successfullyRedeemedString
        case .failure(let priceError):
            couponRedemptionStateLabel.isHidden = false
            couponRedemptionStateLabel.textColor = .appRed
            couponRedemptionStateLabel.text = priceError?.localizableString ?? failedToRedeemString
        }
        
        didUpdateHeight()
    }
    
    
    @objc private func textFieldDidChange() {
        
    }
    
    @IBAction private func tapRedeem() {
        didTapRedeemCoupon(couponCodeTextField.text)
    }
    
}


extension RedeemCouponCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapRedeemCoupon(textField.text)
        textField.resignFirstResponder()
        return true
    }
    
}


extension PriceError {
    
    var localizableString: String {
        switch self {
        case .couponCodeNotFound:
            return failedToRedeemString
        case .depletedRedemptions:
            return depletedRedemptionsErrorMessage
        case .expired:
            return expiredErrorMessage
        case .invalidCouponCode:
            return incorrectErrorMessage
        case .invalidMechanic:
            return incorrectMechanicErrorMessage
        }
    }
    
}

