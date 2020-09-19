//
//  CreateServiceViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleStore
import CoreData
import CarSwaddleData
import Stripe

extension CreateServiceViewController {
    
    enum Row: CaseIterable {
        case location
        case mechanic
        case vehicle
        case oilType
        case price
    }
    
}


@available(*, deprecated, message: "Old ViewController")
final class CreateServiceViewController: UIViewController, StoryboardInstantiating {
    
    private let autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    private let priceNetwork: PriceNetwork = PriceNetwork(serviceRequest: serviceRequest)
    
    private lazy var paymentContext: STPPaymentContext = {
        let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: stripe))
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        return paymentContext
    }()
    
    static func create(autoServiceID: String?) -> CreateServiceViewController {
        let viewController = CreateServiceViewController.viewControllerFromStoryboard()
        viewController.autoServiceID = autoServiceID
        return viewController
    }
    
    private var autoServiceID: String? {
        didSet {
            fulfillAutoService()
            updatePrice()
        }
    }
    
    private var autoService: AutoService!
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var rows: [Row] = Row.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func fulfillAutoService() {
        guard autoService == nil else { return }
        if let identifier = autoServiceID {
            guard let fetchedService  = AutoService.fetch(with: identifier, in: store.mainContext) else { return }
            autoService = fetchedService
        } else {
            let context = store.mainContext
            let newAutoService = AutoService.createWithDefaults(context: context)
            context.persist()
            autoService = newAutoService
        }
    }
    
    private func getVehicle()  -> Vehicle? {
        let recentlyUsedAutoService = AutoService.fetchMostRecentlyUsed(forUserID: User.currentUserID!, in: store.mainContext)?.vehicle
        let firstVehicle = Vehicle.fetchFirstVehicle(forUserID: User.currentUserID!, in: store.mainContext)
        return  recentlyUsedAutoService ?? firstVehicle
    }
    
    private func setupTableView() {
        tableView.register(CreateServiceLocationCell.self)
        tableView.register(CreateServiceMechanicCell.self)
        tableView.register(CreateServiceVehicleCell.self)
        tableView.register(CreateServicePriceCell.self)
        tableView.register(CreateServiceOilTypeCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func didTapCancel() {
        store.mainContext.delete(autoService)
        store.mainContext.persist()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapRequest() {
        guard autoService.canConvertToJSON,
            let price = autoService.price else { return }
        
        var summaryItems: [PKPaymentSummaryItem] = []
        
//        for pricePart in price.parts {
//            guard pricePart.isPartOfSubtotal == true else { continue }
//            summaryItems.append(pricePart.paymentSummaryItem)
//        }
        
        let amount = price.totalDollarValue
        let item = PKPaymentSummaryItem(label: "Car Swaddle", amount: amount)
        summaryItems.append(item)
        
        paymentContext.paymentSummaryItems = summaryItems
        paymentContext.requestPayment()
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
    
    private var loadingPrice: Bool = false
    
    private func updatePrice() {
        guard let mechanicID = autoService.mechanic?.identifier,
            let oilType = autoService.firstOilChange?.oilType,
            let location = autoService.location else { return }
        
        let coordinate = location.coordinate
        loadingPrice = true
        store.privateContext { [weak self] privateContext in
            self?.priceNetwork.requestPrice(mechanicID: mechanicID, oilType: oilType, location: coordinate, couponCode: nil, in: privateContext) { priceObjectID, error in
                DispatchQueue.main.async {
                    guard let _self = self else { return }
                    if let priceObjectID = priceObjectID,
                        let price = store.mainContext.object(with: priceObjectID) as? Price {
                        price.autoService = _self.autoService
                        store.mainContext.persist()
                    }
                    _self.loadingPrice = false
                    _self.tableView.reloadRows(at: [_self.indexPath(from: .price)], with: .none)
                }
            }
        }
    }
    
}

extension CreateServiceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.row(from: indexPath)
        let cell = self.cell(with: row)
        
        cell.configure(with: autoService)
        return cell
    }
    
    private func indexPath(from row: Row) -> IndexPath {
        guard let indexRow = rows.firstIndex(of: row) else { fatalError("Should have \(row) in rows") }
        return IndexPath(row: indexRow, section: 0)
    }
    
    private func row(from indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    private func cell(with row: Row) -> CreateServiceCell {
        switch row {
        case .location:
            let cell: CreateServiceLocationCell = tableView.dequeueCell()
            return cell
        case .mechanic:
            let cell: CreateServiceMechanicCell = tableView.dequeueCell()
            return cell
        case .vehicle:
            let cell: CreateServiceVehicleCell = tableView.dequeueCell()
            return cell
        case .oilType:
            let cell: CreateServiceOilTypeCell = tableView.dequeueCell()
            return cell
        case .price:
            let cell: CreateServicePriceCell = tableView.dequeueCell()
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 72
//    }
    
}

extension CreateServiceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.row(from: indexPath)
        switch row {
        case .location:
            let viewController = SelectLocationViewController.create(delegate: self, autoService: autoService)
            navigationController?.show(viewController, sender: self)
        case .mechanic:
            let viewController = SelectMechanicViewController.create(with: autoService.location!.coordinate)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .vehicle:
            let viewController = SelectVehicleViewController.create(autoService: autoService)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .oilType:
            let viewController = SelectOilTypeViewController.create(with: autoService)
            viewController.delegate = self
            navigationController?.show(viewController, sender: self)
        case .price:
            break
        }
    }
    
}

extension CreateServiceViewController: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        self.autoService.location = location
        store.mainContext.persist()
        navigationController?.popViewController(animated: true)
        updatePrice()
    }
    
    func willBeDismissed(viewController: SelectLocationViewController) {
        
    }
    
}

