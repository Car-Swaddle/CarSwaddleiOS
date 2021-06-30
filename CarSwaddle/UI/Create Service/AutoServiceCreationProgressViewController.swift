//
//  AutoServiceCreationProgressViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore
import CarSwaddleData

protocol AutoServiceCreationProgressDelegate: AnyObject {
    func updateHeight(newHeight: CGFloat)
}

private let normalHeight: CGFloat = 120
private let priceHeight: CGFloat = 120

class AutoServiceCreationProgressViewController: UIViewController, StoryboardInstantiating {
    
    weak var delegate: AutoServiceCreationProgressDelegate?
    
    enum State {
        case location
        case mechanic
        case details
        case payment
    }
    
    public var currentState: State = .location {
        didSet {
            updateViewForCurrentState()
        }
    }
    
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var mechanicLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    @IBOutlet private weak var locationCircle: AutoServiceProgressCircleView!
    @IBOutlet private weak var mechanicCircle: AutoServiceProgressCircleView!
    @IBOutlet private weak var detailsCircle: AutoServiceProgressCircleView!
    
    @IBOutlet private weak var lineView: UIView!
    
    private lazy var stateViews: [UIView] = [locationLabel, mechanicLabel, detailsLabel, locationCircle, mechanicCircle, detailsCircle]
    
    private lazy var priceView: PriceView = {
        let priceView = PriceView.viewFromNib()
        priceView.translatesAutoresizingMaskIntoConstraints = false
        priceView.backgroundColor = .clear
        return priceView
    }()
    
    private let completedColor: UIColor = .action
    private let currentlySelectedColor: UIColor = .appRed
    private let notCompletedColor: UIColor = .gray3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.font = UIFont.appFont(type: .regular, size: 17)
        mechanicLabel.font = UIFont.appFont(type: .regular, size: 17)
        detailsLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        updateViewForCurrentState()
        
        delegate?.updateHeight(newHeight: heightForCurrentState)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        delegate?.updateHeight(newHeight: heightForCurrentState)
    }
    
    func resetUI() {
        priceView.resetUI()
    }
    
    func configure(with autoService: AutoService) {
        priceView.configure(with: autoService)
    }
    
    private func updateViewForCurrentState() {
        locationCircle.status = locationStatus
        mechanicCircle.status = mechanicStatus
        detailsCircle.status = detailsStatus
        
        delegate?.updateHeight(newHeight: heightForCurrentState)
        
        updatePriceViewForCurrentState()
    }
    
    private func updatePriceViewForCurrentState() {
        switch currentState {
        case .location, .mechanic:
            priceView.isHiddenInStackView = true
            stateViewsAreHidden = false
        case .payment, .details:
            priceView.isHiddenInStackView = false
            stateViewsAreHidden = true
            if priceView.superview == nil {
                view.addSubview(priceView)
                priceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
                priceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16).isActive = true
                let topConstraint = priceView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
                topConstraint.isActive = true
//                let bottomConstraint = priceView.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16)
//                bottomConstraint.priority = .defaultLow
//                bottomConstraint.isActive = true
            }
        }
    }
    
    private var stateViewsAreHidden: Bool = false {
        didSet {
            stateViews.forEach { $0.isHiddenInStackView = stateViewsAreHidden }
        }
    }
    
    private var locationStatus: AutoServiceProgressCircleView.Status {
        switch currentState {
        case .location:
            return .current
        case .mechanic:
            return .complete
        case .details:
            return .complete
        case .payment:
            return .complete
        }
    }
    
    private var mechanicStatus: AutoServiceProgressCircleView.Status {
        switch currentState {
        case .location:
            return .incomplete
        case .mechanic:
            return .current
        case .details:
            return .complete
        case .payment:
            return .complete
        }
    }
    
    private var detailsStatus: AutoServiceProgressCircleView.Status {
        switch currentState {
        case .location:
            return .incomplete
        case .mechanic:
            return .incomplete
        case .details:
            return .current
        case .payment:
            return .complete
        }
    }
    
    private var heightForCurrentState: CGFloat {
        switch currentState {
        case .location:
            return normalHeight
        case .payment:
            return priceHeight
        case .details:
            return priceHeight
        case .mechanic:
            return normalHeight
        }
    }
    
}
