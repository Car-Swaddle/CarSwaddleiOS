//
//  PhoneNumberViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 2/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store

final class PhoneNumberViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {

    weak var navigationDelegate: NavigationDelegate?
    @IBOutlet private weak var phoneNumberLabeledTextField: LabeledTextField!
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
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
    }
    
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        let previousButton = navigationItem.rightBarButtonItem
        let spinner = UIBarButtonItem.activityBarButtonItem(with: .gray)
        
        navigationItem.rightBarButtonItem = spinner
        
        guard let phoneNumber = phoneNumberLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber.count > 3 else {
            return
        }
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: phoneNumber, token: nil, timeZone: nil, in: context) { userObjectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if error == nil {
                        self.navigationDelegate?.didFinish(navigationDelegatingViewController: self)
                    }
                    self.navigationItem.rightBarButtonItem = previousButton
                }
            }
        }
    }
    
}

extension PhoneNumberViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        phoneNumberLabeledTextField.updateLabelFontForCurrentText()
        return true
    }
    
}
