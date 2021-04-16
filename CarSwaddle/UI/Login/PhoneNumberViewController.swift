//
//  PhoneNumberViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 2/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import CarSwaddleStore
import UIKit

final class PhoneNumberViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {

    weak var navigationDelegate: NavigationDelegate?
    @IBOutlet private weak var phoneNumberLabeledTextField: LabeledTextField!
    
    @IBOutlet private weak var saveButton: ActionButton!
    
    private lazy var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: saveButton)
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    var isOnSignUp: Bool = false {
        didSet {
            guard viewIfLoaded != nil else { return }
            contentAdjuster.includeTabBarInKeyboardCalculation = !isOnSignUp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberLabeledTextField.textField.text = User.currentUser(context: store.mainContext)?.phoneNumber
        phoneNumberLabeledTextField.labelTextExistsFont = UIFont.appFont(type: .regular, size: 15)
        phoneNumberLabeledTextField.labelTextNotExistsFont = UIFont.appFont(type: .semiBold, size: 15)
        phoneNumberLabeledTextField.updateLabelFontForCurrentText()
        
        phoneNumberLabeledTextField.textField.autocorrectionType = .no
        phoneNumberLabeledTextField.textField.autocapitalizationType = .none
        phoneNumberLabeledTextField.textField.keyboardType = .phonePad
        phoneNumberLabeledTextField.textField.spellCheckingType = .no
        phoneNumberLabeledTextField.textField.textContentType = .telephoneNumber
        
        phoneNumberLabeledTextField.textField.becomeFirstResponder()
        
        phoneNumberLabeledTextField.textField.addTarget(self, action: #selector(PhoneNumberViewController.didChangeText(textField:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tap)
        
        contentAdjuster.showActionButtonAboveKeyboard = true
        contentAdjuster.includeTabBarInKeyboardCalculation = !isOnSignUp
        contentAdjuster.positionActionButton()
        
        updateActionButtonEnabled()
    }
    
    private var actionButtonIsEnabled: Bool {
        guard let phone = phoneNumberLabeledTextField.textField.text else {
                return false
        }
        return phone.count > 3 && !phone.isEmpty 
    }
    
    private func updateActionButtonEnabled() {
        saveButton.isEnabled = actionButtonIsEnabled
    }
    
    @objc private func didTapView() {
        phoneNumberLabeledTextField.textField.resignFirstResponder()
    }
    
    @objc private func didChangeText(textField: UITextField) {
        updateActionButtonEnabled()
    }
    
    @IBAction private func didTapSave() {
        saveButton.isLoading = true
        
        guard let phoneNumber = phoneNumberLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber.count > 3 else {
            return
        }
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: phoneNumber, token: nil, timeZone: nil, referrerID: nil, in: context) { userObjectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if error == nil {
                        self.navigationDelegate?.didFinish(navigationDelegatingViewController: self)
                    }
                    self.saveButton.isLoading = false
                }
            }
        }
    }
    
}

extension PhoneNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        phoneNumberLabeledTextField.updateLabelFontForCurrentText()
        return true
    }
    
}
