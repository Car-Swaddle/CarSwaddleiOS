//
//  MechanicViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 11/11/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI

final class MechanicViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(mechanic: Mechanic) -> MechanicViewController {
        let viewController = MechanicViewController.viewControllerFromStoryboard()
        viewController.mechanic = mechanic
        return viewController
    }
    
    public private(set) var mechanic: Mechanic! {
        didSet {
            updateMechanicView()
        }
    }

    @IBOutlet private weak var mechanicAvailabilityView: MechanicDayAvailabilityViewWrapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateMechanicView()
        
        title = mechanic.user?.displayName
        updateMechanicView()
    }
    
    private var hasUpdatedMechanicView: Bool = false
    
    private func updateMechanicView() {
        guard viewIfLoaded != nil, hasUpdatedMechanicView == false else { return }
        hasUpdatedMechanicView = true
        mechanicAvailabilityView.view.configure(with: mechanic)
    }
    
}


extension User {
    
    var displayName: String {
        var name: String = ""
        if let firstName = firstName {
            name += firstName
            name += " "
        }
        if let lastName = lastName {
            name += lastName
        }
        return name
    }
    
}
