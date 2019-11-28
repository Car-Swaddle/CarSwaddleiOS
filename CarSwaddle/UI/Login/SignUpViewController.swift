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
import Authentication
import SafariServices
import Firebase


private let stripeAgreementURLString = "https://stripe.com/us/connect-account/legal"
private let carSwaddleAgreementURLString = "https://carswaddle.net/terms-of-use/"
private let carSwaddlePrivacyPolicyURLString = "https://carswaddle.net/privacy-policy/"

final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    static var storyboardName: String {
        return "LoginViewController"
    }
    
    var makeTextFieldFirstResponderOnLoad: Bool = false
    
//    private lazy var fadeTransitionDelegate: FadeTransitionDelegate = FadeTransitionDelegate()
    
    static func create() -> SignUpViewController {
        let signUp = SignUpViewController.viewControllerFromStoryboard()
//        signUp.transitioningDelegate = signUp.fadeTransitionDelegate
//        signUp.modalPresentationStyle = .custom
        return signUp
    }
    
    private let auth = Auth(serviceRequest: serviceRequest)
    
    public static let stripeAgreementURL: URL! = URL(string: stripeAgreementURLString)!
    public static let carSwaddleAgreementURL: URL! = URL(string: carSwaddleAgreementURLString)!
    public static let carSwaddlePrivacyURL: URL! = URL(string: carSwaddlePrivacyPolicyURLString)!

    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var agreementTextView: UITextView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var agreementTextViewHeightConstraint: NSLayoutConstraint!
    
    private var signUpTask: URLSessionDataTask?
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let login = segue.destination as? LoginViewController else { return }
////        login.transitioningDelegate = login.fadeTransitionDelegate
//        login.modalPresentationStyle = .custom
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        
        spinner.isHiddenInStackView = true
        updateSignUpEnabledness()
        
        let tintColor = UIColor.textColor2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: UIFont.appFont(type: .semiBold, size: 15) as Any]
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "placeholder text"), attributes: placeholderAttributes)
        emailTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "placeholder text"), attributes: placeholderAttributes)
        passwordTextField.textColor = .white
        
        signupButton.setTitleColor(.white, for: .normal)
        
        passwordTextField.tintColor = .white
        emailTextField.tintColor = .white
        
        emailTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        passwordTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        
        agreementTextViewHeightConstraint.constant = agreementTextView.contentSize.height
        
        setupAgreementTextView()
        
        signupButton.configureForClear()
        
        if makeTextFieldFirstResponderOnLoad {
            emailTextField.becomeFirstResponder()
        }
    }
    
    @IBAction private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupAgreementTextView() {
        let tintColor = UIColor.textColor2
        
        let termsOfUseText = "Car Swaddle Terms of Use Agreement"
        let privacyPolicyText = "Car Swaddle Privacy Policy"
        let stripeText = "Stripe Connected Account Agreement"
        
        let text = "By registering your account, you agree to the \(termsOfUseText), the \(privacyPolicyText) and the \(stripeText)."
        
        let carSwaddleAgreementRange = (text as NSString).range(of: termsOfUseText)
        let privacyPolicyRange = (text as NSString).range(of: privacyPolicyText)
        let connectAgreementRange = (text as NSString).range(of: stripeText)
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: tintColor, .font: UIFont.appFont(type: .regular, size: 11) as Any])
        
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.stripeAgreementURL), range: connectAgreementRange)
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.carSwaddleAgreementURL), range: carSwaddleAgreementRange)
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.carSwaddlePrivacyURL), range: privacyPolicyRange)
        
        let textViewLinkAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.textColor2,
            .underlineColor: UIColor.textColor2,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.appFont(type: .regular, size: 11, scaleFont: false) as Any
        ]
        
        agreementTextView.textAlignment = .center
        agreementTextView.linkTextAttributes = textViewLinkAttributes
        agreementTextView.isSelectable = true
        
        agreementTextView.attributedText = attributedText.copy() as? NSAttributedString
        agreementTextView.delegate = self
        
        agreementTextViewHeightConstraint.constant = agreementTextView.contentSize.height
    }
    
    private func linkAttributes(with url: URL) -> [NSAttributedString.Key: Any] {
        let attributes: [NSAttributedString.Key: Any] = [
            .link: url
        ]
        return attributes
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateSignUpEnabledness()
    }
    
    private func updateSignUpEnabledness() {
        signupButton.isEnabled = signUpIsAllowed
    }
    
    private var signUpIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    private var safariConfiguration: SFSafariViewController.Configuration {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        return configuration
    }
    
    private func showSafari(with url: URL) {
        let stripeSafariViewController = SFSafariViewController(url: url, configuration: safariConfiguration)
        present(stripeSafariViewController, animated: true, completion: nil)
    }
    
    @IBAction private func didTapSignUp() {
        signUpIfAllowed()
    }
    
    @IBAction private func didTapGoToLogin() {
        let login = LoginViewController.create()
        show(login, sender: self)
    }
    
    private func signUpIfAllowed() {
        guard signUpIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateSignUpEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        signupButton.isHiddenInStackView = true
        
        store.privateContext { [weak self] context in
            self?.signUpTask = self?.auth.signUp(email: email, password: password, context: context) { error in
                guard error == nil && AuthController().token != nil else {
                    if let networkError = error as? NetworkRequestError {
                        print("login error: \(networkError)")
                    }
                    DispatchQueue.main.async {
                        self?.spinner.isHiddenInStackView = true
                        self?.spinner.stopAnimating()
                        
                        self?.signupButton.isHiddenInStackView = false
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.trackSignUp()
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
    }
    
    private func trackSignUp() {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: "email"
        ])
    }

}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signUpIfAllowed()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignUpEnabledness()
        return true
    }
    
}

extension SignUpViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if SignUpViewController.stripeAgreementURL == URL || SignUpViewController.carSwaddleAgreementURL == URL || SignUpViewController.carSwaddlePrivacyURL == URL {
            showSafari(with: URL)
        }
        
        return false
    }
    
}


public extension String {
    
    private static let validateEmailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", String.validateEmailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        return self.count > 3
    }
    
}



extension SignUpViewController: FadeAnimationControllerFrameSpecifying {
    var newFrameOfViewToBeTransitioned: CGRect { return logoImageView.frame }
    var viewBeingTransitionedTo: UIView { return logoImageView }
}

extension SignUpViewController: FadeAnimationControllerViewMovable {
    var viewToBeTransitioned: UIView { return logoImageView }
    var frameOfViewToBeMoved: CGRect { return logoImageView.frame }
}
