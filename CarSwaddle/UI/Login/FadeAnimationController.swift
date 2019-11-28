//
//  FadeTransition.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

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
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.toView,
            let fromView = transitionContext.fromView,
            let toViewController = transitionContext.toViewController,
            let fromViewController = transitionContext.fromViewController else { return }
        
        print("animateTransition: \(#function)")
        
        transitionContext.containerView.addSubview(toView)
        toView.frame = transitionContext.finalFrame(for: toViewController)
        toView.alpha = 0.0
        
        toView.layoutIfNeeded()
        
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
        }
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                fromView.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                toView.alpha = 1.0
            }
        }) { isFinished in
            if !transitionContext.transitionWasCancelled {
                fromView.alpha = 1.0
                fromViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled && isFinished)
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
