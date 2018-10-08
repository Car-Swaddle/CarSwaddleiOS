//
//  UIViewControllerExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func inNavigationController() -> UINavigationController {
        let nav = UINavigationController(rootViewController: self)
//        let styler = NavigationBarStyler(navigationBar: nav.navigationBar)
//        styler.style()
        nav.view.layer.shadowColor = UIColor.clear.cgColor
        nav.view.layer.shadowOpacity = 0.0
        nav.view.clipsToBounds = true
        return nav
    }
    
}
