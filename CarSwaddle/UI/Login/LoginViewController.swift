//
//  LoginViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/18/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleNetworkRequest
import CarSwaddleData

class LoginViewController: UIViewController, StoryboardInstantiating {
    
    private let auth = Auth(serviceRequest: serviceRequest)

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var loginTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction private func didTapLogin() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        store.privateContext { [weak self] context in
            self?.loginTask = self?.auth.login(email: email, password: password, context: context) { error in
                guard error == nil else {
                    if let networkError = error as? NetworkRequestError {
                        print("login error: \(networkError)")
                    }
                    return
                }
                print("logged in")
                DispatchQueue.main.async {
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
    }
    
    @IBAction private func didTapForgotPassword() {
        let user = UsersViewController()
        navigationController?.pushViewController(user, animated: true)
    }
    
    
}
