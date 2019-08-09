//
//  TimeSlotCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/30/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store


let hourMinutesPeriodDateFormatter: DateFormatter = {
    let d = DateFormatter()
    d.amSymbol = NSLocalizedString("am", comment: "symbol for AM. Lowercase preferred")
    d.pmSymbol = NSLocalizedString("pm", comment: "symbol for PM. Lowercase preferred")
    d.dateFormat = "h:mm a"
    return d
}()

class TimeSlotCollectionViewCell: UICollectionViewCell, NibRegisterable {

    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var timeLabelContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.font = UIFont.appFont(type: .semiBold, size: 15, scaleFont: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timeLabelContentView.layer.cornerRadius = timeLabelContentView.frame.height/2
    }
    
    func configure(with timeSlotSeconds: Int) {
        let date = Date.with(secondsFromMidnight: timeSlotSeconds)
        timeLabel.text = hourMinutesPeriodDateFormatter.string(from: date)
    }
    
    

}



extension Date {
    
    static func date(secondsFromMidnight: Int) -> Date {
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        return cal.date(bySettingHour: 0, minute: 0, second: secondsFromMidnight, of: date)!
    }
    
}
