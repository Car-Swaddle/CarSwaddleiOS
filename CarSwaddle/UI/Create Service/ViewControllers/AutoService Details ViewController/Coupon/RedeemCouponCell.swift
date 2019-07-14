//
//  RedeemCouponCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 7/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

private let successfullyRedeemedString = NSLocalizedString("Successfully redeemed coupon!", comment: "")
private let failedToRedeemString = NSLocalizedString("Invalid coupon code", comment: "")

final class RedeemCouponCell: UITableViewCell, NibRegisterable {
    
    enum CouponRedemptionState {
        case none
        case success
        case failure
    }

    var didTapRedeemCoupon: (_ code: String?) -> Void = { _ in }
    var didUpdateHeight: () -> Void = {}
    
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
        case .failure:
            couponRedemptionStateLabel.isHidden = false
            couponRedemptionStateLabel.textColor = .appRed
            couponRedemptionStateLabel.text = failedToRedeemString
        }
        
        didUpdateHeight()
    }
    
    
    @objc private func textFieldDidChange() {
        
    }
    
    @IBAction private func tapRedeem() {
        didTapRedeemCoupon(couponCodeTextField.text)
    }
    
}
