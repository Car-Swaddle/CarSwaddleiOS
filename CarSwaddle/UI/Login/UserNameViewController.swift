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

final class UserNameViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {
    
    weak var navigationDelegate: NavigationDelegate?
    
//    @IBOutlet private weak var firstNameTextField: UITextField!
//    @IBOutlet private weak var lastNameTextField: UITextField!
    
    @IBOutlet private weak var firstNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var lastNameLabeledTextField: LabeledTextField!
    
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentUser = User.currentUser(context: store.mainContext)
        firstNameLabeledTextField.textField.text = currentUser?.firstName
        lastNameLabeledTextField.textField.text = currentUser?.lastName
        
        firstNameLabeledTextField.textField.delegate = self
        lastNameLabeledTextField.textField.delegate = self
        
        firstNameLabeledTextField.labelTextExistsFont = UIFont.appFont(type: .regular, size: 15)
        lastNameLabeledTextField.labelTextExistsFont = UIFont.appFont(type: .regular, size: 15)
        
        firstNameLabeledTextField.updateLabelFontForCurrentText()
        lastNameLabeledTextField.updateLabelFontForCurrentText()
        
        configureTextField(firstNameLabeledTextField.textField)
        firstNameLabeledTextField.textField.textContentType = .givenName
        configureTextField(lastNameLabeledTextField.textField)
        lastNameLabeledTextField.textField.textContentType = .familyName
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .default
        textField.spellCheckingType = .no
    }
    
    
    @IBAction private func didTapSave() {
        let previousButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem.activityBarButtonItem(with: .gray)
        
        updateUser { [weak self] error in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem = previousButton
                if let _self = self {
                    self?.navigationDelegate?.didFinish(navigationDelegatingViewController: _self)
//                    self?.delegate?.didChangeName(userInfoViewController: _self)
                }
            }
        }
    }
    
    private func updateUser(completion: @escaping (_ error: Error?) -> Void) {
        guard let firstName = firstNameLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let lastName = lastNameLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                completion(UserInfoError.noInput)
                return
        }
        
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: nil, token: nil, timeZone: nil, in: context) { userObjectID, error in
                completion(error)
            }
        }
    }
    
}

extension UserNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        firstNameLabeledTextField.updateLabelFontForCurrentText()
        lastNameLabeledTextField.updateLabelFontForCurrentText()
        return true
    }
    
}
