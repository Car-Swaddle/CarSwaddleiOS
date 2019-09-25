//
//  FocusedCollectionViewCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

private let selectedImageViewLength: CGFloat = 27
private let selectedImageViewContenInset: CGFloat = 6

class FocusedCollectionViewCell: UICollectionViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondary
        
        let selectedImageView = UIImageView()
        selectedImageView.image = #imageLiteral(resourceName: "checkmark").withRenderingMode(.alwaysTemplate)
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.tintColor = .white
        
        view.addSubview(selectedImageView)
        
        selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        selectedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: selectedImageViewContenInset).isActive = true
        selectedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -selectedImageViewContenInset).isActive = true
        selectedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -selectedImageViewContenInset).isActive = true
        selectedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: selectedImageViewContenInset).isActive = true
        
        return view
    }()
    
    private func setup() {
        contentView.backgroundColor = .secondaryBackgroundColor
        
        contentView.layer.cornerRadius = defaultCornerRadius
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4
        
        clipsToBounds = false
        layer.masksToBounds = false
        
        addSubview(selectedView)
        
        setupSelectedImageView()
        
        updateViewForSelectedState()
    }
    
    private func setupSelectedImageView() {
        selectedView.heightAnchor.constraint(equalToConstant: selectedImageViewLength).isActive = true
        selectedView.widthAnchor.constraint(equalToConstant: selectedImageViewLength).isActive = true
        selectedView.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        selectedView.centerYAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        
        selectedView.layer.cornerRadius = selectedImageViewLength/2
        
        selectedView.layer.shadowOpacity = 0.15
        selectedView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedView.layer.shadowRadius = 4
    }
    
    override var isSelected: Bool {
        didSet {
            updateViewForSelectedState()
        }
    }
    
    private func updateViewForSelectedState() {
        if isSelected {
            configureForSelected()
        } else {
            configureForUnselected()
        }
    }

    private func configureForSelected() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.secondary.cgColor
        selectedView.isHiddenInStackView = false
    }
    
    private func configureForUnselected() {
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
        selectedView.isHiddenInStackView = true
    }
    
}
