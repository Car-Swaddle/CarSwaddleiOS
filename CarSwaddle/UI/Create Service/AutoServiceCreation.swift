//
//  AutoServiceCreation.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store
import CarSwaddleData
import Stripe
import CoreData
import Firebase

private let errorWithPaymentTitle = NSLocalizedString("Car Swaddle was unable to process your payment", comment: "")
private let errorWithPaymentMessage = NSLocalizedString("Please try again with another payment method", comment: "")

final class AutoServiceCreation: NSObject {
    
    public var pocketController: PocketController!
    
    private var autoService: AutoService
    
    override init() {
        assert(Thread.isMainThread, "Must be on main")
        
        self.autoService = AutoService.createWithDefaults(context: store.mainContext)
        store.mainContext.persist()
        
        super.init()
        
        let pocketController = PocketController(rootViewController: selectLocationViewController, bottomViewController: progressViewController)
        pocketController.view.backgroundColor = UIColor(red255: 249, green255: 245, blue255: 237)
        pocketController.bottomViewControllerHeight = 120
        
        paymentContext.hostViewController = pocketController
        
        self.pocketController = pocketController
    }
    
    private var priceNetwork: PriceNetwork = PriceNetwork(serviceRequest: serviceRequest)
    private var loadingPrice: Bool = false
    private let autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private weak var payViewController: SelectAutoServiceDetailsViewController?
    
    private lazy var paymentContext: STPPaymentContext = {
        let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: stripe))
        paymentContext.delegate = self
        return paymentContext
    }()
    
    private var price: Price? {
        didSet {
            progressViewController.configure(with: autoService)
        }
    }
    
    private lazy var progressViewController: AutoServiceCreationProgressViewController = {
        let progressViewController = AutoServiceCreationProgressViewController.viewControllerFromStoryboard()
        progressViewController.delegate = self
        return progressViewController
    }()
    
    private lazy var selectLocationViewController: SelectLocationViewController = {
        let selectLocationViewController = SelectLocationViewController.create(delegate: self, autoService: autoService)
        return selectLocationViewController
    }()
    
    private func updatePrice(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        guard let mechanicID = autoService.mechanic?.identifier,
            let oilType = autoService.firstOilChange?.oilType,
            let coordinate = autoService.location?.coordinate else { return }
        loadingPrice = true
        
//        let couponCode = payViewController?.couponCode
        let couponCode = autoService.couponID
        
        payViewController?.isUpdatingPrice = true
        
        store.privateContext { [weak self] privateContext in
            self?.priceNetwork.requestPrice(mechanicID: mechanicID, oilType: oilType, location: coordinate, couponCode: couponCode, in: privateContext) { priceObjectID, error in
                DispatchQueue.main.async {
                    defer {
                        completion(error)
                        self?.payViewController?.isUpdatingPrice = false
                        self?.payViewController?.isRedeemingCoupon = false
                    }
                    guard let self = self else { return }
                    if let priceObjectID = priceObjectID,
                        let price = store.mainContext.object(with: priceObjectID) as? Price {
                        price.autoService = self.autoService
                        store.mainContext.persist()
                        self.price = price
                        
                        let couponState: RedeemCouponCell.CouponRedemptionState
                        if couponCode == nil || couponCode?.isEmpty == true {
                            couponState = .none
                        } else {
                            if price.couponDiscount != nil || price.bookingFeeDiscount != nil {
                                couponState = .success
                            } else {
                                couponState = .failure
                            }
                        }
                        self.payViewController?.couponRedemptionState = couponState
                        
                    } else {
                        self.payViewController?.couponRedemptionState = .none
                    }
                    self.loadingPrice = false
                }
            }
        }
    }
    
    private func createAutoService(sourceID: String, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) {
        autoService.managedObjectContext?.persist()
        let objectID = autoService.objectID
        store.privateContext { [weak self] context in
            guard let privateAutoService = context.object(with: objectID) as? AutoService else { return }
            self?.autoServiceNetwork.createAutoService(autoService: privateAutoService, sourceID: sourceID, in: context) { newAutoService, error in
                DispatchQueue.main.async {
                    completion(newAutoService, error)
                }
            }
        }
    }
    
    private func payForAutoService() {
        guard autoService.canConvertToJSON,
            let price = autoService.price else { return }
        
        paymentContext.paymentSummaryItems = price.summaryItems
        paymentContext.requestPayment()
//        paymentContext.presentPaymentOptionsViewController()
        
        Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [
            AnalyticsParameterPrice: price.totalDollarValue,
            AnalyticsParameterStartDate: autoService.scheduledDate ?? Date(),
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterContentType: "oilChange",
            AnalyticsParameterCheckoutOption: "requestPayment"
        ])
    }
    
}

