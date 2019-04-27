//
//  LabeledInfoCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 4/26/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Lottie

final class LabeledInfoCell: UITableViewCell, NibRegisterable {
    
    var errorViewIsHidden: Bool = true {
        didSet {
            updateErrorViewHiddenStatus()
        }
    }
    
    var descriptionText: String? {
        didSet {
            updateText()
        }
    }
    
    var valueText: String? {
        didSet {
            updateText()
        }
    }
    
    private func updateText() {
        if let valueText = valueText {
            descriptionLabel.isHiddenInStackView = false
            descriptionLabel.text = descriptionText
            valueLabel.text = valueText
        } else {
            descriptionLabel.isHiddenInStackView = true
            valueLabel.text = descriptionText
        }
    }
    
    private func updateErrorViewHiddenStatus() {
        animationView.isHiddenInStackView = errorViewIsHidden
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryType = .disclosureIndicator
        updateErrorViewHiddenStatus()
        
        valueLabel?.font = UIFont.appFont(type: .regular, size: 17)
        descriptionLabel?.font = UIFont.appFont(type: .regular, size: 15)
        
        animationView.animation = Animation.named("circle-pulse")
        animationView.animationSpeed = 0.7
        animationView.loopMode = .loop
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animationView.play()
    }
    
}
