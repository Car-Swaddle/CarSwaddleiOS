//
//  AddCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class AddCollectionViewCell: UICollectionViewCell, NibRegisterable {
    
    var showGuideLabel: Bool = false {
        didSet { updateGuideLabelDisplay() }
    }
    
    @IBOutlet private weak var guideLabel: UILabel!
    
    func nudge() {
        shake()
        UIView.animate(withDuration: 0.25) {
            self.borderColor = .secondary
            self.borderWidth = 2
        }
    }
    
    private func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = defaultCornerRadius
        guideLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        
        updateGuideLabelDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showGuideLabel = false
    }
    
    private func updateGuideLabelDisplay() {
        guideLabel.isHiddenInStackView = !showGuideLabel
    }

}
