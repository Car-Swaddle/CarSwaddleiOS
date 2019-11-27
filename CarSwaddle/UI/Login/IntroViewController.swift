//
//  IntroViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/24/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class IntroViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var leftOrSeparatorView: UIView!
    @IBOutlet private weak var rightOrSeparatorView: UIView!
    @IBOutlet private weak var lineAccentView: UIView!
    
    @IBOutlet private weak var logoImageView: UIImageView!
    
    @IBOutlet private weak var createAnAccountButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    
    @IBOutlet private weak var orLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orLabel.font = .header
        
        loginButton.configureForFilledIn()
        
        createAnAccountButton.configureForClear()
        
        lineAccentView.cornerRadius = lineAccentView.frame.height/2
        rightOrSeparatorView.cornerRadius = rightOrSeparatorView.frame.height/2
        leftOrSeparatorView.cornerRadius = leftOrSeparatorView.frame.height/2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func didTapLogin() {
        let login = LoginViewController.viewControllerFromStoryboard()
        login.makeTextFieldFirstResponderOnLoad = true
        show(login, sender: self)
    }
    
    @IBAction private func didTapCreateAnAccount() {
        let signUp = SignUpViewController.viewControllerFromStoryboard()
        signUp.makeTextFieldFirstResponderOnLoad = true
        show(signUp, sender: self)
    }
    
}


extension IntroViewController: FadeAnimationControllerViewMovable {
    
    var viewToBeTransitioned: UIView {
        return logoImageView
    }
    
    var frameOfViewToBeMoved: CGRect {
        return logoImageView.frame
    }
    
}


extension UIButton {
    
    private static let buttonHeight: CGFloat = 47
    private static let buttonWidth: CGFloat = 294
    
    func configureForFilledIn() {
        setTitleColor(.alternateBrand, for: .normal)
        setBackgroundImage(UIImage.from(color: .white), for: .normal)
        setBackgroundImage(UIImage.from(color: UIColor.white.withAlphaComponent(0.9)), for: .highlighted)
        setBackgroundImage(UIImage.from(color: UIColor.white.withAlphaComponent(0.9)), for: .selected)
        setBackgroundImage(UIImage.from(color: UIColor.white.withAlphaComponent(0.9)), for: .disabled)
        layer.masksToBounds = true
        
        titleLabel?.font = .action
        
        heightAnchor.constraint(equalToConstant: UIButton.buttonHeight).isActive = true
        widthAnchor.constraint(equalToConstant: UIButton.buttonWidth).isActive = true
        
        layoutIfNeeded()
        
        cornerRadius = frame.height/2
    }
    
    func configureForClear() {
        titleLabel?.font = .action
        borderWidth = 1
        borderColor = .white
        setTitleColor(.white, for: .normal)
        backgroundColor = .clear
        
        heightAnchor.constraint(equalToConstant: UIButton.buttonHeight).isActive = true
        widthAnchor.constraint(equalToConstant: UIButton.buttonWidth).isActive = true
        
        layoutIfNeeded()
        
        cornerRadius = frame.height/2
    }
    
}
