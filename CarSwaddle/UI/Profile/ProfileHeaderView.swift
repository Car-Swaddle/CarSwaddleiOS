//
//  ProfileImageView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleStore
import CarSwaddleUI

protocol ProfileHeaderViewDelegate: AnyObject {
    func didSelectCamera(headerView: ProfileHeaderView)
    func didSelectCameraRoll(headerView: ProfileHeaderView)
    func presentAlert(alert: UIAlertController, headerView: ProfileHeaderView)
}

final class ProfileHeaderView: UIView, NibInstantiating {

    public func configure(with user: User) {
        imageView.configure(withUserID: user.identifier)
    }
    
    public weak var delegate: ProfileHeaderViewDelegate?
    
    
    @IBOutlet private weak var imageView: UserImageView!
    @IBOutlet private weak var editButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction private func didTapEdit() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addCancelAction()
        
        delegate?.presentAlert(alert: alert, headerView: self)
    }
    
    
    private var cameraAction: UIAlertAction {
        let title = NSLocalizedString("Camera", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            self.delegate?.didSelectCamera(headerView: self)
        }
    }
    
    private var cameraRollAction: UIAlertAction {
        let title = NSLocalizedString("Camera Roll", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            self.delegate?.didSelectCameraRoll(headerView: self)
        }
    }
    
}
