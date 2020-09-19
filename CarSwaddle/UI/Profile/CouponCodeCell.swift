//
//  CouponCodeCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/17/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore

class CouponCodeCell: UITableViewCell, NibRegisterable {

    public func configure(with coupon: Coupon) {
        selectionStyle = coupon.canBeRedeemed ? .default : .none
        couponView.configure(with: coupon)
    }
    
    public func configureForNoCoupon() {
        couponView.configureForNoCoupon()
    }
    
    public var didSelectShare: (_ code: String) -> Void = { _ in }
    
    private lazy var couponView: CouponView = {
        let view = CouponView.viewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(couponView)
        
        couponView.pinFrameToSuperViewBounds()
        couponView.didTapShare = { [weak self] couponCode in
            self?.didSelectShare(couponCode)
        }
    }
    
}
