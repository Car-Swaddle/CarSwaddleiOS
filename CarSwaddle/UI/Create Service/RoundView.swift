//
//  RoundView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundView: UIView {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
    
}

@IBDesignable
open class RoundLabeledView: RoundView {
    
    @IBInspectable
    public var labelText: String? {
        didSet {
            label.text = labelText
        }
    }
    
    public lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(type: .regular, size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        addSubview(label)
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor).isActive = true
    }
    
}

@IBDesignable
open class AutoServiceProgressCircleView: RoundLabeledView {
    
    public enum Status: Int {
        case current
        case complete
        case incomplete
    }
    
    public var status: Status = .incomplete {
        didSet {
            updateForCurrentStatus()
        }
    }
    
    @IBInspectable
    public var ibStatus: Int {
        set { status = Status(rawValue: newValue) ?? .incomplete }
        get { return status.rawValue }
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
//        updateForCurrentStatus()
    }
    
    private func updateForCurrentStatus() {
        switch status {
        case .complete:
            configureForComplete()
        case .current:
            configureForCurrent()
        case .incomplete:
            configureForIncomplete()
        }
    }
    
    private func configureForComplete() {
        label.textColor = .white
        backgroundColor = .secondary
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
    
    private func configureForCurrent() {
        label.textColor = .white
        backgroundColor = .alternateSelectionColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    private func configureForIncomplete() {
        label.textColor = .black
        backgroundColor = .gray3
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
    
}

