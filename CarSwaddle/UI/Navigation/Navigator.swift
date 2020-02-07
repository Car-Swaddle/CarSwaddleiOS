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
        
        actionButton.defaultBackgroundColor = .action
        actionButton.disabledBackgroundColor = UIColor.action.color(adjustedBy255Points: -70).withAlphaComponent(0.9)
        actionButton.defaultTitleFont = .large
        actionButton.setTitleColor(.disabledText, for: .disabled)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.large as Any]
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.titleTextAttributes = attributes
        navBarAppearance.barTintColor = .background
//        navBarAppearance.isTranslucent = false
        
        UITextField.appearance().tintColor = .action
        
        let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .semiBold, size: 10) as Any,
            .foregroundColor: UIColor.action
        ]
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
        
        UITabBar.appearance().barTintColor = .content
        
        let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .regular, size: 10) as Any,
            .foregroundColor: UIColor.secondaryText
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalTabBarAttributes, for: .normal)
        UITabBar.appearance().tintColor = .action
        
        UISwitch.appearance().tintColor = .action
        UISwitch.appearance().onTintColor = .action
        UINavigationBar.appearance().tintColor = .action
        
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.action as Any]
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused, .reserved] {
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: state)
        }
        
        UITableViewCell.appearance().textLabel?.font = .title
        
//        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .secondary
        UISearchBar.appearance().tintColor = .action
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.defaultTextAttributes = [.font: UIFont.title as Any, .foregroundColor: UIColor.text as Any]
        
        CustomAlertAction.cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
        
        defaultLabeledTextFieldTextFieldFont = .title
        defaultLabeledTextFieldLabelNotExistsFont = .detail
        defaultLabeledTextFieldLabelFont = .detail
        
        STPTheme.default().font = .large
        STPTheme.default().emphasisFont = .large
        
        ContentInsetAdjuster.defaultBottomOffset = tabBarController.tabBar.bounds.height
        
        let labeledTextFieldAppearance = LabeledTextField.appearance()
        labeledTextFieldAppearance.underlineColor = .action
        labeledTextFieldAppearance.textFieldBackgroundColor = .secondaryBackground
        labeledTextFieldAppearance.labelTextColor = .detailTextColor
        labeledTextFieldAppearance.textFieldTextColor = .text
        
        CircleButton.appearance().buttonColor = .text
        
        if #available(iOS 13, *) {
            let style = UINavigationBarAppearance()
            style.buttonAppearance.normal.titleTextAttributes = barButtonTextAttributes
            style.doneButtonAppearance.normal.titleTextAttributes = [.font: UIFont.action as Any, .foregroundColor: UIColor.action as Any]
            
            style.titleTextAttributes = [.font: UIFont.extralarge]
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.standardAppearance = style
            navigationBar.scrollEdgeAppearance = style
            navigationBar.compactAppearance = style
        }
        
        let alertAppearance = CustomAlertContentView.appearance()
        alertAppearance.backgroundColor = .background
        alertAppearance.titleTextColor = .text
        alertAppearance.messageTextColor = .secondaryText

        alertAppearance.normalButtonColor = .secondaryBackground
        alertAppearance.normalButtonTitleColor = .text
        alertAppearance.buttonBorderColor = .clear

        alertAppearance.preferredButtonColor = .action
        alertAppearance.preferredButtonTitleColor = .inverseText
        
        alertAppearance.buttonTitleFont = .title

        alertAppearance.titleFont = .large
        alertAppearance.buttonTitleFont = .title
        alertAppearance.messageFont = .title

        alertAppearance.textFieldFont = .title

        alertAppearance.switchLabelFont = .detail
        alertAppearance.switchLabelTextColor = .text

        alertAppearance.textFieldBorderColor = .secondaryContent
        
        CustomAlertController.alertBackgroundColor = .background
        CustomAlertController.transparentBackgroundColor = UIColor.neutral3.withAlphaComponent(0.5)
    }
    
    public func initialViewController() -> UIViewController {
        if isLoggedIn {
            return loggedInViewController
        } else {
            return LoginExperience.initialViewController()
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
        tabController.view.backgroundColor = .background
        
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
        let login = LoginExperience.initialViewController()
        login.view.frame = rootViewController.view.frame
        login.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = login
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
        navigationDelegateViewController.modalPresentationStyle = .fullScreen
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
            name.isOnSignUp = true
            viewControllers.append(name)
        }
        
        if currentUser?.phoneNumber == nil {
            let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
            phoneNumber.isOnSignUp = true
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
        
        let profileViewController = ProfileViewController()
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


class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    var navigationController: UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
