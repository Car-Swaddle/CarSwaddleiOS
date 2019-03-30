//
//  LocationSearchCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit
import CarSwaddleUI

private let titleAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.appFont(type: .regular, size: 15) as Any,
    .foregroundColor: UIColor.black
]
private let subtitleAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.appFont(type: .regular, size: 15) as Any,
    .foregroundColor: UIColor.gray4
]

private let titleHighlightAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.appFont(type: .semiBold, size: 15) as Any,
    .foregroundColor: UIColor.black
]
private let subtitleHighlightAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.appFont(type: .semiBold, size: 15) as Any,
    .foregroundColor: UIColor.black
]

final class LocationSearchCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    func configure(with searchItem: MKLocalSearchCompletion) {
        titleLabel.attributedText = attributedTitle(from: searchItem)
        subtitleLabel.attributedText = attributedSubtitle(from: searchItem)
    }
    
    private func attributedTitle(from searchItem: MKLocalSearchCompletion) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: searchItem.title, attributes: titleAttributes)
        attributedString.setAttributes(titleHighlightAttributes, ranges: searchItem.titleHighlightRanges.nsRanges)
        return attributedString.copy() as! NSAttributedString
    }
    
    private func attributedSubtitle(from searchItem: MKLocalSearchCompletion) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: searchItem.subtitle, attributes: subtitleAttributes)
        attributedString.setAttributes(subtitleHighlightAttributes, ranges: searchItem.subtitleHighlightRanges.nsRanges)
        return attributedString.copy() as! NSAttributedString
    }
    
//    private func
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension NSMutableAttributedString {
    
    func setAttributes(_ attributes: [NSAttributedString.Key: Any], ranges: [NSRange]) {
        for range in ranges {
            setAttributes(titleHighlightAttributes, range: range)
        }
    }
    
}

extension Array where Element: NSValue {
    
    var nsRanges: [NSRange] {
        var ranges: [NSRange] = []
        for value in self {
            guard let range = value as? NSRange else { continue }
            ranges.append(range)
        }
        return ranges
    }
    
}
