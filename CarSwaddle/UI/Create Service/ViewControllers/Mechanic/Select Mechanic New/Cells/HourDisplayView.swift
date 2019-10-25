//
//  HourDisplayView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/30/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class HourDisplayView: UIView, NibInstantiating {

    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var hourContentView: UIView!
    
    public var isSelected: Bool = false {
        didSet {
            updateForSelectionState()
        }
    }
    
    var didSelectHour: () -> Void = { }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(HourDisplayView.tap))
        addGestureRecognizer(tap)
        hourLabel.font = UIFont.appFont(type: .semiBold, size: 14, scaleFont: false)
        styleAsUnselected()
        style()
        clipsToBounds = false
        backgroundColor = .clear
    }
    
    private func style() {
        hourContentView.layer.shadowOpacity = 0.2
        hourContentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        hourContentView.layer.shadowRadius = 4
    }
    
    @objc private func tap() {
        didSelectHour()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hourContentView.layer.cornerRadius = hourContentView.frame.height/2
    }
    
    func configure(with timeSlotSeconds: Int) {
        let date = Date.with(secondsFromMidnight: timeSlotSeconds)
        hourLabel.text = hourMinutesPeriodDateFormatter.string(from: date)
    }
    
    private func styleAsSelected() {
        hourContentView.backgroundColor = .action
        hourLabel.textColor = .white
        hourContentView.borderColor = selectedBorderColor
        hourContentView.borderWidth = 1
    }
    
    private func updateForSelectionState() {
        isSelected ? styleAsSelected() : styleAsUnselected()
    }
    
    private var selectedBorderColor: UIColor {
        if #available(iOS 13, *) {
//            return .clear
            return traitCollection.userInterfaceStyle == .dark ? .white : .clear
        } else {
            return .clear
        }
    }
    
    private var unselectedBorderColor: UIColor {
        if #available(iOS 13, *) {
            return .clear
//            return traitCollection.userInterfaceStyle == .dark ? .white : .clear
        } else {
            return .clear
        }
    }
    
    private var unselectedBackgroundColor: UIColor {
        return .content
//        if #available(iOS 13, *) {
////            return .clear
////            return traitCollection.userInterfaceStyle == .dark ? .background : .white
//        } else {
////            return .clear
//        }
    }
    
    private func styleAsUnselected() {
        hourContentView.backgroundColor = unselectedBackgroundColor
        hourLabel.textColor = .text
        hourContentView.borderColor = unselectedBorderColor
        hourContentView.borderWidth = 1
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForSelectionState()
    }
    
}
