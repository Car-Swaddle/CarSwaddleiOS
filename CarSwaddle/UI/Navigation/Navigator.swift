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
import Store

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
        
        if AuthController().token != nil {
            //            pushNotificationController.requestPermission()
            showRequiredScreensIfNeeded()
        }
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        let actionButton = ActionButton.appearance()
        
        actionButton.defaultBackgroundColor = .secondary
        actionButton.disabledBackgroundColor = UIColor.secondary.color(adjustedBy255Points: -40)
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
        
        LabeledTextField.defaultTextFieldFont = UIFont.appFont(type: .regular, size: 17)
        LabeledTextField.defaultLabelNotExistsFont = UIFont.appFont(type: .semiBold, size: 17)
        LabeledTextField.defaultLabelFont = UIFont.appFont(type: .regular, size: 17)
        
        let labeledTextFieldAppearance = LabeledTextField.appearance()
        labeledTextFieldAppearance.underlineColor = .secondary
    }
    
    public func initialViewController() -> UIViewController {
        if AuthController().token == nil {
            let signUp = SignUpViewController.viewControllerFromStoryboard()
            let navigationController = signUp.inNavigationController()
            navigationController.navigationBar.barStyle = .black
            navigationController.navigationBar.isHidden = true
            return navigationController
        } else {
            return loggedInViewController
        }
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
        appDelegate.window?.rootViewController?.present(navigationDelegateViewController, animated: true, completion: nil)
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
        
        appDelegate.window?.rootViewController?.present(navigationController, animated: true, completion: nil)
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
