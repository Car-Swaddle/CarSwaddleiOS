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
import Store
import Firebase

final class ProfileViewController: UIViewController, StoryboardInstantiating {

    enum Row: CaseIterable {
        case name
        case phoneNumber
    }
    
    private var rows: [Row] = Row.allCases
    
    @IBOutlet private weak var tableView: UITableView!
    private let auth = Auth(serviceRequest: serviceRequest)
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var imagePicker: UIImagePickerController?
    
    private var user: User? = User.currentUser(context: store.mainContext) {
        didSet {
            reloadData()
        }
    }
    
    private lazy var headerView: ProfileHeaderView = {
        let view = ProfileHeaderView.viewFromNib()
        view.delegate = self
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        return view
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(ProfileViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .primaryBackgroundColor
        setupTableView()
        requestData()
    }
    
    private func setupTableView() {
        tableView.register(TextCell.self)
        tableView.register(LabeledInfoCell.self)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func didSelectOptions() {
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
                Analytics.logEvent("logout", parameters: [:])
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
            self?.userNetwork.requestCurrentUser(in: privateContext) { userObjectID, error in
                DispatchQueue.main.async {
                    self?.user = User.currentUser(context: store.mainContext)
                    completion()
                }
            }
        }
    }
    
    private func reloadData() {
        tableView.reloadData()
    }
    
}


extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
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
        }
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        switch row {
        case .name:
            let viewController = UserNameViewController.viewControllerFromStoryboard()
            viewController.navigationDelegate = self
            show(viewController, sender: self)
        case .phoneNumber:
            let viewController = PhoneNumberViewController.viewControllerFromStoryboard()
            viewController.navigationDelegate = self
            show(viewController, sender: self)
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
                    guard let user = mainContext.object(with: userObjectID) as? User else { return }
                    self?.headerView.configure(with: user)
                }
            }
        }
    }
    
}
