//
//  UserInfoViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleUI
import Store

struct UserInfoError: Error {
    let rawValue: String
    
    static let noInput = UserInfoError(rawValue: "noInput")
}

final class UserInfoViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentUser = User.currentUser(context: store.mainContext)
        firstNameTextField.text = currentUser?.firstName
        lastNameTextField.text = currentUser?.lastName
    }
    
    
    @IBAction func didTapSave() {
        let previousButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem.activityBarButtonItem(with: .gray)
        
        updateUser { [weak self] error in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem = previousButton
                navigator.navigateToLoggedInViewController()
            }
        }
    }
    
    private func updateUser(completion: @escaping (_ error: Error?) -> Void) {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text else {
                completion(UserInfoError.noInput)
                return
        }
        
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: nil, in: context) { userObjectID, error in
                completion(error)
            }
        }
    }
    
}
