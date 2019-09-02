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

private let editNameTitle = NSLocalizedString("Edit Name", comment: "Title for a screen that allows the user to edit their name in our system")
private let yourNameTitle = NSLocalizedString("Enter your Name", comment: "Title for a screen that allows the user to edit their name in our system")

struct UserInfoError: Error {
    let rawValue: String
    
    static let noInput = UserInfoError(rawValue: "noInput")
}

final class UserNameViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {
    
    weak var navigationDelegate: NavigationDelegate?
    
    @IBOutlet private weak var firstNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var lastNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var saveButton: ActionButton!
    
    private lazy var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: saveButton)
    
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    var isOnSignUp: Bool = false {
        didSet {
            guard viewIfLoaded != nil else { return }
            contentAdjuster.includeTabBarInKeyboardCalculation = !isOnSignUp
        }
    }
    
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
        
        firstNameLabeledTextField.textField.returnKeyType = .next
        lastNameLabeledTextField.textField.returnKeyType = .done
        
        firstNameLabeledTextField.textField.addTarget(self, action: #selector(UserNameViewController.didChangeText(textField:)), for: .editingChanged)
        lastNameLabeledTextField.textField.addTarget(self, action: #selector(UserNameViewController.didChangeText(textField:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tap)
        
        contentAdjuster.includeTabBarInKeyboardCalculation = !isOnSignUp
        contentAdjuster.showActionButtonAboveKeyboard = true
        contentAdjuster.positionActionButton()
        
        updateActionButtonEnabled()
        
        title = titleForContext
    }
    
    @objc private func didTapView() {
        firstNameLabeledTextField.textField.resignFirstResponder()
        lastNameLabeledTextField.textField.resignFirstResponder()
    }
    
    @objc private func didChangeText(textField: UITextField) {
        updateActionButtonEnabled()
    }
    
    private var titleForContext: String {
        return isOnSignUp ? yourNameTitle : editNameTitle
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .default
        textField.spellCheckingType = .no
    }
    
    private var actionButtonIsEnabled: Bool {
        guard let first = firstNameLabeledTextField.textField.text,
            let last = lastNameLabeledTextField.textField.text else {
            return false
        }
        return !first.isEmpty && !last.isEmpty
    }
    
    private func updateActionButtonEnabled() {
        saveButton.isEnabled = actionButtonIsEnabled
    }
    
    @IBAction private func didTapSave() {
        saveName()
    }
    
    private func saveName() {
        saveButton.isLoading = true
        
        updateUser { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.saveButton.isLoading = false
                if error == nil {
                    self.navigationDelegate?.didFinish(navigationDelegatingViewController: self)
                }
            }
        }
    }
    
    private func updateUser(completion: @escaping (_ error: Error?) -> Void) {
        guard let firstName = firstNameLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let lastName = lastNameLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !firstName.isEmpty, !lastName.isEmpty else {
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
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameLabeledTextField.textField {
            lastNameLabeledTextField.textField.becomeFirstResponder()
        }
        if textField == lastNameLabeledTextField.textField {
            saveName()
        }
        return true
    }
    
}
