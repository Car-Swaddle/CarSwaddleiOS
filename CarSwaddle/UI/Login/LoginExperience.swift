//
//  LoginExperience.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/24/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

class LoginExperience {
    
    static func initialViewController() -> UIViewController {
        let signUp = IntroViewController.viewControllerFromStoryboard()
        let navigationController = signUp.inBackingViewNavigationController()
        navigationController.navigationBar.barStyle = .black
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
    
}
