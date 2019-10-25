//
//  ShareCouponView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/16/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Store
import CoreData
import CarSwaddleUI

private let numberOfCoupons: Int = 3

class ShareCouponView: UIView, NibInstantiating {
    
    public var didTapShare: ( _ code: String) -> Void = { _ in }
    
    public func updateCoupons() {
        updateCouponsFromNetwork()
    }
    
    @IBOutlet private weak var explanationLabel: UILabel!
    @IBOutlet private weak var couponStackView: UIStackView!
    
    private var couponNetwork: CouponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    
    private var couponViews: [CouponView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        explanationLabel.font = .title
        
        updateViewForLocalCoupons()
        updateCouponsFromNetwork()
    }
    
    private func updateCouponsFromNetwork() {
        importCoupons { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateViewForLocalCoupons()
            }
        }
    }
    
    private func updateViewForLocalCoupons() {
        let coupons = Coupon.fetchCurrentUserShareableCoupons(fetchLimit: numberOfCoupons, in: store.mainContext)
        for (index, coupon) in coupons.enumerated() {
            let couponView = self.couponView(at: index)
            if couponView.superview == nil {
                couponStackView.addArrangedSubview(couponView)
            }
            couponView.configure(with: coupon)
        }
    }
    
    private func couponView(at index: Int) -> CouponView {
        if let couponView = couponViews.safeObject(at: index) {
            return couponView
        } else {
            let couponView = CouponView.viewFromNib()
            couponView.didTapShare = { coupon in
                self.didTapShare(coupon)
            }
            couponViews.append(couponView)
            return couponView
        }
    }
    
    
    private func importCoupons(completion: @escaping (_ error: Error?) -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.couponNetwork.getSharableCoupons(limit: 3, offset: 0, in: privateContext) { couponIDs, error in
                completion(error)
            }
        }
    }
    
}


public extension Coupon {
    
    static func fetchCurrentUserShareableCoupons(fetchLimit: Int, in context: NSManagedObjectContext) -> [Coupon] {
        let fetchRequest = Coupon.currentUserShareableCouponsFetchRequest(fetchLimit: fetchLimit)
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    static func currentUserShareableCouponsFetchRequest(fetchLimit: Int) -> NSFetchRequest<Coupon> {
        let fetchRequest: NSFetchRequest<Coupon> = Coupon.fetchRequest()
        fetchRequest.sortDescriptors = [Coupon.creationDate]
        fetchRequest.predicate = Coupon.predicateIsCurrentUserCreator() ?? NSPredicate(value: false)
        fetchRequest.fetchLimit = fetchLimit
        return fetchRequest
    }
    
    static func predicateIsCurrentUserCreator() -> NSPredicate? {
        guard let currentUserID = User.currentUserID else { return nil }
        return Coupon.predicateCreatedBy(userWithID: currentUserID)
    }
    
    static func predicateCreatedBy(userWithID creatorID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Coupon.createdByUserID), creatorID)
    }
    
    static var creationDate: NSSortDescriptor {
        return NSSortDescriptor(key: "creationDate", ascending: true)
    }
    
    
}
