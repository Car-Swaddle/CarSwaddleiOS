//
//  LocationSearchRetulsViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit
import CarSwaddleUI

protocol LocationSearchResultsDelegate: AnyObject {
    func didSelect(result: MKLocalSearchCompletion, viewController: LocationSearchResultsViewController)
    func didTapView(_ viewController: LocationSearchResultsViewController)
}

final class LocationSearchResultsViewController: UIViewController, StoryboardInstantiating {
    
    var results: [MKLocalSearchCompletion] = [] {
        didSet {
            assert(Thread.isMainThread, "Must be on main thread to set results")
            tableView.reloadData()
        }
    }
    
    weak var delegate: LocationSearchResultsDelegate?
    
    private var insetAdjuster: ContentInsetAdjuster!
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        return tap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: nil)

        view.backgroundColor = .clear
//        view.alpha = 0.2
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        tableView.
        setupTableView()
//        view.isUserInteractionEnabled = false
//        tableView.isUserInteractionEnabled = true
        
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupTableView() {
        tableView.register(LocationSearchCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @objc private func didTapView() {
        delegate?.didTapView(self)
    }

}

extension LocationSearchResultsViewController: UIGestureRecognizerDelegate {
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer == tap else { return true }
//        return !(gestureRecognizer.view is UITableViewCell)
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer == tap && touch.view != tableView else { return true }
        return !(touch.view?.isDescendant(of: tableView) == true)
    }
    
}


extension LocationSearchResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LocationSearchCell = tableView.dequeueCell()
        cell.configure(with: results[indexPath.row])
        return cell
    }
    
}

extension LocationSearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        delegate?.didSelect(result: results[indexPath.row], viewController: self)
    }
    
}
