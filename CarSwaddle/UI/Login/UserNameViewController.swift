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
    
    static let editNameTitle = NSLocalizedString("Edit Name", comment: "Title for a screen that allows the user to edit their name in our system")
    static let yourNameTitle = NSLocalizedString("Your Name", comment: "Title for a screen that allows the user to edit their name in our system")
    
    weak var navigationDelegate: NavigationDelegate?
    
    @IBOutlet private weak var firstNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var lastNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var saveButton: ActionButton!
    
    private lazy var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: saveButton)
    
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
        
        contentAdjuster.showActionButtonAboveKeyboard = true
        contentAdjuster.positionActionButton()
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .default
        textField.spellCheckingType = .no
    }
    
    @IBAction private func didTapSave() {
        saveButton.isLoading = true
        
        updateUser { [weak self] error in
            DispatchQueue.main.async {
                self?.saveButton.isLoading = false
                if let _self = self {
                    self?.navigationDelegate?.didFinish(navigationDelegatingViewController: _self)
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
