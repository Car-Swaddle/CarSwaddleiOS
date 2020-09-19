//
//  RateAlertController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 8/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleData
import CarSwaddleUI
import Cosmos
import CarSwaddleStore


class RatingController {
    
    public var userDidRate: () -> Void = {}
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    private var starRatingView: CosmosView?
    private var ratingTextView: UITextView?
    
    public init() { }
    
    public func createRatingAlert(forAutoServiceID autoServiceID: String) -> CustomAlertController {
        let title = NSLocalizedString("Rate your mechanic", comment: "Title of alert when user is rating their mechanic")
        let content = CustomAlertContentView.view(withTitle: title, message: nil)
//        content.attributedTitleText = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.neutral5, .font: UIFont.title as UIFont])
        
        content.addCustomView { customView in
            customView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            let starRatingView = CosmosView(settings: .default)
            starRatingView.rating =  5.0
            starRatingView.settings.updateOnTouch = true
            starRatingView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.addSubview(starRatingView)
            starRatingView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
            starRatingView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            
            starRatingView.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
            starRatingView.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            starRatingView.settings.filledImage = #imageLiteral(resourceName: "star_filled_same_color_border")
            starRatingView.settings.emptyImage = #imageLiteral(resourceName: "star_inactive_gray_border")
            
            self.starRatingView = starRatingView
        }
        
        content.addCustomView { customView in
            customView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            customView.addSubview(textView)
            textView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
            textView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
            textView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
            textView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8.0
            
            textView.font = .title
            textView.tintColor = .action
            
            textView.becomeFirstResponder()
            
            self.ratingTextView = textView
        }
        
        content.addCancelAction()
        let rateAction = self.rateAction(autoServiceID: autoServiceID)
        content.addAction(rateAction)
        
        content.preferredAction = rateAction
        
//        if let button = content.preferredButton {
//            button.titleLabel?.font = UIFont.appFont(type: .regular, size: 17)
//
//            button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
//            button.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .highlighted)
//
//            button.layer.borderWidth = 1
//            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//
//            let background: UIColor = .secondary
//
//            button.setBackgroundImage(UIImage.from(color: background), for: .normal)
//            button.setBackgroundImage(UIImage.from(color: background.color(adjustedBy255Points: -40)), for: .highlighted)
//        }
        
//        content.normalButtons.forEach {
//            configureNormalActionButton($0)
//        }
        
        let alert = CustomAlertController.viewController(contentView: content)
        return alert
    }
    
//    private func configureNormalActionButton(_ button: UIButton) {
//        button.titleLabel?.font = UIFont.appFont(type: .regular, size: 17)
//        button.setTitleColor(.secondary, for: .normal)
//        button.setTitleColor(.viewBackgroundColor1, for: .highlighted)
//
//        button.layer.borderWidth = 1
//        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//
//        let background = UIColor(white255: 244)
//
//        button.setBackgroundImage(UIImage.from(color: background), for: .normal)
//        button.setBackgroundImage(UIImage.from(color: background.color(adjustedBy255Points: -40)), for: .highlighted)
//    }
    
    private func rateAction(autoServiceID: String) -> CustomAlertAction {
        let rateTitle = NSLocalizedString("Rate", comment: "Button title when selected confirms rate of user to mechanic")
        return CustomAlertAction(title: rateTitle) { [weak self] alert in
            guard let rating = self?.starRatingView?.rating,
                let text = self?.ratingTextView?.text else { return }
            store.privateContext { context in
                let json: JSONObject = ["review": [
                    "rating": rating,
                    "text": text
                    ]
                ]
                self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, json: json, in: context) {  objectID, error in
                    if error == nil {
                        print("success!")
                        DispatchQueue.main.async {
                            self?.userDidRate()
                        }
                    } else {
                        print("No success")
                    }
                }
            }
        }
    }
    
}
