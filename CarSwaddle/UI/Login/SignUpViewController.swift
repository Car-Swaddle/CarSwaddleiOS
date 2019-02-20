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

    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var signUpTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        
        spinner.isHiddenInStackView = true
        updateSignUpEnabledness()
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateSignUpEnabledness()
    }
    
    private func updateSignUpEnabledness() {
        signupButton.isEnabled = signUpIsAllowed
    }
    
    private var signUpIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapSignUp() {
        guard signUpIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateSignUpEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        signupButton.isHiddenInStackView = true
        
        store.privateContext { [weak self] context in
            self?.signUpTask = self?.auth.signUp(email: email, password: password, context: context) { error in
                guard error == nil && AuthController().token != nil else {
                    if let networkError = error as? NetworkRequestError {
                        print("login error: \(networkError)")
                    }
                    DispatchQueue.main.async {
                        self?.spinner.isHiddenInStackView = true
                        self?.spinner.stopAnimating()
                        
                        self?.signupButton.isHiddenInStackView = false
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

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignUpEnabledness()
        return true
    }
    
}


public extension String {
    
    private static let validateEmailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    public var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", String.validateEmailRegex)
        return emailTest.evaluate(with: self)
    }
    
    public var isValidPassword: Bool {
        return self.count > 3
    }
    
}
