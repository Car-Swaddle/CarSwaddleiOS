//
//  CircleButton.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/19/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


private let inset: CGFloat = 10

@IBDesignable
class CircleButton: UIButton {
    
    @IBInspectable dynamic var buttonColor: UIColor = .black {
        didSet {
            updateBorderColor()
            tintColor = buttonColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height/2
    }
    
    private func setup() {
        updateBorderColor()
        updateBorderWidth()
        
        contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        buttonColor = .titleTextColor
        
        updateBorderColor()
        tintColor = buttonColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateBorderColor()
        tintColor = buttonColor
    }
    
    private func updateBorderColor() {
        layer.borderColor = buttonColor.cgColor
    }
    
    private func updateBorderWidth() {
        layer.borderWidth = 1
    }
    
}
