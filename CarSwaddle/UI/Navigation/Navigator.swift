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
    
    public func initialViewController() -> UIViewController {
        if AuthController().token == nil {
            let signUp = SignUpViewController.viewControllerFromStoryboard()
            return signUp
        } else {
            return rootViewController
        }
    }
    
    lazy var rootViewController: UIViewController = {
        return rootNavigationController()
    }()
    
    private var tabBarController: UITabBarController?
    
    private func rootNavigationController() -> UIViewController {
        var viewControllers: [UIViewController] = []
        
        for tab in Tab.all {
            let viewController = self.viewController(for: tab)
            viewControllers.append(viewController.inNavigationController())
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
//        tabController.tabBar.tintColor = .black
//        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9)]
//        tabController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        tabController.view.backgroundColor = .white
        
        self.tabBarController = tabController
        
        return tabController
    }
    
    private lazy var servicesViewController: ServicesViewController = {
        let servicesViewController = ServicesViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Services", comment: "Title of tab item.")
        servicesViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        return servicesViewController
    }()
    
    private lazy var profileViewController: ProfileViewController = {
        let profileViewController = ProfileViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Profile", comment: "Title of tab item.")
        profileViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        return profileViewController
    }()
    
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
            root = rootViewController
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


extension Navigator: UITabBarControllerDelegate {
    
    private static let didChangeTabEvent = "Did Change Tab"
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("changed tab")
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



//enum TransitionDirection {
//    case right
//    case left
//}
//
//protocol RelativeTransitionDelegate: class {
//    func relativeTransition(_ transition: RelativeTransition, fromViewController: UIViewController, toViewController: UIViewController) -> TransitionDirection
//}
//
//class RelativeTransition: NSObject, UIViewControllerAnimatedTransitioning {
//
//    private let duration: TimeInterval = 0.2
//    private let animationLength: CGFloat = 30.0
//    private(set) weak var delegate: RelativeTransitionDelegate?
//
//    init(delegate: RelativeTransitionDelegate) {
//        self.delegate = delegate
//    }
//
//    @objc func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return duration
//    }
//
//    @objc func animateTransition(using context: UIViewControllerContextTransitioning) {
//        guard let fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from),
//            let toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to),
//            let fromView = fromViewController.view,
//            let toView = toViewController.view else { return }
//
//        let duration = transitionDuration(using: context)
//        let containerView = context.containerView
//
//        containerView.addSubview(fromViewController.view)
//        containerView.addSubview(toViewController.view)
//
//        let offScreenRight = CGAffineTransform(translationX: animationLength, y: 0)
//        let offScreenLeft = CGAffineTransform(translationX: -animationLength, y: 0)
//
//        let direction = delegate?.relativeTransition(self, fromViewController: fromViewController, toViewController: toViewController) ?? .left
//
//        switch direction {
//        case .left:
//            toView.transform = offScreenRight
//        case .right:
//            toView.transform = offScreenLeft
//        }
//
//        toView.alpha = 0.0
//
//        UIView.animate(withDuration: duration, delay:0, options: [.curveEaseOut], animations: {
//            switch direction {
//            case .left:
//                fromView.transform = offScreenLeft
//            case .right:
//                fromView.transform = offScreenRight
//            }
//            toView.transform = .identity
//
//            fromView.alpha = 0.0
//            toView.alpha = 1.0
//        }, completion: { (finished: Bool) in
//            context.completeTransition(finished)
//            if finished {
//                fromView.transform = .identity
//                fromView.removeFromSuperview()
//            }
//        })
//    }
//
//}
//
//
