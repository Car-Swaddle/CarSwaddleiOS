//
//  SelectLocationViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Store
import CoreLocation


final class SelectMechanicViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(with location: CLLocationCoordinate2D) -> SelectMechanicViewController {
        let viewController = SelectMechanicViewController.viewControllerFromStoryboard()
        viewController.location = location
        return viewController
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var location: CLLocationCoordinate2D!
    private var mechanics: [Mechanic] = [] {
        didSet {
            if let firstMechanic = mechanics.first {
                let firstViewController = MechanicViewController.create(mechanic: firstMechanic)
                mechanicPageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
            }
            mechanicPageViewController.dataSource = nil
            mechanicPageViewController.dataSource = self
        }
    }
    
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
    
    private func updateMechanics() {
        guard let location = self.location else { return }
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, coordinate: location, maxDistance: 10000, in: context) { mechanicIDs, error in
                store.mainContext { mainContext in
                    self?.mechanics = Mechanic.fetchObjects(with: mechanicIDs, in: mainContext)
                }
            }
        }
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
        return MechanicViewController.create(mechanic: mechanics[nextIndex])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let mechanicViewController = viewController as? MechanicViewController else { return nil }
        let mechanicID = mechanicViewController.mechanic.identifier
        let index = mechanics.firstIndex { return $0.identifier == mechanicID }
        guard let currentIndex = index else { return nil }
        let nextIndex = mechanics.index(before: currentIndex)
        guard nextIndex >= 0 else { return nil }
        return MechanicViewController.create(mechanic: mechanics[nextIndex])
    }
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return mechanics.count
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
    
}


extension SelectMechanicViewController: UIPageViewControllerDelegate {
    
}

//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mechanics.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: MechanicSelectCell = tableView.dequeueCell(for: indexPath)
//        cell.configure(with: mechanics[indexPath.row])
//        return cell
//    }
//
//}
//
//
//extension SelectMechanicViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selected mechanic")
//    }
//
//}
