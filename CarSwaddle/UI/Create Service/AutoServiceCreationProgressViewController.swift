//
//  AutoServiceCreationProgressViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData

protocol AutoServiceCreationProgressDelegate: AnyObject {
    func updateHeight(newHeight: CGFloat)
}

private let normalHeight: CGFloat = 120
private let priceHeight: CGFloat = 200

class AutoServiceCreationProgressViewController: UIViewController, StoryboardInstantiating {
    
    weak var delegate: AutoServiceCreationProgressDelegate?
    
//    var autoService: AutoService?

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
    
    @IBOutlet private weak var locationCircle: RoundView!
    @IBOutlet private weak var mechanicCircle: RoundView!
    @IBOutlet private weak var detailsCircle: RoundView!
    
    lazy var priceView: PriceView = {
        let priceView = PriceView.viewFromNib()
        return priceView
    }()
    
    private let completedColor: UIColor = .secondary
    private let currentlySelectedColor: UIColor = .appRed
    private let notCompletedColor: UIColor = .gray3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.font = UIFont.appFont(type: .regular, size: 17)
        mechanicLabel.font = UIFont.appFont(type: .regular, size: 17)
        detailsLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        updateViewForCurrentState()
    }
    
    private func updateViewForCurrentState() {
        locationCircle.backgroundColor = locationCircleColor
        mechanicCircle.backgroundColor = mechanicCircleColor
        detailsCircle.backgroundColor = detailsCircleColor
        
        delegate?.updateHeight(newHeight: heightForCurrentState)
        
        updateForPriceView()
    }
    
    private func updateForPriceView() {
        switch currentState {
        case .location, .mechanic:
            priceView.removeFromSuperview()
        case .payment, .details:
            if priceView.superview == nil {
                view.addSubview(priceView)
                priceView.pinFrameToSuperViewBounds()
            }
        }
    }
    
    private var locationCircleColor: UIColor {
        switch currentState {
        case .location:
            return currentlySelectedColor
        case .mechanic:
            return completedColor
        case .details:
            return completedColor
        case .payment:
            return completedColor
        }
    }
    
    private var mechanicCircleColor: UIColor {
        switch currentState {
        case .location:
            return notCompletedColor
        case .mechanic:
            return currentlySelectedColor
        case .details:
            return completedColor
        case .payment:
            return completedColor
        }
    }
    
    private var detailsCircleColor: UIColor {
        switch currentState {
        case .location:
            return notCompletedColor
        case .mechanic:
            return notCompletedColor
        case .details:
            return currentlySelectedColor
        case .payment:
            return completedColor
        }
    }
    
    private var heightForCurrentState: CGFloat {
        switch currentState {
        case .location:
            return normalHeight
        case .payment:
            return priceHeight
        case .details:
            return 160
        case .mechanic:
            return 160
        }
    }
    
}
