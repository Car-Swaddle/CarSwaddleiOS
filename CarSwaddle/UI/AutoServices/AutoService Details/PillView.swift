//
//  PillView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 5/4/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

private let defaultVerticalInset: CGFloat = 8
private let defaultHorizontalInset: CGFloat = 13

@IBDesignable
final class PillView: UIView {
    
    @IBInspectable
    public var text: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(type: .semiBold, size: 17)
        label.textColor = .white
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .vertical)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = frame.height/2
    }
    
    @IBInspectable
    public var topInset: CGFloat {
        get { return edgeInsets.top }
        set { edgeInsets.top = newValue }
    }
    
    @IBInspectable
    public var bottomInset: CGFloat {
        get { return edgeInsets.bottom }
        set { edgeInsets.bottom = newValue }
    }
    
    @IBInspectable
    public var leftInset: CGFloat {
        get { return edgeInsets.left }
        set { edgeInsets.left = newValue }
    }
    
    @IBInspectable
    public var rightInset: CGFloat {
        get { return edgeInsets.right }
        set { edgeInsets.right = newValue }
    }
    
    
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: defaultVerticalInset, left: defaultHorizontalInset, bottom: defaultVerticalInset, right: defaultHorizontalInset) {
        didSet { updateInsets() }
    }
    
    private var labelLeadingConstraint: NSLayoutConstraint!
    private var labelTrailingConstraint: NSLayoutConstraint!
    private var labelTopConstraint: NSLayoutConstraint!
    private var labelBottomConstraint: NSLayoutConstraint!
    
    private func setup() {
        addSubview(label)
        let constraints = label.pinFrameToSuperViewBounds(insets: edgeInsets)
        labelLeadingConstraint = constraints?.left
        labelTrailingConstraint = constraints?.right
        labelTopConstraint = constraints?.top
        labelBottomConstraint = constraints?.bottom
    }
    
    private func updateInsets() {
        labelLeadingConstraint.constant = edgeInsets.left
        labelTrailingConstraint.constant = edgeInsets.right
        labelLeadingConstraint.constant = edgeInsets.top
        labelBottomConstraint.constant = edgeInsets.bottom
    }
    
}
