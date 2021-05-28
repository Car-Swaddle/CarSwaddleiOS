//
//  ProfileViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleNetworkRequest
import Authentication
import CarSwaddleUI
import CarSwaddleStore
import SwiftUI

private let numberOfCoupons: Int = 3

final class ProfileViewController: TableViewSchemaController {

    enum Row: String, CaseIterable, TableViewControllerRow {
        var identifier: String { return self.rawValue }
        case name
        case phoneNumber
        case coupon
    }
    
    private let auth = Auth(serviceRequest: serviceRequest)
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private let couponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    private var imagePicker: UIImagePickerController?
    
    private var user: CarSwaddleStore.User? = User.currentUser(context: store.mainContext) {
        didSet {
            reloadData()
        }
    }
    
    private lazy var coupons: [Coupon] = {
         return Coupon.fetchCurrentUserShareableCoupons(fetchLimit: numberOfCoupons, in: store.mainContext)
    }()
    
    private lazy var headerView: ProfileHeaderView = {
        let view = ProfileHeaderView.viewFromNib()
        view.delegate = self
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        return view
    }()
    
    
    override func didPullToRefresh() {
        requestData { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override var cellTypes: [NibRegisterable.Type] {
        return [LabeledInfoCell.self, CouponCodeCell.self]
    }
    
    public init() {
        super.init(schema: [Section(rows: [Row.name, Row.phoneNumber]), Section(rows: [Row.coupon, Row.coupon, Row.coupon])])
        title = NSLocalizedString("Coupon Creation", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        requestData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Options", comment: ""), style: .plain, target: self, action: #selector(didSelectOptions))
        
        tableView.delegate = self
        tableView.sectionHeaderHeight = 30
        tableView.backgroundColor = .background
    }
    
    private func updateCouponsFromNetwork() {
        importCoupons { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.reloadData()
            }
        }
    }
    
    private func importCoupons(completion: @escaping (_ error: Error?) -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.couponNetwork.getSharableCoupons(limit: 3, offset: 0, in: privateContext) { couponIDs, error in
                completion(error)
            }
        }
    }
    
    @objc private func didSelectOptions() {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = self.logoutAction()
        
        actionController.addAction(logoutAction)
        actionController.addCancelAction()
        
        present(actionController, animated: true, completion: nil)
    }
    
    private func logoutAction() -> UIAlertAction {
        let title = NSLocalizedString("Logout", comment: "title of button to logout")
        let logoutAction = UIAlertAction(title: title, style: .destructive) { [weak self] action in
            self?.logoutServer {
                self?.logoutLocally {
                    navigator.navigateToLoggedOutViewController()
                }
            }
        }
        return logoutAction
    }
    
    private func logoutServer(completion: @escaping () -> Void) {
        auth.logout(deviceToken: pushNotificationController.getDeviceToken()) { error in
            pushNotificationController.deleteDeviceToken()
            DispatchQueue.main.async {
                tracker.logEvent(name: "logout", parameters: nil)
                completion()
            }
        }
    }
    
    private func logoutLocally(completion: @escaping () -> Void) {
        finishTasksAndInvalidate {
            try? store.destroyAllData()
            try? profileImageStore.destroy()
            AuthController().removeToken()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func requestData(completion: @escaping () -> Void = {  }) {
        store.privateContext { [weak self] privateContext in
            
            let group = DispatchGroup()
            
            group.enter()
            self?.userNetwork.requestCurrentUser(in: privateContext) { userObjectID, error in
                DispatchQueue.main.async {
                    self?.user = User.currentUser(context: store.mainContext)
                    group.leave()
                }
            }
            
            group.enter()
            self?.couponNetwork.getSharableCoupons(limit: numberOfCoupons, offset: 0, in: privateContext) { couponIDs, error in
                DispatchQueue.main.async {
                    self?.coupons = Coupon.fetchCurrentUserShareableCoupons(fetchLimit: numberOfCoupons, in: store.mainContext)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.reloadData()
                completion()
            }
        }
    }
    
    private func activityViewController(with code: String) -> UIActivityViewController {
        let formatString = NSLocalizedString("I'm giving you %%10 off a mobile oil change from Car Swaddle. To accept, use the code %@ on checkout. Download the app at %@", comment: "")
        let shareCopy = String(format: formatString, code, urlNavigation.carSwaddleAppStoreURL.absoluteString)
        let activity = UIActivityViewController(activityItems: [shareCopy], applicationActivities: nil)
        return activity
    }
    
    private func reloadData() {
        tableView.reloadData()
    }
    
    override func cell(for viewRow: TableViewControllerRow, indexPath: IndexPath) -> UITableViewCell {
        guard let row = viewRow as? Row else { fatalError("Not correct row") }
        switch row {
        case .name:
            let cell: LabeledInfoCell = tableView.dequeueCell()
            cell.valueText = user?.displayName
            cell.descriptionText = NSLocalizedString("Name", comment: "Name of the user")
            return cell
        case .phoneNumber:
            let cell: LabeledInfoCell = tableView.dequeueCell()
            cell.valueText = user?.phoneNumber
            cell.descriptionText = NSLocalizedString("Phone number", comment: "Phone number of user")
            return cell
        case .coupon:
            let cell: CouponCodeCell = tableView.dequeueCell()
            if let coupon = coupons.safeObject(at: indexPath.row) {
                cell.configure(with: coupon)
                cell.didSelectShare = { [weak self] code in
                    self?.showActivity(forCoupon: code)
                }
            } else {
                cell.configureForNoCoupon()
                cell.didSelectShare = { _ in }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = schema[indexPath.section].rows[indexPath.row] as? Row else { return }
        switch row {
        case .name:
            let viewController = UserNameViewController.viewControllerFromStoryboard()
            viewController.navigationDelegate = self
            show(viewController, sender: self)
        case .phoneNumber:
            let viewController = PhoneNumberViewController.viewControllerFromStoryboard()
            viewController.navigationDelegate = self
            show(viewController, sender: self)
        case .coupon:
            if let coupon = coupons.safeObject(at: indexPath.row), coupon.canBeRedeemed {
                showActivity(forCoupon: coupon.identifier)
            }
        }
    }
    
    private func showActivity(forCoupon coupon: String) {
        let activity = self.activityViewController(with: coupon)
        present(activity, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = LabeledHeaderView.viewFromNib()
            view.label.text = NSLocalizedString("Do you have a friend that could use an oil change? We've generated three 10% off coupon codes for you to share:", comment: "")
            return view
        } else {
            return nil
        }
    }
    
}

extension ProfileViewController: NavigationDelegate {
    
    func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController) {
        tableView.reloadData()
        navigationController?.popToViewController(self, animated: true)
    }
    
}

extension ProfileViewController: ProfileHeaderViewDelegate {
    
    func didSelectCamera(headerView: ProfileHeaderView) {
        let imagePicker = self.imagePicker(source: .camera)
        present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectCameraRoll(headerView: ProfileHeaderView) {
        let imagePicker = self.imagePicker(source: .photoLibrary)
        present(imagePicker, animated: true, completion: nil)
    }
    
    func presentAlert(alert: UIAlertController, headerView: ProfileHeaderView) {
        present(alert, animated: true, completion: nil)
    }
    
    private func imagePicker(source: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = false
        return imagePicker
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        guard let image = info[.originalImage] as? UIImage else { return }
        let orientedImage = UIImage.imageWithCorrectedOrientation(image)
        guard let imageData = orientedImage.resized(toWidth: 300 * UIScreen.main.scale)?.jpegData(compressionQuality: 1.0) else {
            return
        }
        guard let url = try? profileImageStore.storeFile(data: imageData, fileName: User.currentUserID ?? "profileImage") else {
            return
        }
//        updateHeader()
        store.privateContext { [weak self] privateContext in
            self?.userNetwork.setProfileImage(fileURL: url, in: privateContext) { userObjectID, error in
                store.mainContext { mainContext in
                    guard let userObjectID = userObjectID else { return }
                    guard let user = mainContext.object(with: userObjectID) as? CarSwaddleStore.User else { return }
                    self?.headerView.configure(with: user)
                }
            }
        }
    }
    
}
