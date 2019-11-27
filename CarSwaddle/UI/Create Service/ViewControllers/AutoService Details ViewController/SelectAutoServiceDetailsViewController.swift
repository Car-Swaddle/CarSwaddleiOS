//
//  SelectAutoServiceDetailsViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store
import Stripe
import Firebase
import SafariServices

private let oilTypesURL = URL(string: "https://carswaddle.com/oil-types/")!

protocol SelectAutoServiceDetailsViewControllerDelegate: class {
    func didSelect(vehicle: Vehicle, oilType: OilType, viewController: SelectAutoServiceDetailsViewController)
    func didChangeOilType(oilType: OilType, viewController: SelectAutoServiceDetailsViewController)
    func willBeDismissed(viewController: SelectAutoServiceDetailsViewController)
    func didSetCouponCode(couponCode: String?, viewController: SelectAutoServiceDetailsViewController)
}

final class SelectAutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {
    
    weak var delegate: SelectAutoServiceDetailsViewControllerDelegate?
    
    var isUpdatingPrice: Bool = false {
        didSet {
            assert(Thread.isMainThread, "Must be on main")
            guard viewIfLoaded != nil else { return }
            actionButton.isLoading = isUpdatingPrice
        }
    }
    
    var isRedeemingCoupon: Bool = false {
        didSet {
            tableView.firstVisibleCell(of: RedeemCouponCell.self)?.isRedeemingCoupon = isRedeemingCoupon
        }
    }
    
    var couponRedemptionState: RedeemCouponCell.CouponRedemptionState = .none {
        didSet {
            tableView.firstVisibleCell(of: RedeemCouponCell.self)?.couponRedemptionState = couponRedemptionState
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    
    weak var paymentContext: STPPaymentContext?
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    private var selectedOilType: OilType? {
        didSet {
//            tableView.reloadData()
        }
    }
    
    func didUpdatePaymentContext() {
        tableView.reloadData()
    }
    
    private var selectedVehicle: Vehicle? {
        didSet {
            let cell = tableView.firstVisibleCell(of: SelectVehicleCell.self)
            cell?.selectedVehicle = selectedVehicle
        }
    }
    
    private enum Row: CaseIterable {
        case vehicle
        case oilType
        case paymentMethod
        case redeemCoupon
    }
    
    private var rows: [Row] = Row.allCases
    private var vehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        insetAdjuster.positionActionButton()
        
        requestVehicles { [weak self] in
            guard let currentUserID = User.currentUserID else { return }
            store.mainContext { mainContext in
                self?.selectedVehicle = Vehicle.fetchVehicles(forUserID: currentUserID, in: mainContext).first
                self?.tableView.reloadData()
            }
        }
        
        actionButton.addTarget(self, action: #selector(SelectAutoServiceDetailsViewController.didSelectPay), for: .touchUpInside)
        
        selectedOilType = .conventional
        
        actionButton.isLoading = isUpdatingPrice
    }
    
    @objc private func didSelectPay() {
        guard let vehicle = selectedVehicle,
            let oilType = selectedOilType else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                higlightAddVehicleCell()
                return
        }
        delegate?.didSelect(vehicle: vehicle, oilType: oilType, viewController: self)
        
        Analytics.logEvent(AnalyticsEventSetCheckoutOption, parameters: [
            AnalyticsParameterCheckoutOption: "selectVehicleAndOilChange",
            AnalyticsParameterCheckoutStep: "3",
        ])
    }
    
    private func higlightAddVehicleCell() {
        selectVehicleCell?.addVehicleCell?.nudge()
    }
    
    private var selectVehicleCell: SelectVehicleCell? {
        return tableView.firstVisibleCell(of: SelectVehicleCell.self)
    }
    
    private func setupTableView() {
        tableView.register(SelectVehicleCell.self)
        tableView.register(SelectOilTypeCell.self)
        tableView.register(PaymentMethodCell.self)
        tableView.register(RedeemCouponCell.self)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    private func requestVehicles(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.vehicleNetwork.requestVehicles(limit: 10, offset: 0, in: privateContext) { vehicles, error in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}


extension SelectAutoServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.item]
        switch row {
        case .vehicle:
            let cell: SelectVehicleCell = tableView.dequeueCell()
            cell.delegate = self
            cell.selectedVehicle = selectedVehicle
            return cell
        case .oilType:
            let cell: SelectOilTypeCell = tableView.dequeueCell()
            cell.delegate = self
            cell.selectedOilType = selectedOilType
            return cell
        case .paymentMethod:
            let cell: PaymentMethodCell = tableView.dequeueCell()
            cell.configure(with: paymentContext?.selectedPaymentOption)
            return cell
        case .redeemCoupon:
            let cell: RedeemCouponCell = tableView.dequeueCell()
            cell.isRedeemingCoupon = isRedeemingCoupon
            cell.didTapRedeemCoupon = { [weak self] coupon in
                guard let self = self else { return }
                self.delegate?.didSetCouponCode(couponCode: coupon, viewController: self)
            }
            cell.didUpdateHeight = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return cell
        }
    }
    
}

extension SelectAutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rows[indexPath.item]
        switch row {
        case .vehicle, .oilType, .redeemCoupon:
            break
        case .paymentMethod:
            tableView.deselectRow(at: indexPath, animated: true)
            paymentContext?.presentPaymentOptionsViewController()
        }
    }
    
}


extension SelectAutoServiceDetailsViewController: SelectVehicleCellDelegate, AddVehicleViewControllerDelegate, SelectOilTypeDelegate {
    
    func didSelectOilType(oilType: OilType, cell: SelectOilTypeCell) {
        selectedOilType = oilType
        delegate?.didChangeOilType(oilType: oilType, viewController: self)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterContentType: "oilType",
            "oilType": oilType.localizedString
        ])
    }
    
    func didSelectVehicle(vehicle: Vehicle?, cell: SelectVehicleCell) {
        selectedVehicle = vehicle
        Analytics.logEvent(AnalyticsEventSetCheckoutOption, parameters: [
            AnalyticsParameterContentType: "vehicle",
            "vehicle": vehicle?.name ?? "removed"
        ])
    }
    
    func didSelectAdd(cell: SelectVehicleCell) {
        let addVehicleViewController = AddVehicleViewController.viewControllerFromStoryboard()
        let navigationController = addVehicleViewController.inNavigationController()
        addVehicleViewController.delegate = self
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
        
        Analytics.logEvent("didSelectCreateVehicle", parameters: nil)
    }
    
    func didCreateVehicle(vehicle: Vehicle, viewController: AddVehicleViewController) {
        selectedVehicle = vehicle
        
        Analytics.logEvent("createdNewVehicle", parameters: [
            "vehicleName": vehicle.name
        ])
    }
    
    func didTapMoreInfo(cell: SelectOilTypeCell) {
        let viewController = infoWebViewController()
        present(viewController, animated: true, completion: nil)
    }
    
    private func infoWebViewController() -> SFSafariViewController {
        return SFSafariViewController(url: oilTypesURL)
    }
    
}
