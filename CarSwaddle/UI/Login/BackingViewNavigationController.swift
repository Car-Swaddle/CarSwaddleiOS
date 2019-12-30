//
//  BackingViewNavigationController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

class BackingViewNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    @IBInspectable var backgroundImage: UIImage? {
        didSet {
            updateWithCurrentBackgroundImage()
        }
    }
    
    @IBInspectable var overlayColor: UIColor = .white {
        didSet {
            backgroundOverlay.backgroundColor = overlayColor
        }
    }
    
    convenience init(rootViewController: UIViewController, backgroundImage: UIImage?) {
        self.init(rootViewController: rootViewController)
        self.backgroundImage = backgroundImage
        updateWithCurrentBackgroundImage()
    }
    
    private var backgroundOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.88
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setupBackground()
        updateWithCurrentBackgroundImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupBackground() {
        view.addSubview(backgroundImageScrollView)
        backgroundImageScrollView.pinFrameToSuperViewBounds()
        
        backgroundImageScrollView.addSubview(backgroundImageView)
        
        backgroundOverlay.backgroundColor = overlayColor
        view.insertSubview(backgroundOverlay, aboveSubview: backgroundImageScrollView)
        backgroundOverlay.pinFrameToSuperViewBounds()
        updateWithCurrentBackgroundImage()
        backgroundImageView.contentMode = .scaleAspectFill
        addBackgroundScrollAnimation()
    }
    
    private func updateWithCurrentBackgroundImage() {
        let image = self.backgroundImage
        backgroundImageView.image = image
        backgroundImageView.frame = CGRect(origin: .zero, size: imageSize)
        backgroundImageScrollView.contentSize = imageSize
    }
    
    private var edgeGesture: UIScreenEdgePanGestureRecognizer?
    private var animation: CABasicAnimation?
    private var backgroundImageView = UIImageView()
    private var backgroundImageScrollView = UIScrollView()
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        edgeGesture?.removeTarget(self, action: #selector(self.handleEdgePan(_:)))
        if viewControllers.count > 1 {
            addEdgeGesture(to: viewController)
        }
    }
    
    private func addEdgeGesture(to viewController: UIViewController) {
        let edge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleEdgePan(_:)))
        edge.edges = .left
        viewController.view.addGestureRecognizer(edge)
        edgeGesture = edge
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.sendSubviewToBack(backgroundOverlay)
        view.sendSubviewToBack(backgroundImageScrollView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        addBackgroundScrollAnimation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
        }) { context in
            self.addBackgroundScrollAnimation()
        }
    }
    
    private let animationName: String = "viewAnimation"
    private var interactionController: UIPercentDrivenInteractiveTransition?
    
    private func createAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.duration = 210
        animation.autoreverses = true
        animation.repeatCount = .greatestFiniteMagnitude
        animation.fromValue = backgroundImageScrollView.bounds
        animation.toValue =  CGRect(origin: scrollViewEndPoint, size: view.frame.size)
        return animation
    }
    
    private func addBackgroundScrollAnimation() {
        backgroundImageScrollView.bounds = CGRect(origin: scrollViewStartingPoint, size: view.frame.size)
        
        backgroundImageScrollView.layer.removeAnimation(forKey: animationName)
        
        let animation = self.createAnimation()
        self.animation = animation
        backgroundImageScrollView.layer.add(animation, forKey: animationName)
        backgroundImageScrollView.bounds = CGRect(origin: scrollViewEndPoint, size: view.frame.size)
    }
    
    private func removeAnimation() {
        backgroundImageScrollView.layer.removeAnimation(forKey: animationName)
    }
    
    @objc private func willEnterForeground() {
        addBackgroundScrollAnimation()
    }
    
    @objc private func didEnterBackground() {
        addBackgroundScrollAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackgroundScrollAnimation()
    }
    
    private var scrollViewStartingPoint: CGPoint {
        return CGPoint(x: 0, y: imageSize.height - view.frame.height)
    }
    
    private var scrollViewEndPoint: CGPoint {
        return CGPoint(x: imageSize.width - view.frame.width, y: 0)
    }
    
    private let imageScale: CGFloat = 1.7
    
    private var imageSize: CGSize {
        guard let backgroundImage = backgroundImage else { return .zero }
        return CGSize(width: backgroundImage.size.width/imageScale, height: backgroundImage.size.height/imageScale)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return self.interactionController
    }
    
    private var fade: FadeAnimationController = FadeAnimationController()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
           switch operation {
           case .push, .pop:
            return FadeAnimationController()
           case .none:
            return nil
           @unknown default:
            return nil
        }
    }
    
    @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        let translate = gesture.translation(in: gesture.view)
        let percent = translate.x / gestureView.bounds.size.width
        
        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            self.popViewController(animated: true)
        case .changed:
            interactionController?.update(percent)
        case .ended, .cancelled, .failed:
            let velocity = gesture.velocity(in: gesture.view)
            if percent > 0.5 || velocity.x > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default:
            interactionController = nil
        }
    }
    
}

extension UIViewController {
    
    func inBackingViewNavigationController(image: UIImage? = UIImage(named: "suburbs"), overlayColor: UIColor = .tertiaryBrand) -> BackingViewNavigationController {
        let nav = BackingViewNavigationController(rootViewController: self, backgroundImage: image)
        nav.overlayColor = overlayColor
        return nav
    }
    
}
