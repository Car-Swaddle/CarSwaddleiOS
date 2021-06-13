//
//  ServicesEmptyStateView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 6/12/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Lottie

class ServicesEmptyStateView: UIView, NibInstantiating {
    
    @IBOutlet private weak var letsGetStartedLabel: UILabel!
    @IBOutlet private weak var secondaryLabel: UILabel!
    @IBOutlet private weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        letsGetStartedLabel.font = UIFont.appFont(type: .regular, size: 24)
        secondaryLabel.font = UIFont.appFont(type: .regular, size: 16)
        
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
    }
    
}


final class ServicesEmptyStateViewWrapper: UIView {
    
    lazy var view: ServicesEmptyStateView = ServicesEmptyStateView.viewFromNib()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        addSubview(view)
        view.pinFrameToSuperViewBounds()
    }
    
}
