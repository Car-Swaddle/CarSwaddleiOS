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
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)

    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    private var loginTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        emailTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        
        spinner.isHiddenInStackView = true
        
        updateLoginEnabledness()
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateLoginEnabledness()
    }
    
    private func updateLoginEnabledness() {
        loginButton.isEnabled = loginIsAllowed
    }
    
    private var loginIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapLogin() {
        guard loginIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateLoginEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        loginButton.isHiddenInStackView = true
        
        login(email: email, password: password) { [weak self] error in
            guard error == nil && AuthController().token != nil else {
                if let networkError = error as? NetworkRequestError {
                    print("login error: \(networkError)")
                }
                DispatchQueue.main.async {
                    self?.spinner.isHiddenInStackView = true
                    self?.spinner.stopAnimating()
                    
                    self?.loginButton.isHiddenInStackView = false
                }
                return
            }
            DispatchQueue.main.async {
                navigator.navigateToLoggedInViewController()
            }
        }
    }
    
    private func login(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        store.privateContext { [weak self] context in
            self?.loginTask = self?.auth.login(email: email, password: password, context: context) { error in
                self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: nil, token: nil, timeZone: TimeZone.current.identifier, in: context) { userObjectID, userError in
                    completion(error)
                }
            }
        }
    }
    
    @IBAction private func didTapForgotPassword() {
        let user = UsersViewController()
        navigationController?.pushViewController(user, animated: true)
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateLoginEnabledness()
        return true
    }
    
}
