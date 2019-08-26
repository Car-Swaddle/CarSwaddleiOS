//
//  Navigator.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Authentication
import CarSwaddleUI
import CarSwaddleData
import Store
import Stripe

extension Navigator {
    
    enum Tab: Int {
        case services
        case profile
        
        static var all: [Tab] {
            return [.services, .profile]
        }
        
        fileprivate var name: String {
            switch self {
            case .services:
                return "Services"
            case .profile:
                return "Profile"
            }
        }
        
    }
    
}

let navigator = Navigator()

final class Navigator: NSObject {
    
    private var appDelegate: AppDelegate
    
    public override init() {
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    public func setupWindow() {
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = navigator.initialViewController()
        appDelegate.window?.makeKeyAndVisible()
        
        #if DEBUG
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(Navigator.didTripleTap))
        tripleTap.numberOfTapsRequired = 3
        tripleTap.numberOfTouchesRequired = 2
        appDelegate.window?.addGestureRecognizer(tripleTap)
        #endif
        
        if isLoggedIn {
            pushNotificationController.requestPermission()
            showRequiredScreensIfNeeded()
        }
        
        setupAppearance()
    }
    
    private var ratingController: RatingController = RatingController()
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    public func showRatingAlertFor(autoServiceID: String) {
        guard isLoggedIn else { return }
        let alert = ratingController.createRatingAlert(forAutoServiceID: autoServiceID)
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    public func showAutoService(autoServiceID: String) {
        guard isLoggedIn else { return }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServiceDetails(autoServiceID: autoServiceID, in: privateContext) { autoServiceObjectID, error in
                store.mainContext { mainContext in
                    guard let self = self else { return }
                    guard let autoService = AutoService.fetch(with: autoServiceID, in: store.mainContext) else { return }
                    let viewController = self.viewController(for: .services)
                    UIViewController.dismissToViewController(viewController) { success in
                        self.tabBarController.selectedIndex = Tab.services.rawValue
                        if let navigationController = viewController.navigationController {
                            let viewController = AutoServiceDetailsViewController.create(with: autoService)
                            navigationController.show(viewController, sender: self)
                        }
                    }
                }
            }
        }
    }
    
    private func setupAppearance() {
        let actionButton = ActionButton.appearance()
        
        actionButton.defaultBackgroundColor = .secondary
        actionButton.disabledBackgroundColor = UIColor.secondary.color(adjustedBy255Points: -70).withAlphaComponent(0.9)
        actionButton.defaultTitleFont = UIFont.appFont(type: .semiBold, size: 20)
        actionButton.setTitleColor(.gray3, for: .disabled)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 20) as Any]
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().barTintColor = .veryLightGray
        UINavigationBar.appearance().isTranslucent = false
        UITextField.appearance().tintColor = .secondary
        
        let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .semiBold, size: 10) as Any,
            .foregroundColor: UIColor.secondary
        ]
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
        
        let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .regular, size: 10) as Any,
            .foregroundColor: UIColor.lightGray
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalTabBarAttributes, for: .normal)
        UITabBar.appearance().tintColor = .secondary
        
        UISwitch.appearance().tintColor = .secondary
        UISwitch.appearance().onTintColor = .secondary
        UINavigationBar.appearance().tintColor = .secondary
        
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 17) as Any]
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused, .reserved] {
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: state)
        }
        
        UITableViewCell.appearance().textLabel?.font = UIFont.appFont(type: .regular, size: 14)
        
