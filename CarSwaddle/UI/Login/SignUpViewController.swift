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


final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    static var storyboardName: String {
        return "LoginViewController"
    }
    
    private let auth = Auth(serviceRequest: serviceRequest)

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var loginTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func didTapSignUp() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        store.privateContext { [weak self] context in
            self?.loginTask = self?.auth.signUp(email: email, password: password, context: context) { error in
                guard error == nil else {
                    if let networkError = error as? NetworkRequestError {
                        print("login error: \(networkError)")
                    }
                    return
                }
                DispatchQueue.main.async {
                    let userInfoViewController = UserInfoViewController.viewControllerFromStoryboard()
                    self?.navigationController?.pushViewController(userInfoViewController, animated: true)
                }
            }
        }
    }
    
    @IBAction private func didTapGoToLogin() {
        
    }

}
