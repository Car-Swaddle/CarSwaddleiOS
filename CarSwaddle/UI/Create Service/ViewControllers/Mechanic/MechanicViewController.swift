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
import CarSwaddleData

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
    @IBOutlet weak var mechanicImageView: MechanicImageView!
    
    weak var delegate: MechanicViewControllerDelegate?
    
    private var mechanicService: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)

    @IBOutlet private weak var mechanicAvailabilityView: MechanicDayAvailabilityViewWrapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = mechanic.user?.displayName
        updateMechanicView()
        mechanicImageView.configure(withMechanicID: mechanic.identifier)
        mechanicAvailabilityView.view.delegate = self
        updateStats { [weak self] in
            self?.updateMechanicView()
        }
    }
    
    private func updateStats(completion: @escaping () -> Void) {
        let mechanicID = mechanic.identifier
        store.privateContext { [weak self] privateContext in
            self?.mechanicService.getStats(mechanicID: mechanicID, in: privateContext) { mechanicID, error in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
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
