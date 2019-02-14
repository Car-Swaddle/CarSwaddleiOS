//
//  SignUpViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/18/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleNetworkRequest
import CarSwaddleData
import Authentication


final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    static var storyboardName: String {
        return "LoginViewController"
    }
    
    private let auth = Auth(serviceRequest: serviceRequest)

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var signUpTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapSignUp() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        store.privateContext { [weak self] context in
            self?.signUpTask = self?.auth.signUp(email: email, password: password, context: context) { error in
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
    
    @IBAction private func didTapGoToLogin() {
        
    }

}

//extension SignUpViewController: NavigationDelegate {
//
//    func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController) {
//        navigator.navigateToLoggedInViewController()
//    }
//
//}
