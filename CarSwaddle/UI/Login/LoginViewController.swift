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
import Firebase

class LoginViewController: UIViewController, StoryboardInstantiating {
    
    private let auth: Auth = Auth(serviceRequest: serviceRequest)
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)

    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    private var loginTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        
        let tintColor = UIColor.textColor2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: UIFont.appFont(type: .semiBold, size: 15) as Any]
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "placeholder text"), attributes: placeholderAttributes)
        emailTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "placeholder text"), attributes: placeholderAttributes)
        passwordTextField.textColor = .white
        
        loginButton.setTitleColor(.white, for: .normal)
        
        emailTextField.tintColor = .white
        passwordTextField.tintColor = .white
        
        emailTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        passwordTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        
        spinner.isHiddenInStackView = true
        
        updateLoginEnabledness()
        backgroundImageView.image = backgroundImage
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
        loginIfAllowed()
    }
    
    private func loginIfAllowed() {
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
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    AnalyticsParameterMethod: "email"
                ])
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
    
    @IBAction private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapForgotPassword() {
        let forgotPassword = ForgotPasswordViewController.viewControllerFromStoryboard()
        forgotPassword.previousEmailAddress = emailTextField.text
        present(forgotPassword.inNavigationController(), animated: true, completion: nil)
    }
    
    
    
    private var backgroundImage: UIImage? {
        let gradientPoints = SignUpViewController.gradientPoints
        return UIImage(size: view.bounds.size, gradientPoints: gradientPoints)
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginIfAllowed()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateLoginEnabledness()
        return true
    }
    
}
