//
//  AutoServiceCreationProgressViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class AutoServiceCreationProgressViewController: UIViewController, StoryboardInstantiating {

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
        switch currentState {
        case .location:
            locationCircle.backgroundColor = currentlySelectedColor
            mechanicCircle.backgroundColor = notCompletedColor
            detailsCircle.backgroundColor = notCompletedColor
        case .mechanic:
            locationCircle.backgroundColor = completedColor
            mechanicCircle.backgroundColor = currentlySelectedColor
            detailsCircle.backgroundColor = notCompletedColor
        case .details:
            locationCircle.backgroundColor = completedColor
            mechanicCircle.backgroundColor = completedColor
            detailsCircle.backgroundColor = currentlySelectedColor
        case .payment:
            locationCircle.backgroundColor = completedColor
            mechanicCircle.backgroundColor = completedColor
            detailsCircle.backgroundColor = completedColor
        }
    }
    
}
