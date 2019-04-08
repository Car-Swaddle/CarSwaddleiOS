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
        
//        progressViewController.autoService = autoService
        
        paymentContext.hostViewController = pocketController
        
        self.pocketController = pocketController
    }
    
    private var priceNetwork: PriceNetwork = PriceNetwork(serviceRequest: serviceRequest)
    private var loadingPrice: Bool = false
    private let autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private lazy var paymentContext: STPPaymentContext = {
        let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: stripe))
        paymentContext.delegate = self
        return paymentContext
    }()
    
    private var price: Price? {
        didSet {
//            if let autoService = autoService {
//                priceView.configure(with: autoService)
//            }
            progressViewController.configure(with: autoService)
        }
    }
    
    private lazy var progressViewController: AutoServiceCreationProgressViewController = {
        let progressViewController = AutoServiceCreationProgressViewController.viewControllerFromStoryboard()
        progressViewController.delegate = self
        return progressViewController
    }()
    
    private lazy var selectLocationViewController: SelectLocationViewController = {
        let selectLocationViewController = SelectLocationViewController.create(delegate: self, autoService: autoService, location: nil)
        return selectLocationViewController
    }()
    
    private func updatePrice() {
        guard let mechanicID = autoService.mechanic?.identifier,
            let oilType = autoService.firstOilChange?.oilType,
            let coordinate = autoService.location?.coordinate else { return }
        loadingPrice = true
        store.privateContext { [weak self] privateContext in
            self?.priceNetwork.requestPrice(mechanicID: mechanicID, oilType: oilType, location: coordinate, in: privateContext) { priceObjectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let priceObjectID = priceObjectID,
                        let price = store.mainContext.object(with: priceObjectID) as? Price {
                        price.autoService = self.autoService
                        store.mainContext.persist()
                        self.price = price
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
        
        var summaryItems: [PKPaymentSummaryItem] = []
        
        for pricePart in price.parts {
            guard pricePart.isPartOfSubtotal == true else { continue }
            summaryItems.append(pricePart.paymentSummaryItem)
        }
        
        let amount = price.totalDollarValue
        let item = PKPaymentSummaryItem(label: "Car Swaddle", amount: amount)
        summaryItems.append(item)
        
        paymentContext.paymentSummaryItems = summaryItems
        paymentContext.requestPayment()
    }
    
}

extension AutoServiceCreation: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("context changed")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("failed to load: \(error)")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("create paymet result")
        print("paymentResult: \(paymentResult)")
        print("paymentContext: \(paymentContext)")
        let sourceID = paymentResult.source.stripeID
        createAutoService(sourceID: sourceID) { [weak self] autoServiceObjectID, error in
            if let error = error {
                completion(error)
            } else {
//                self?.dismiss(animated: true) {
//                    self?.dismiss(animated: true, completion: nil)
//                }
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
            print("error")
            if let error = error {
                print("\(error)")
            }
        case .success:
            print("success")
        case .userCancellation:
            print("user cancelled")
        @unknown default:
            fatalError("unkown case")
        }
    }
    
}

extension AutoServiceCreation: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        
        autoService.location = location
//        let selectMechanic = SelectMechanicViewController.create(with: location.coordinate)
//        selectMechanic.delegate = self
        
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
        UIView.animate(withDuration: 0.25) {
            self.pocketController?.view.layoutIfNeeded()
        }
//        pocketController?.view.layoutIfNeeded()
//        pocketController?.viewControllers.last?.view?.layoutIfNeeded()
    }
    
}

extension AutoServiceCreation: SelectMechanicDelegate {
    
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: UIViewController) {
        print("mechanic")
        
        progressViewController.currentState = .details
        
        autoService.mechanic = mechanic
        autoService.scheduledDate = date
        
        updatePrice()
        
        let detailsSelect = SelectAutoServiceDetailsViewController.viewControllerFromStoryboard()
        detailsSelect.delegate = self
        pocketController.show(detailsSelect, sender: self)
    }
    
    func willBeDismissed(viewController: UIViewController) {
        progressViewController.currentState = .location
    }
    
}

extension AutoServiceCreation: SelectAutoServiceDetailsViewControllerDelegate {
    
//    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
    
        
//        let selectOilType: SelectOilTypeViewController = SelectOilTypeViewController.create(with: autoService)
//        selectOilType.delegate = self
        
//        pocketController.show(selectOilType, sender: self)
//    }
    
    func didSelect(vehicle: Vehicle, oilType: OilType, viewController: SelectAutoServiceDetailsViewController) {
        print("didSelect")
        progressViewController.currentState = .payment
        self.autoService.vehicle = vehicle
        self.autoService.firstOilChange?.oilType = oilType
        
        payForAutoService()
    }
    
    func willBeDismissed(viewController: SelectAutoServiceDetailsViewController) {
        progressViewController.currentState = .mechanic
    }
    
//    func willBeDismissed(viewController: SelectVehicleViewController) {
//        progressViewController.currentState = .mechanic
//    }
    
}

extension AutoServiceCreation: SelectVehicleViewControllerDelegate {
    
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
        progressViewController.currentState = .payment
        
        let selectOilType: SelectOilTypeViewController = SelectOilTypeViewController.create(with: autoService)
        selectOilType.delegate = self
        
        pocketController.show(selectOilType, sender: self)
    }
    
    func didDeselectVehicle(viewController: SelectVehicleViewController) {
        
    }
    
    func willBeDismissed(viewController: SelectVehicleViewController) {
        progressViewController.currentState = .mechanic
    }
    
}

extension AutoServiceCreation: SelectOilTypeViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController) {
        print("oil type")
        // show price
    }
    
    func willBeDismissed(viewController: SelectOilTypeViewController) {
        progressViewController.currentState = .details
    }
    
}
