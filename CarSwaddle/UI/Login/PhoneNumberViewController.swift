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
    
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.text = User.currentUser(context: store.mainContext)?.phoneNumber
    }
    
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        let previousButton = navigationItem.rightBarButtonItem
        let spinner = UIBarButtonItem.activityBarButtonItem(with: .gray)
        
        navigationItem.rightBarButtonItem = spinner
        
        guard let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
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
