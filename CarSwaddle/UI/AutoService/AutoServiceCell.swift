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

    
    
    @IBOutlet weak var scheduledDateLabel: UILabel!
    @IBOutlet weak var mechanicLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var serviceTypeLabel: UILabel!
    
//    private let locationManager: LocationManager
    
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
    }
    
    func configure(with autoService: AutoService) {
        print("autoService: \(autoService)")
        if let date = autoService.scheduledDate {
            scheduledDateLabel.text = dateFormatter.string(from: date)
        }
        
        mechanicLabel.text = autoService.mechanic?.user?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
        vehicleLabel.text = autoService.vehicle?.name
        serviceTypeLabel.text = autoService.serviceEntities.first?.entityType.localizedString
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}


extension ServiceEntity.EntityType {
    
    var localizedString: String {
        switch self {
        case .oilChange:
            return NSLocalizedString("Oil Change", comment: "Type of oil change")
        }
    }
    
}
