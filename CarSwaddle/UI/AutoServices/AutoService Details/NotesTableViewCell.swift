//
//  NotesTableViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 5/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleStore
import CarSwaddleData
import UIKit


final class NotesTableViewCell: UITableViewCell, NibRegisterable {
    
    var didBeginEditing: () -> () = {}
    
    var showHairlineView: Bool = true {
        didSet {
            hairlineView?.isHidden = !showHairlineView
        }
    }
    
    @IBOutlet private weak var notesLabel: UILabel!
    @IBOutlet private weak var notesTextView: UITextView!
    
    @IBOutlet private weak var notesContentView: UIView!
    
    private var autoService: AutoService?
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    private var timer: Timer?
    private var hairlineView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notesLabel.font = UIFont.appFont(type: .regular, size: 15)
        notesTextView.font = UIFont.appFont(type: .regular, size: 17)
        notesTextView.delegate = self
        
        notesContentView.layer.cornerRadius = defaultCornerRadius
        notesContentView.layer.borderColor = UIColor.gray5.cgColor
        notesContentView.layer.borderWidth = UIView.hairlineLength
        
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        let view = addHairlineView(toSide: .bottom, color: hairlineColor, size: 1.0, insets: insets)
        view.layer.cornerRadius = 0.5
        self.hairlineView = view
        
        selectionStyle = .none
    }
    
    private var hairlineColor: UIColor {
        if #available(iOS 13.0, *) {
            return .opaqueSeparator
        } else {
            return .gray3
        }
    }
    
    func configure(with autoService: AutoService) {
        self.autoService = autoService
        notesTextView.text = autoService.notes
        
        hairlineView?.isHidden = autoService.status != .canceled
    }
    
}

extension NotesTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NotesTableViewCell.updateNotes), userInfo: nil, repeats: false)
    }
    
    @objc private func updateNotes() {
        guard let autoServiceID = autoService?.identifier,
            let notesText = notesTextView.text else { return }
        
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, notes: notesText, in: privateContext) { autoServiceObjectID, error in
                if let error = error {
                    print("error updating notes: \(error)")
                }
            }
        }
    }
    
}