extension AutoServiceCreation: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("context changed")
        payViewController?.isUpdatingPrice = paymentContext.loading
        payViewController?.didUpdatePaymentContext()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("failed to load: \(error)")
        Analytics.logEvent(AnalyticsEventCheckoutProgress, parameters: [
            AnalyticsParameterCheckoutOption: "failedPayment"
        ])
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("create paymet result")
        print("paymentResult: \(paymentResult)")
        print("paymentContext: \(paymentContext)")
        let sourceID = paymentResult.source.stripeID
        payViewController?.isUpdatingPrice = true
        createAutoService(sourceID: sourceID) { [weak self] autoServiceObjectID, error in
            self?.payViewController?.isUpdatingPrice = false
            if let error = error {
                completion(error)
            } else {
                self?.pocketController.dismiss(animated: true) {
                    self?.pocketController.dismiss(animated: true, completion: nil)
                }
                completion(nil)
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("finished UI")
        
        switch status {
        case .error:
            print("error: \(String(describing: error))")
            let alert = errorAlertController(title: errorWithPaymentTitle, message: errorWithPaymentMessage)
            paymentContext.hostViewController?.present(alert, animated: true, completion: nil)
            var params: [String: Any] = [AnalyticsParameterCheckoutOption: "systemErrorPayment"]
            if let error = error {
                print("\(error)")
                params["errorMessage"] = error.localizedDescription
            }
            Analytics.logEvent(AnalyticsEventCheckoutProgress, parameters: params)
        case .success:
            print("success")
            Analytics.logEvent(AnalyticsEventCheckoutProgress, parameters: [
                AnalyticsParameterCheckoutOption: "successfullyPaid"
            ])
        case .userCancellation:
            print("user cancelled")
            Analytics.logEvent(AnalyticsEventCheckoutProgress, parameters: [
                AnalyticsParameterCheckoutOption: "userCanceledPayment"
            ])
        @unknown default:
            fatalError("unkown case")
        }
    }
    
    private func errorAlertController(title: String, message: String) -> CustomAlertController {
        let alert = CustomAlertContentView.view(withTitle: title, message: message)
        alert.addOkayAction()
        return CustomAlertController.viewController(contentView: alert)
    }
    
}

extension AutoServiceCreation: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        autoService.location = location
        progressViewController.currentState = .mechanic
        
        let selectMechanic = SelectMechanicTableViewController.create(with: location.coordinate)
        selectMechanic.delegate = self
        pocketController.show(selectMechanic, sender: self)
    }
    
    func willBeDismissed(viewController: SelectLocationViewController) {
        
    }
    
}

extension AutoServiceCreation: AutoServiceCreationProgressDelegate {
    
    func updateHeight(newHeight: CGFloat) {
        self.pocketController?.bottomViewControllerHeight = newHeight + pocketController.safeAreaInsetsMinusAdditional.bottom
//        UIView.animate(withDuration: 0.25) {
//            self.pocketController?.view.layoutIfNeeded()
//        }
    }
    
}

extension AutoServiceCreation: SelectMechanicDelegate {
    
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: UIViewController) {
        print("mechanic")
        
        progressViewController.currentState = .details
        
        autoService.mechanic = mechanic
        autoService.scheduledDate = date
        autoService.firstOilChange?.oilType = .conventional
        
        updatePrice()
        
        let detailsSelect = SelectAutoServiceDetailsViewController.viewControllerFromStoryboard()
        detailsSelect.delegate = self
        detailsSelect.isUpdatingPrice = true
        detailsSelect.paymentContext = paymentContext
        payViewController = detailsSelect
        pocketController.show(detailsSelect, sender: self)
    }
    
    func willBeDismissed(viewController: UIViewController) {
        progressViewController.currentState = .location
    }
    
}

extension AutoServiceCreation: SelectAutoServiceDetailsViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectAutoServiceDetailsViewController) {
        autoService.firstOilChange?.oilType = oilType
        autoService.managedObjectContext?.persist()
        updatePrice()
    }
    
    func didSelect(vehicle: Vehicle, oilType: OilType, viewController: SelectAutoServiceDetailsViewController) {
        print("didSelect")
        progressViewController.currentState = .payment
        self.autoService.vehicle = vehicle
        self.autoService.firstOilChange?.oilType = oilType
        autoService.managedObjectContext?.persist()
        
        payForAutoService()
    }
    
    func willBeDismissed(viewController: SelectAutoServiceDetailsViewController) {
        progressViewController.currentState = .mechanic
    }
    
    func didSetCouponCode(couponCode: String?, viewController: SelectAutoServiceDetailsViewController) {
        autoService.couponID = couponCode
        autoService.managedObjectContext?.persist()
        payViewController?.isRedeemingCoupon = true
        updatePrice()
    }
    
}



extension Price {
    
    var summaryItems: [PKPaymentSummaryItem] {
        var items: [PKPaymentSummaryItem] = []
        
//        {
//            "oilChange": 5600,
//            "distance": 196,
//            "bookingFee": 580,
//            "processingFee": 226,
//            "subtotal": 5796,
//            "taxes": 471,
//            "total": 7073,
//            "id": "b75f2150-9ef2-11e9-9729-e1444a210d28"
//        }
        
        items.append(PKPaymentSummaryItem(label: NSLocalizedString("Subtotal", comment: "Line item of subtotal"), amount: subtotal.centsToDollars))
        items.append(PKPaymentSummaryItem(label: NSLocalizedString("Sales tax", comment: "Line item of sales tax"), amount: taxes.centsToDollars))
        items.append(PKPaymentSummaryItem(label: NSLocalizedString("Booking fees", comment: "Line item of booking and processing fees"), amount: (bookingFee + processingFee).centsToDollars))
        
        let amount = totalDollarValue
        let item = PKPaymentSummaryItem(label: "Car Swaddle, Inc.", amount: amount)
        items.append(item)
        
        return items
    }
    
}


extension Int {
    
    var decimalNumber: NSDecimalNumber {
        return NSDecimalNumber(integerLiteral: self)
    }
    
}


