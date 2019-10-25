//
//  CouponView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/16/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI


public let blankText = NSLocalizedString("--", comment: "")

let percentFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.minimumFractionDigits = 1
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.minimumIntegerDigits = 1
    
    return numberFormatter
}()

class CouponView: UIView, NibInstantiating {
    
    public var didTapShare: (_ code: String) -> Void = { _ in }
    
    public func configure(with coupon: Coupon) {
        self.coupon = coupon
        
        couponCodeLabel.text = coupon.identifier
        couponDetailsLabel.text = couponDetailsText(for: coupon)
        alpha = alpha(for: coupon)
        sharebutton.isEnabled = coupon.canBeRedeemed
    }
    
    public func configureForNoCoupon() {
        self.coupon = nil
        
        couponCodeLabel.text = blankText
        couponDetailsLabel.text = blankText
        alpha = 1.0
        sharebutton.isEnabled = true
    }
    
    private func alpha(for coupon: Coupon) -> CGFloat {
        if coupon.canBeRedeemed {
            return 1.0
        } else {
            return 0.4
        }
    }
    
    private func couponDetailsText(for coupon: Coupon) -> String? {
        return coupon.appliedReduction?.localizedString
    }
    
    private var coupon: Coupon?
    
    @IBOutlet private weak var couponCodeLabel: UILabel!
    @IBOutlet private weak var sharebutton: UIButton!
    @IBOutlet private weak var couponDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        couponCodeLabel.titleStyled()
        couponDetailsLabel.detailStyled()
        sharebutton.setTitleColor(.selectionColor, for: .normal)
        sharebutton.titleLabel?.font = .action
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        couponCodeLabel.addGestureRecognizer(tap)
        couponCodeLabel.isUserInteractionEnabled = true
    }
    
    @objc private func didTapLabel() {
        let menu = UIMenuController.shared
        menu.setTargetRect(couponCodeLabel.frame, in: self)
        menu.setMenuVisible(true, animated: true)
    }
    
    @IBAction private func didTapShareButton() {
        guard let coupon = coupon else {
            assert(false, "Did not have coupon when tapped")
            return
        }
        didTapShare(coupon.identifier)
    }
    
    
}




extension Coupon {
    
    
    public enum AppliedReduction {
        case amountOff(cents: Int)
        case percentOff(percent: CGFloat)
        
        var localizedString: String? {
            switch self {
            case .amountOff(let cents):
                let formatString = NSLocalizedString("$%@ off", comment: "")
                guard let currency = currencyFormatter.string(from: NSNumber(value: cents)) else {
                    assert(false, "Should have a value here")
                    return nil
                }
                return String(format: formatString, currency)
            case .percentOff(let percent):
                let formatString = NSLocalizedString("%.1f%% off", comment: "")
                return String(format: formatString, (percent * 100.0))
            }
        }
        
    }
    
    public var appliedReduction: AppliedReduction? {
        if let amountOff = amountOff, amountOff > 0 {
            return AppliedReduction.amountOff(cents: amountOff)
        } else if let percentOff = percentOff, percentOff > 0 {
            return AppliedReduction.percentOff(percent: percentOff)
        }
        return nil
    }
    
    
    public var canBeRedeemed: Bool {
        return isRedemptionAvailable && !isExpired
    }
    
    public var numberOfAvailableRedemptions: Int? {
        guard let maxRedemptions = maxRedemptions else { return nil }
        return maxRedemptions - redemptions
    }
    
    public var isRedemptionAvailable: Bool {
        guard let numberOfAvailableRedemptions = numberOfAvailableRedemptions else { return true }
        return numberOfAvailableRedemptions > 0
    }
    
    public var isExpired: Bool {
        return redeemBy < Date()
    }
    
}


public extension CGFloat {
    
    var nsNumber: NSNumber {
        return NSNumber(value: Float(self))
    }
    
}
