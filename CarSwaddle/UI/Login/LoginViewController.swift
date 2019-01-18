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
import Authentication

class LoginViewController: UIViewController, StoryboardInstantiating {
    
    private let auth: Auth = Auth(serviceRequest: serviceRequest)

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet weak var testServerSwitch: UISwitch!
    private var loginTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testServerSwitch.setOn(useLocalServer, animated: false)
    }
    
    @IBAction private func didTapLogin() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        store.privateContext { [weak self] context in
            self?.loginTask = self?.auth.login(email: email, password: password, context: context) { error in
                guard error == nil && AuthController().token != nil else {
                    if let networkError = error as? NetworkRequestError {
                        print("login error: \(networkError)")
                    }
                    return
                }
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
    
    
    
    @IBAction func didSwitch(_ testServerSwitch: UISwitch) {
        _serviceRequest = nil
        useLocalServer = testServerSwitch.isOn
    }
    
}
