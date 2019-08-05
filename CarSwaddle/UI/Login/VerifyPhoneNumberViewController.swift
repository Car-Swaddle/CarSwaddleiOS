//
//  VerifyPhoneNumberViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 2/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest
import Store

private let codeNumberOfDigits = 5

final class VerifyPhoneNumberViewController: UIViewController, NavigationDelegating, OneTimeCodeViewControllerDelegate {
    
    weak var navigationDelegate: NavigationDelegate?
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var userService: UserService = UserService(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(oneTimeViewController)
        view.addSubview(oneTimeViewController.view)
        oneTimeViewController.view.pinFrameToSuperViewBounds()
        oneTimeViewController.didMove(toParent: self)
        
        _ = oneTimeViewController.oneTimeCodeEntryView.becomeFirstResponder()
        
        oneTimeViewController.resendCodeButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.resendCodeButton.tintColor = .viewBackgroundColor1
        
        oneTimeViewController.updatePhoneNumberButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.updatePhoneNumberButton.tintColor = .viewBackgroundColor1
        
        oneTimeViewController.verifyPhoneNumberTitleLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.verifyPhoneNumberDescriptionLabel.font = UIFont.appFont(type: .regular, size: 15)
        
        sendSMSVerification()
        
        title = NSLocalizedString("Verify Phone number", comment: "Title of screen for verifying the user's phone number")
    }
    
    private lazy var oneTimeViewController: OneTimeCodeViewController = {
        let viewController = OneTimeCodeViewController.viewControllerFromStoryboard()
        viewController.delegate = self
        viewController.numberOfDigits = codeNumberOfDigits
        viewController.phoneNumber = User.currentUser(context: store.mainContext)?.phoneNumber ?? ""
        return viewController
    }()
    
    func codeDidChange(code: String, viewController: OneTimeCodeViewController) {
        guard code.count == codeNumberOfDigits else { return }
        oneTimeViewController.view.endEditing(true)
        store.privateContext { [weak self] privateContext in
            self?.userNetwork.verifySMS(withCode: code, in: privateContext) { userObjectID, error in
                guard let self = self else { return }
                if error == nil {
                    print("success")
                    DispatchQueue.main.async {
                        self.navigationDelegate?.didFinish(navigationDelegatingViewController: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showErrorAlert()
                    }
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let title = NSLocalizedString("Looks like something isn't right", comment: "Error title")
        let message = NSLocalizedString("The code you entered doesn't match the code we sent. Please type the code again.\n\nIs %@ not your phone number? Tap `Update phone number` to update.", comment: "Error title")
        
        let formattedMessage = String(format: message, User.currentUser(context: store.mainContext)?.phoneNumber ?? "")
        let alertContent = CustomAlertContentView.view(withTitle: title, message: formattedMessage)
        
        alertContent.addOkayAction { [weak self] action in
            self?.oneTimeViewController.oneTimeCodeEntryView.setText("")
            _ = self?.oneTimeViewController.oneTimeCodeEntryView.becomeFirstResponder()
        }
        
        let tryAgainTitle = NSLocalizedString("Update phone number", comment: "button title that will show a screen to update their phone number")
        let updatePhoneNumberAction = CustomAlertAction(title: tryAgainTitle) { [weak self] action in
            self?.showUpdatePhoneNumber()
        }
        
        alertContent.addAction(updatePhoneNumberAction)
        
        let alert = CustomAlertController.viewController(contentView: alertContent)
        present(alert, animated: true, completion: nil)
    }
    
    func didSelectResendVerificationCode(viewController: OneTimeCodeViewController) {
        sendSMSVerification()
    }
    
    func didSelectUpdatePhoneNumberButton(viewController: OneTimeCodeViewController) {
        showUpdatePhoneNumber()
    }
    
    private func showUpdatePhoneNumber() {
        let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
        phoneNumber.navigationDelegate = self
        show(phoneNumber, sender: self)
    }
    
    private func sendSMSVerification() {
        userService.sendSMSVerification { error in
            if error == nil {
                print("no error resending")
            } else {
                print("error resending")
            }
        }
    }
    
}

extension VerifyPhoneNumberViewController: NavigationDelegate {
    
    func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController) {
        let verify = VerifyPhoneNumberViewController()
        show(verify, sender: self)
    }
    
}
