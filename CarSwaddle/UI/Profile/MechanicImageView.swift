//
//  MechanicImageView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/16/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleData
import Store

final class MechanicImageView: UIImageView {
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var mechanicID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultImage()
        layer.cornerRadius = 8
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }
    
    public func configure(withMechanicID mechanicID: String) {
        self.mechanicID = mechanicID
        
        if let userImage = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext) {
            image = userImage
        } else {
            setDefaultImage()
            store.privateContext { [weak self] privateContext in
                self?.mechanicNetwork.getProfileImage(mechanicID: mechanicID, in: privateContext) { fileURL, error in
                    guard self?.mechanicID == mechanicID else { return }
                    DispatchQueue.main.async {
                        if let image = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext) {
                            self?.image = image
                        } else {
                            self?.setDefaultImage()
                        }
                    }
                }
            }
        }
    }
    
    private func setDefaultImage() {
        image = UIImage.from(color: .gray3)
    }
    
}

