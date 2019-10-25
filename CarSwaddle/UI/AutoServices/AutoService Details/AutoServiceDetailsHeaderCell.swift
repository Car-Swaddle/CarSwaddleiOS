//
//  AutoServiceDetailsHeaderCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 5/4/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import Cosmos
import MessageUI


protocol AutoServiceDetailsHeaderCellDelegate: AnyObject {
    func present(viewController: UIViewController, cell: AutoServiceDetailsHeaderCell)
    func dismissMessageComposeViewController(cell: AutoServiceDetailsHeaderCell)
    func didTapReview(cell: AutoServiceDetailsHeaderCell)
}

final class AutoServiceDetailsHeaderCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var dateCardViewWrapper: DateCardViewWrapper!
    @IBOutlet private weak var mechanicNameLabel: UILabel!
    @IBOutlet private weak var autoServiceStatePillView: PillView!
    @IBOutlet private weak var cosmosView: CosmosView!
    @IBOutlet private weak var reviewLabel: UILabel!
    
    weak var delegate: AutoServiceDetailsHeaderCellDelegate?
    
    private var autoService: AutoService?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        mechanicNameLabel.font = UIFont.appFont(type: .semiBold, size: 19)
        cosmosView.backgroundColor = .clear
    }

    func configure(with autoService: AutoService) {
        self.autoService = autoService
        if let scheduledDate = autoService.scheduledDate {
            dateCardViewWrapper.view.configure(with: scheduledDate)
        }
        
        mechanicNameLabel.text = autoService.mechanic?.user?.displayName
        autoServiceStatePillView.configure(with: autoService.status)
        
        reviewLabel.text = autoService.reviewFromUser?.text
        cosmosView.rating = Double(autoService.reviewFromUser?.rating ?? 0.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AutoServiceDetailsHeaderCell.didTapRating))
        cosmosView.addGestureRecognizer(tap)
    }
    
    @objc private func didTapRating() {
        delegate?.didTapReview(cell: self)
    }
    
    @IBAction private func didTapCall() {
        guard let phoneNumber = self.phoneNumber?.replacingOccurrences(of: " ", with: ""),
            let url = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(url)
    }
    
    private var phoneNumber: String? {
        return autoService?.mechanic?.user?.phoneNumber
    }
    
    @IBAction private func didTapSMS() {
        guard MFMessageComposeViewController.canSendText(),
            let phoneNumber = self.phoneNumber else { return }
        let controller = MFMessageComposeViewController()
        controller.recipients = [phoneNumber]
        controller.messageComposeDelegate = self
        delegate?.present(viewController: controller, cell: self)
    }
    
}

extension AutoServiceDetailsHeaderCell: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        delegate?.dismissMessageComposeViewController(cell: self)
    }
    
}


private extension PillView {
    
    func configure(with status: AutoService.Status) {
        switch status {
        case .canceled:
            backgroundColor = .appRed
            text = NSLocalizedString("Canceled", comment: "Status")
        case .completed:
            backgroundColor = .appGreen
            text = NSLocalizedString("Completed", comment: "Status")
        case .inProgress:
            backgroundColor = .blue
            text = NSLocalizedString("In Progress", comment: "Status")
        case .scheduled:
            backgroundColor = .action
            text = NSLocalizedString("Scheduled", comment: "Status")
        }
    }
    
}
