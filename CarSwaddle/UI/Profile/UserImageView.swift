//
//  UserImageView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/6/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleUI
import Store

final class UserImageView: UIImageView {
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image = UIImage.from(color: .gray3)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }
    
    public func configure(withUserID userID: String) {
        self.userID = userID
        
        if let userImage = profileImageStore.getImage(forUserWithID: userID) {
            image = userImage
        } else {
            userNetwork.getProfileImage(userID: userID) { [weak self] url, error in
                guard self?.userID == userID, url != nil else { return }
                DispatchQueue.main.async {
                    self?.image = profileImageStore.getImage(forUserWithID: userID)
                }
            }
        }
    }
    
}
