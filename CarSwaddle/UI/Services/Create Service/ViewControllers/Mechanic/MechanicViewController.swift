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

protocol MechanicViewControllerDelegate: AnyObject {
    func didChangeDate(date: Date?, viewController: MechanicViewController)
}

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
    
    weak var delegate: MechanicViewControllerDelegate?

    @IBOutlet private weak var mechanicAvailabilityView: MechanicDayAvailabilityViewWrapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = mechanic.user?.displayName
        updateMechanicView()
        mechanicAvailabilityView.view.delegate = self
    }
    
    private var hasUpdatedMechanicView: Bool = false
    
    private func updateMechanicView() {
        guard viewIfLoaded != nil, hasUpdatedMechanicView == false else { return }
        hasUpdatedMechanicView = true
        mechanicAvailabilityView.view.configure(with: mechanic)
    }
    
}

extension MechanicViewController: MechanicDateAvailabilityDelegate {
    
    func didChangeDate(date: Date?, view: MechanicDayAvailabilityView) {
        delegate?.didChangeDate(date: date, viewController: self)
    }
    
}


extension User {
    
    public var displayName: String {
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
