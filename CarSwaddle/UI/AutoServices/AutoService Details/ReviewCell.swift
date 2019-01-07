//
//  ReviewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Cosmos
import Store
import CarSwaddleData

protocol ReviewCellProtocol: AnyObject {
    func didSelectRate()
}

final class ReviewCell: UITableViewCell, NibRegisterable {

    public weak var delegate: ReviewCellProtocol?
    
    @IBOutlet private weak var starRatingView: CosmosView!
    @IBOutlet private weak var ratingTextLabel: UILabel!
    @IBOutlet private weak var addReviewButton: UIButton!
    
    private var autoService: AutoService!
    
    public func configure(with autoService: AutoService) {
        self.autoService = autoService
        if let review = autoService.reviewFromUser {
            starRatingView.rating = Double(review.rating)
            ratingTextLabel.text = review.text
            starRatingView.isHiddenInStackView = false
            ratingTextLabel.isHiddenInStackView = false
            addReviewButton.isHiddenInStackView = true
        } else {
            starRatingView.isHiddenInStackView = true
            ratingTextLabel.isHiddenInStackView = true
            addReviewButton.isHiddenInStackView = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        starRatingView.isUserInteractionEnabled = false
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction private func didTapAddReview() {
        delegate?.didSelectRate()
    }
    
}
