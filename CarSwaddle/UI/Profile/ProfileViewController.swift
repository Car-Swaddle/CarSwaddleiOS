//
//  ProfileViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
//import CarSwaddleUI

final class ProfileViewController: UIViewController, StoryboardInstantiating {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
    
    @IBAction private func didSelectOptions() {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let title = NSLocalizedString("Logout", comment: "title of button to logout")
        let logoutAction = UIAlertAction(title: title, style: .destructive) { action in
            Auth().logout { error in
                print("error: \(error)")
            }
        }
        
        actionController.addAction(logoutAction)
        actionController.addCancelAction()
        
        present(actionController, animated: true, completion: nil)
    }
    
}
