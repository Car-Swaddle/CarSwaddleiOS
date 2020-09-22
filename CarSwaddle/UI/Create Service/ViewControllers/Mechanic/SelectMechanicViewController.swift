//
//  SelectLocationViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleStore
import CoreLocation

let yearMonthDayDateFormatter: DateFormatter = {
    let yearMonthDayDateFormatter = DateFormatter()
    yearMonthDayDateFormatter.dateFormat = "yyyy-MM-dd"
    return yearMonthDayDateFormatter
}()

protocol SelectMechanicDelegate: AnyObject {
    func didSaveMechanic(mechanic: Mechanic, date: Date, viewController: UIViewController)
    func willBeDismissed(viewController: UIViewController)
}

final class SelectMechanicViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(with location: CLLocationCoordinate2D) -> SelectMechanicViewController {
        let viewController = SelectMechanicViewController.viewControllerFromStoryboard()
        viewController.location = location
        return viewController
    }
    
    public weak var delegate: SelectMechanicDelegate?
    
    @IBOutlet private weak var tableView: UITableView!
    private let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var location: CLLocationCoordinate2D!
    private var mechanics: [Mechanic] = [] {
        didSet {
            if let firstMechanic = mechanics.first {
                let firstViewController = MechanicViewController.create(mechanic: firstMechanic)
                firstViewController.delegate = self
                mechanicPageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
            }
            mechanicPageViewController.dataSource = nil
            mechanicPageViewController.dataSource = self
        }
    }
    private var scheduledDate: Date? {
        didSet {
            updateSaveEnabledness()
        }
    }
    
    private var currentMechanicIndex: Int = 0
    private var nextIndex: Int = 0
    
    private var mechanicViewControllers: [MechanicViewController] = []
    
    lazy var mechanicPageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(mechanicPageViewController)
        view.addSubview(mechanicPageViewController.view)
        mechanicPageViewController.view.pinFrameToSuperViewBounds()
        mechanicPageViewController.didMove(toParent: self)
        
        updateMechanics()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            delegate?.willBeDismissed(viewController: self)
        }
    }
    
    private func updateMechanics() {
        guard let location = self.location else { return }
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, coordinate: location, maxDistance: 1_000_000, in: context) { mechanicObjectIDs, error in
                store.mainContext { mainContext in
                    let mechanics = Mechanic.fetchObjects(with: mechanicObjectIDs, in: mainContext)
                    self?.mechanics = mechanics
                    let mechanicIDs = mechanics.map { $0.identifier }
                    self?.updateSaveEnabledness()
                    tracker.logEvent(trackerName: .viewItem, parameters: [
                        Tracker.Parameter.itemList.rawValue: mechanicIDs,
                        "numberOfItems": mechanicIDs.count
                    ])
                }
            }
        }
    }
    
    @IBAction func didSelectSave() {
        guard let mechanic = currentSelectedMechanic, let scheduledDate = scheduledDate else { return }
        delegate?.didSaveMechanic(mechanic: mechanic, date: scheduledDate, viewController: self)
        
        tracker.logEvent(trackerName: .checkoutOption, parameters: [
            Tracker.Parameter.checkoutOption.rawValue: "selectMechanicDayAndTime",
            Tracker.Parameter.checkoutStep.rawValue: "2",
            Tracker.Parameter.startDate.rawValue: yearMonthDayDateFormatter.string(from: scheduledDate),
            "daysFromCurrentDate": scheduledDate.timeIntervalSinceNow.days
        ])
    }
    
    private func updateSaveEnabledness() {
        navigationItem.rightBarButtonItem?.isEnabled = isSaveButtonEnabled
    }
    
    private var isSaveButtonEnabled: Bool {
        return currentSelectedMechanic != nil && scheduledDate != nil
    }
    
    private var currentSelectedMechanic: Mechanic? {
        guard currentMechanicIndex < mechanics.count else { return nil }
        return mechanics[currentMechanicIndex]
    }
    
}

extension SelectMechanicViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let mechanicViewController = viewController as? MechanicViewController else { return nil }
        let mechanicID = mechanicViewController.mechanic.identifier
        let index = mechanics.firstIndex { return $0.identifier == mechanicID }
        guard let currentIndex = index else { return nil }
        let nextIndex = mechanics.index(after: currentIndex)
        guard nextIndex < mechanics.count else { return nil }
        let viewController = MechanicViewController.create(mechanic: mechanics[nextIndex])
        viewController.delegate = self
        return viewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let mechanicViewController = viewController as? MechanicViewController else { return nil }
        let mechanicID = mechanicViewController.mechanic.identifier
        let index = mechanics.firstIndex { return $0.identifier == mechanicID }
        guard let currentIndex = index else { return nil }
        let nextIndex = mechanics.index(before: currentIndex)
        guard nextIndex >= 0 else { return nil }
        let viewController = MechanicViewController.create(mechanic: mechanics[nextIndex])
        viewController.delegate = self
        return viewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return mechanics.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

extension SelectMechanicViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let firstPending = pendingViewControllers.first as? MechanicViewController else {
            return
        }
        nextIndex = mechanics.firstIndex(of: firstPending.mechanic) ?? 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentMechanicIndex = nextIndex
        }
        nextIndex = 0
    }
    
}

extension SelectMechanicViewController: MechanicViewControllerDelegate {
    
    func didChangeDate(date: Date?, viewController: MechanicViewController) {
        scheduledDate = date
    }
    
}