//        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .secondary
        UISearchBar.appearance().tintColor = .secondary
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.defaultTextAttributes = [.font: UIFont.appFont(type: .regular, size: 17) as Any]
        
        CustomAlertAction.cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
        
        defaultLabeledTextFieldTextFieldFont = UIFont.appFont(type: .regular, size: 15)
        defaultLabeledTextFieldLabelNotExistsFont = UIFont.appFont(type: .semiBold, size: 15)
        defaultLabeledTextFieldLabelFont = UIFont.appFont(type: .regular, size: 15)
        
        STPTheme.default().font = UIFont.appFont(type: .regular, size: 19)
        STPTheme.default().emphasisFont = UIFont.appFont(type: .semiBold, size: 19)
        
        ContentInsetAdjuster.defaultBottomOffset = tabBarController.tabBar.bounds.height
        
        let labeledTextFieldAppearance = LabeledTextField.appearance()
        labeledTextFieldAppearance.underlineColor = .secondary
    }
    
    public func initialViewController() -> UIViewController {
        if isLoggedIn {
            return loggedInViewController
        } else {
            let signUp = SignUpViewController.viewControllerFromStoryboard()
            let navigationController = signUp.inNavigationController()
            navigationController.navigationBar.barStyle = .black
            navigationController.navigationBar.isHidden = true
            return navigationController
        }
    }
    
    public var isLoggedIn: Bool {
        return AuthController().token != nil
    }
    
    public var loggedInViewController: UIViewController {
        return tabBarController
    }
    
    private var _tabBarController: UITabBarController?
    public var tabBarController: UITabBarController {
        if let _tabBarController = _tabBarController {
            return _tabBarController
        }
        
        var viewControllers: [UIViewController] = []
        for tab in Tab.all {
            let viewController = self.viewController(for: tab)
            viewControllers.append(viewController.inNavigationController())
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
        tabController.view.backgroundColor = .white
        
        self._tabBarController = tabController
        
        tabController.view.layoutIfNeeded()
        ContentInsetAdjuster.defaultBottomOffset = tabController.tabBar.bounds.height
        
        return tabController
    }
    
    public func navigateToLoggedInViewController() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let newViewController = loggedInViewController
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { completed in
            pushNotificationController.requestPermission()
            self.showRequiredScreensIfNeeded()
        }
    }
    
    public func navigateToLoggedOutViewController() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let signUp = SignUpViewController.viewControllerFromStoryboard()
        let newViewController = signUp.inNavigationController()
        newViewController.navigationBar.barStyle = .black
        newViewController.navigationBar.isHidden = true
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { [weak self] completed in
            self?.removeUI()
        }
    }
    
    private func removeUI() {
        _tabBarController = nil
        _servicesViewController = nil
        _profileViewController = nil
    }
    
    private func showRequiredScreensIfNeeded() {
        let viewControllers = requiredViewControllers()
        guard viewControllers.count > 0 else { return }
        
        let navigationDelegateViewController = NavigationDelegateViewController(navigationDelegatingViewControllers: viewControllers)
        navigationDelegateViewController.externalDelegate = self
        presentAtRoot(viewController: navigationDelegateViewController)
//        appDelegate.window?.rootViewController?.present(navigationDelegateViewController, animated: true, completion: nil)
    }
    
    private func presentAtRoot(viewController: UIViewController) {
        appDelegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func requiredViewControllers() -> [NavigationDelegatingViewController] {
        var viewControllers: [NavigationDelegatingViewController] = []
        
        let currentUser = User.currentUser(context: store.mainContext)
        
        if currentUser?.firstName == nil || currentUser?.lastName == nil {
            let name = UserNameViewController.viewControllerFromStoryboard()
            viewControllers.append(name)
        }
        
        if currentUser?.phoneNumber == nil {
            let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
            viewControllers.append(phoneNumber)
        }
        
        if currentUser?.isPhoneNumberVerified == false {
            let verify = VerifyPhoneNumberViewController()
            viewControllers.append(verify)
        }
        
        return viewControllers
    }
    
    func showEnterNewPasswordScreen(resetToken: String) {
        let enterPassword = EnterNewPasswordViewController.create(resetToken: resetToken)
        presentAtRoot(viewController: enterPassword.inNavigationController())
    }
    
    private var _servicesViewController: ServicesViewController?
    private var servicesViewController: ServicesViewController {
        if let _servicesViewController = _servicesViewController {
            return _servicesViewController
        }
        
        let servicesViewController = ServicesViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Services", comment: "Title of tab item.")
        let image = #imageLiteral(resourceName: "car")
        let selectedImage = #imageLiteral(resourceName: "car")
        servicesViewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        _servicesViewController = servicesViewController
        return servicesViewController
    }
    
    private var _profileViewController: ProfileViewController?
    private var profileViewController: ProfileViewController {
        if let _profileViewController = _profileViewController {
            return _profileViewController
        }
        
        let profileViewController = ProfileViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Profile", comment: "Title of tab item.")
        let image = #imageLiteral(resourceName: "user")
        let selectedImage = #imageLiteral(resourceName: "user")
        profileViewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        _profileViewController = profileViewController
        return profileViewController
    }
    
    private func viewController(for tab: Tab) -> UIViewController {
        switch tab {
        case .services:
            return servicesViewController
        case .profile:
            return profileViewController
        }
    }
    
    private func tab(from viewController: UIViewController) -> Tab? {
        var root: UIViewController
        if let navigationController = viewController as? UINavigationController,
            let navRoot = navigationController.viewControllers.first {
            root = navRoot
        } else {
            root = loggedInViewController
        }
        
        if root == self.servicesViewController {
            return .services
        } else if root == self.profileViewController {
            return .profile
        }
        return nil
    }
    
    lazy private var transition: HorizontalSlideTransition = {
        return HorizontalSlideTransition(delegate: self)
    }()
    
}

#if DEBUG
extension Navigator: TweakViewControllerDelegate {
    
    @objc private func didTripleTap() {
        let allTweaks = Tweak.all
        let tweakViewController = TweakViewController.create(with: allTweaks, delegate: self)
        let navigationController = tweakViewController.inNavigationController()

        presentAtRoot(viewController: navigationController)
//        appDelegate.window?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func didDismiss(requiresAppReset: Bool, tweakViewController: TweakViewController) {
        if requiresAppReset {
            logout.logout()
        }
    }
    
}
#endif

extension Navigator: UITabBarControllerDelegate {
    
    private static let didChangeTabEvent = "Did Change Tab"
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //        guard let tab = self.tab(from: viewController) else { return }
        //        trackEvent(with: Navigator.didChangeTabEvent, attributes: ["Screen": tab.name])
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
}

extension Navigator: HorizontalSlideTransitionDelegate {
    
    func relativeTransition(_ transition: HorizontalSlideTransition, fromViewController: UIViewController, toViewController: UIViewController) -> HorizontalSlideDirection {
        guard let fromTab = self.tab(from: fromViewController),
            let toTab = self.tab(from: toViewController) else { return .left }
        return fromTab.rawValue < toTab.rawValue ? .left : .right
    }
    
}


extension Navigator: NavigationDelegateViewControllerDelegate {
    
    func didFinishLastViewController(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
        navigateToLoggedInViewController()
    }
    
    func didSelectLogout(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.endEditing(true)
        logout.logout()
    }
    
}



extension UINavigationController {
    
    public func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popToViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}


public extension UIViewController {
    
    static func dismissToViewController(_ rootViewController: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                if let navigationController = presentedViewController as? UINavigationController {
                    navigationController.popToRootViewController(animated: true) {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            }
        } else if let navigationController = rootViewController.navigationController {
            navigationController.popToRootViewController(animated: true) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
}
