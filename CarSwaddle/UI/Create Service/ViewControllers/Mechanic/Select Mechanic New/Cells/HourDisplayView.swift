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
    
    func styleAsSelected() {
        hourContentView.backgroundColor = .secondary
        hourLabel.textColor = .white
    }
    
    func styleAsUnselected() {
        hourContentView.backgroundColor = .white
//        hourContentView.layer.borderColor = UIColor.viewBackgroundColor1.withAlphaComponent(0.6).cgColor
//        hourContentView.layer.borderWidth = UIView.hairlineLength
        hourLabel.textColor = .black
    }
    
}
