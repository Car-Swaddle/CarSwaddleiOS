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
//
//private let selectedColor: UIColor = .tertiaryBackgroundColor
//private let unselectedColor: UIColor = UIColor.tertiaryBackgroundColor.color(adjustedBy255Points: -15)

final class AutoServiceCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var mechanicLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var vehicleLabel: UILabel!
    @IBOutlet private weak var serviceTypeLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    
    @IBOutlet private weak var mechanicNameStackView: UIStackView!
    @IBOutlet private weak var locationStackView: UIStackView!
    @IBOutlet private weak var vehicleStackView: UIStackView!
    @IBOutlet private weak var serviceTypeStackView: UIStackView!
    @IBOutlet private weak var notesStackView: UIStackView!
    @IBOutlet private weak var serviceContentView: UIView!
    
    @IBOutlet private weak var dateCardViewWrapper: DateCardViewWrapper!
    
    @IBOutlet private var dateCardViewHeightConstraint: NSLayoutConstraint!
    
    
    private var selectedColor: UIColor { UIColor.secondaryBackgroundColor.color(adjustedBy255Points: -15) }
    private var unselectedColor: UIColor { .secondaryBackgroundColor }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        serviceTypeStackView.isHiddenInStackView = true
        notesStackView.isHiddenInStackView = true
        backgroundColor = .primaryBackgroundColor
        contentView.backgroundColor = .primaryBackgroundColor
        
        serviceContentView.backgroundColor = .secondaryBackgroundColor
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mechanicLabel.text = ""
        locationLabel.text = ""
        vehicleLabel.text = ""
        serviceTypeLabel.text = ""
        notesLabel.text = ""
    }
    
    func configure(with autoService: AutoService) {
        if let date = autoService.scheduledDate {
            dateCardViewWrapper.view.configure(with: date)
        }
        
        mechanicLabel.text = autoService.mechanic?.user?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
        vehicleLabel.text = autoService.vehicle?.name
        serviceTypeLabel.text = autoService.serviceEntities.first?.entityType.localizedString
        notesLabel.text = autoService.notes
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateHighlight(animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateHighlight(animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHighlight(animated: false)
    }
    
    private func updateHighlight(animated: Bool) {
        let color = isHighlighted || isSelected ? selectedColor : unselectedColor
        let updateColor = { self.serviceContentView.backgroundColor = color }
        if animated {
            UIView.animate(withDuration: 0.25) {
                updateColor()
            }
        } else {
            updateColor()
        }
    }
    
}
