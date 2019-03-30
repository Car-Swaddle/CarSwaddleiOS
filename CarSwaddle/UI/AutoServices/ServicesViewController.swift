//
//  ServicesViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import CarSwaddleNetworkRequest
import Store

final class ServicesViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addTarget(self, action: #selector(ServicesViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestAutoServices { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    lazy private var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var autoServices: [AutoService] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupTableView()
        adjuster.positionActionButton()
        actionButton.addTarget(self, action: #selector(ServicesViewController.didTapCreate), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAutoServices()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    private func requestAutoServices(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServices(limit: 20, offset: 0, sortStatus: [.inProgress, .scheduled, .completed, .canceled], in: privateContext) { autoServiceIDs, error in
                DispatchQueue.main.async {
                    store.mainContext { mainContext in
                        self?.autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
                        completion()
                    }
                }
            }
        }
    }
    
    @IBAction private func didTapCreate() {
        let creator = AutoServiceCreation()
        self.creator = creator
        let pocketController = creator.pocketController!
        present(pocketController, animated: true, completion: nil)
    }
    
    private var creator: AutoServiceCreation?
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ServicesViewController: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        
    }
    
    func willBeDismissed(viewController: SelectLocationViewController) {
        
    }
    
}

extension ServicesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: autoServices[indexPath.row])
        return cell
    }
    
}

extension ServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoService = autoServices[indexPath.row]
        
        let viewController = AutoServiceDetailsViewController.create(with: autoService)
        show(viewController, sender: self)
    }
    
}






//
//
//
//private let bottomGapConstant: CGFloat = 16
//
//public protocol ContentInsetAdjusterDelegate: AnyObject {
//    func bottomOffset(adjuster: ContentInsetAdjuster) -> CGFloat
//}
//
//public class ContentInsetAdjuster {
//
//    public static var defaultBottomOffset: CGFloat = 0
//
//    public init(tableView: UITableView? = nil, actionButton: ActionButton? = nil) {
//        self.tableView = tableView
//        self.actionButton = actionButton
//
//        self.originalContentInset = tableView?.contentInset ?? .zero
//
//        setup()
//    }
//
//    public weak var delegate: ContentInsetAdjusterDelegate?
//
//    public var tableView: UITableView?
//    public var actionButton: ActionButton?
//
//    /// If this is true, you must call `positionActionButton`.
//    public var showActionButtonAboveKeyboard: Bool = false
//
//    public var includeTabBarInKeyboardCalculation: Bool = true
//
//    private var actionButtonBottomConstraint: NSLayoutConstraint?
//
//    public func positionActionButton() {
//        guard let actionButton = actionButton, let superview = actionButton.superview else {
//            assert(false, "Don't have action button or superview")
//            return
//        }
//        actionButton.translatesAutoresizingMaskIntoConstraints = false
//        let bottomConstraint = actionButton.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -bottomGapConstant)
//        self.actionButtonBottomConstraint = bottomConstraint
//        bottomConstraint.isActive = true
//        actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 280).isActive = true
//        actionButton.centerXAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerXAnchor).isActive = true
//
//        actionButton.layoutIfNeeded()
//        updateContentInsets()
//    }
//
//    private func setup() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        updateContentInsets()
//    }
//
//    public func updateContentInsets() {
//        if actionButton != nil {
//            let insets = defaultContentInsets
//            tableView?.contentInset = insets
//            tableView?.scrollIndicatorInsets.bottom = insets.bottom
//        }
//    }
//
//    private var originalContentInset: UIEdgeInsets = .zero
//
//    private var defaultBottomContentInset: CGFloat {
//        if let actionButton = actionButton, actionButton.isHidden == false {
//            let inset = actionButton.frame.height + bottomGapConstant*2
//            return inset
//        } else {
//            return 0
//        }
//    }
//
//    private var defaultContentInsets: UIEdgeInsets {
//        let previous = originalContentInset
//        return UIEdgeInsets(top: previous.top, left: previous.left, bottom: defaultBottomContentInset, right: previous.right)
//    }
//
//    @objc private func keyboardWillHide(notification: Notification) {
//        if UIApplication.shared.applicationState != .active { return }
//
//        let bottomContentInset: CGFloat
//        if actionButton != nil {
//            bottomContentInset = defaultBottomContentInset
//        } else {
//            bottomContentInset = 0
//        }
//        self.actionButton?.superview?.layoutIfNeeded()
//
//        UIView.animate(withDuration: 0.25) {
//            self.tableView?.contentInset.bottom = bottomContentInset
//            self.tableView?.scrollIndicatorInsets.bottom = bottomContentInset
//            //            self.tableView?.contentOffset = newContentOffset
//            self.actionButtonBottomConstraint?.constant = -bottomGapConstant
//            self.actionButton?.superview?.layoutIfNeeded()
//        }
//    }
//
//    @objc private func keyboardDidChange(notification: Notification) {
//
//    }
//
//    @objc private func keyboardWillShow(notification: Notification) {
//        if UIApplication.shared.applicationState != .active { return }
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
//            let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
//            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
//        var keyboardHeight = keyboardFrame.cgRectValue.height
//        keyboardHeight = keyboardHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
//        if includeTabBarInKeyboardCalculation {
//            let bottomOffset: CGFloat = (delegate?.bottomOffset(adjuster: self) ?? ContentInsetAdjuster.defaultBottomOffset)
//            keyboardHeight = keyboardHeight - bottomOffset + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
//        }
//
//        var contentInsetBottom = keyboardHeight
//
//        var newYOffset: CGFloat = 0
//        if let tableView = tableView {
//            newYOffset = keyboardHeight + tableView.contentOffset.y
//            let newWindowHeight = tableView.contentSize.height - (tableView.frame.height - (keyboardHeight + tableView.contentInset.bottom))
//            newYOffset = min(newYOffset, newWindowHeight)
//        }
//
//        if let actionButton = actionButton, showActionButtonAboveKeyboard && actionButton.isHidden == false {
//            contentInsetBottom = contentInsetBottom + actionButton.frame.height + bottomGapConstant*2
//        }
//
//        self.actionButton?.superview?.layoutIfNeeded()
//
//        let options = UIView.AnimationOptions(rawValue: animationCurve)
//        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
//            self.tableView?.contentInset.bottom = contentInsetBottom
//            self.tableView?.scrollIndicatorInsets.bottom = contentInsetBottom
//            if self.showActionButtonAboveKeyboard {
//                self.actionButtonBottomConstraint?.constant = -(keyboardHeight + bottomGapConstant)
//            }
//            self.actionButton?.superview?.layoutIfNeeded()
//        }) { isFinished in
//
//        }
//    }
//
//}
