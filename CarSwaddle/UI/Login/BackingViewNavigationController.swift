//
//  BackingViewNavigationController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

class BackingViewNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    private var backgroundOverlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImageScrollView)
        backgroundImageScrollView.pinFrameToSuperViewBounds()
        
        backgroundImageScrollView.addSubview(backgroundImageView)
        
        view.backgroundColor = .red
        
        delegate = self
        let backgroundOverlay = UIView()
        backgroundOverlay.backgroundColor = .tertiaryBrand
        backgroundOverlay.alpha = 0.88
        self.backgroundOverlay = backgroundOverlay
        view.insertSubview(backgroundOverlay, aboveSubview: backgroundImageScrollView)
        backgroundOverlay.pinFrameToSuperViewBounds()
        
        backgroundImageView.contentMode = .scaleAspectFill
        let image = self.backgroundImage
        backgroundImageView.image = image
        backgroundImageView.frame = CGRect(origin: .zero, size: imageSize)
        
        backgroundImageScrollView.contentSize = imageSize
        
        addThatAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private var animation: CABasicAnimation?
    private var backgroundImageView = UIImageView()
    private var backgroundImageScrollView = UIScrollView()
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let backgroundOverlay = backgroundOverlay {
            view.sendSubviewToBack(backgroundOverlay)
        }
        view.sendSubviewToBack(backgroundImageScrollView)
    }
    
    private let animationName: String = "viewAnimation"
    
    private func createAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.duration = 210
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        animation.fromValue = backgroundImageScrollView.bounds
        animation.toValue =  CGRect(origin: scrollViewEndPoint, size: view.frame.size)
        //        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    private func addThatAnimation() {
        backgroundImageScrollView.bounds = CGRect(origin: scrollViewStartingPoint, size: view.frame.size)
        
        let animation = self.createAnimation()
        self.animation = animation
        backgroundImageScrollView.layer.removeAnimation(forKey: animationName)
        backgroundImageScrollView.layer.add(animation, forKey: animationName)
        backgroundImageScrollView.bounds = CGRect(origin: scrollViewEndPoint, size: view.frame.size)
    }
    
    private func removeAnimation() {
        backgroundImageScrollView.layer.removeAnimation(forKey: animationName)
    }
    
    @objc private func willEnterForeground() {
        addThatAnimation()
    }
    
    @objc private func didEnterBackground() {
        removeAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addThatAnimation()
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeAnimationController()
    }
    
    private var backgroundImage: UIImage {
        //        let gradientPoints = SignUpViewController.gradientPoints
        //        return UIImage(size: view.bounds.size, gradientPoints: gradientPoints)
        return UIImage(named: "suburbs")!
    }
    
    private var scrollViewStartingPoint: CGPoint {
        return CGPoint(x: 0, y: imageSize.height - view.frame.height)
    }
    
    private var scrollViewEndPoint: CGPoint {
        return CGPoint(x: imageSize.width - view.frame.width, y: 0)
    }
    
    private let scale: CGFloat = 1.7
    
    private var imageSize: CGSize {
        return CGSize(width: backgroundImage.size.width/scale, height: backgroundImage.size.height/scale)
    }
    
    //    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    //        <#code#>
    //    }
    
}

extension UIViewController {
    
    func inBackingViewNavigationController() -> BackingViewNavigationController {
        return BackingViewNavigationController(rootViewController: self)
    }
    
}

class IntroNavigatoinController: BackingViewNavigationController {
    
    
    
}



final class FadeTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeAnimationController()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeAnimationController()
    }
    
    //    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    //        return nil
    //    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
}

protocol FadeAnimationControllerViewMovable: AnyObject {
    var viewToBeTransitioned: UIView { get }
    var frameOfViewToBeMoved: CGRect { get }
}

protocol FadeAnimationControllerFrameSpecifying: AnyObject {
    var viewBeingTransitionedTo: UIView { get }
    var newFrameOfViewToBeTransitioned: CGRect { get }
}

class FadeAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.55
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.toView,
            let fromView = transitionContext.fromViewController?.view,
            let toViewController = transitionContext.toViewController,
            let fromViewController = transitionContext.fromViewController else { return }
        
        transitionContext.containerView.addSubview(toView)
        toView.alpha = 0.0
        
        //        toView.frame = transitionContext.finalFrame(for: toViewController)
        
        let viewMovable = (fromViewController as? FadeAnimationControllerViewMovable)
        let viewToBeMovedSnapshot = viewMovable?.viewToBeTransitioned.snapshotView(afterScreenUpdates: false)
        let frameSpecifying = (toViewController as? FadeAnimationControllerFrameSpecifying)
        let newFrame = frameSpecifying?.newFrameOfViewToBeTransitioned
        let newView = frameSpecifying?.viewBeingTransitionedTo
        
        if let viewToBeMovedSnapshot = viewToBeMovedSnapshot,
            let frameOfViewToBeMoved = viewMovable?.frameOfViewToBeMoved {
            transitionContext.containerView.addSubview(viewToBeMovedSnapshot)
            viewToBeMovedSnapshot.frame = frameOfViewToBeMoved
            newView?.alpha = 0.0
            viewMovable?.viewToBeTransitioned.alpha = 0.0
//            viewToBeMovedSnapshot.alpha = 0.0
        }
        
        toView.frame = transitionContext.containerView.frame
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                fromView.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                toView.alpha = 1.0
            }
            
//            if let newFrame = newFrame {
//                viewToBeMovedSnapshot?.frame = newFrame
//            }
        }) { isFinished in
//            viewMovable?.viewToBeTransitioned.alpha = 1.0
//            newView?.alpha = 1.0
//            viewToBeMovedSnapshot?.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(isFinished)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseInOut, animations: {
            if let newFrame = newFrame {
                viewToBeMovedSnapshot?.frame = newFrame
            }
        }) { isFinished in
            viewMovable?.viewToBeTransitioned.alpha = 1.0
            newView?.alpha = 1.0
            viewToBeMovedSnapshot?.removeFromSuperview()
        }
        
//        UIView.animate(
//            withDuration: transitionDuration(using: transitionContext)/2,
//            animations: {
//                fromView.alpha = 0.0
//        }, completion: { finished in
//            fromViewController.view.removeFromSuperview()
//            UIView.animate(
//                withDuration: self.transitionDuration(using: transitionContext)/2,
//                animations: {
//                    toView.alpha = 1.0
//            }, completion: { finished in
//                transitionContext.completeTransition(finished)
//            })
//        })
    }
    
}

extension UIViewControllerContextTransitioning {
    
    var toView: UIView? {
        return view(forKey: .to)
    }
    
    var fromView: UIView? {
        return view(forKey: .from)
    }
    
    var toViewController: UIViewController? {
        return viewController(forKey: .to)
    }
    
    var fromViewController: UIViewController? {
        return viewController(forKey: .from)
    }
    
}



final class ClearBackgroundPresentationController: UIPresentationController {
    
    public override var shouldRemovePresentersView: Bool { return true }
    
    
    public override func presentationTransitionWillBegin() {
        
        
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        
    }
    
    public override func dismissalTransitionWillBegin() {
        
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
}