extension CreateServiceViewController: SelectMechanicDelegate {
    
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: UIViewController) {
        self.autoService.mechanic = mechanic
        autoService.scheduledDate = date
        store.mainContext.persist()
        navigationController?.popViewController(animated: true)
        updatePrice()
    }
    
    func willBeDismissed(viewController: UIViewController) {
        
    }
    
}

extension CreateServiceViewController: SelectOilTypeViewControllerDelegate {
    
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController) {
        autoService.firstOilChange?.oilType = oilType
        store.mainContext.persist()
        let indexPath = IndexPath(row: rows.firstIndex(of: .oilType) ?? 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
        navigationController?.popViewController(animated: true)
        updatePrice()
    }
    
    func willBeDismissed(viewController: SelectOilTypeViewController) {
        
    }
    
}

extension CreateServiceViewController: SelectVehicleViewControllerDelegate {
    
    func didSelectVehicle(vehicle: Vehicle, viewController: SelectVehicleViewController) {
        autoService.vehicle = vehicle
        store.mainContext.persist()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
        updatePrice()
    }
    
    func didDeselectVehicle(viewController: SelectVehicleViewController) {
        autoService.vehicle = nil
        store.mainContext.persist()
        tableView.reloadData()
        updatePrice()
    }
 
    func willBeDismissed(viewController: SelectVehicleViewController) {
        
    }
    
}

extension CreateServiceViewController: STPPaymentContextDelegate {
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
//        <#code#>
//    }
//
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("context changed")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("failed to load: \(error)")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        guard let sourceID = paymentResult.paymentMethod?.stripeId else { return }
        print("create paymet result")
        print("paymentResult: \(paymentResult)")
        print("paymentContext: \(paymentContext)")
        createAutoService(sourceID: sourceID) { [weak self] autoServiceObjectID, error in
            if let error = error {
                completion(.error, error)
            } else {
                self?.dismiss(animated: true) {
                    self?.dismiss(animated: true, completion: nil)
                }
                completion(.success, nil)
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


//extension PricePart {
//
//    var paymentSummaryItem: PKPaymentSummaryItem {
//        return PKPaymentSummaryItem(pricePart: self)
//    }
//
//}
//
//extension PKPaymentSummaryItem {
//
//    convenience init(pricePart: PricePart) {
//        self.init(label: pricePart.key, amount: pricePart.dollarValue)
//    }
//
//}
