//
//  AutoServiceCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 12/4/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d h:mm a"
    return formatter
}()

final class AutoServiceCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var scheduledDateLabel: UILabel!
    @IBOutlet private weak var mechanicLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var vehicleLabel: UILabel!
    @IBOutlet private weak var serviceTypeLabel: UILabel!
    
    @IBOutlet private weak var notesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scheduledDateLabel.text = ""
        mechanicLabel.text = ""
        locationLabel.text = ""
        vehicleLabel.text = ""
        serviceTypeLabel.text = ""
        notesLabel.text = ""
    }
    
    func configure(with autoService: AutoService) {
        if let date = autoService.scheduledDate {
            scheduledDateLabel.text = dateFormatter.string(from: date)
        }
        
        mechanicLabel.text = autoService.mechanic?.user?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
        vehicleLabel.text = autoService.vehicle?.name
        serviceTypeLabel.text = autoService.serviceEntities.first?.entityType.localizedString
        notesLabel.text = autoService.notes
    }
    
}

