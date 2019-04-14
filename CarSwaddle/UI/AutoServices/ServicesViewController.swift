//
//  ServicesViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import CarSwaddleNetworkRequest
import Store
import Firebase

final class ServicesViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: ActionButton!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addTarget(self, action: #selector(ServicesViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestAutoServices { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    lazy private var adjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var autoServices: [AutoService] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupTableView()
        adjuster.positionActionButton()
        actionButton.addTarget(self, action: #selector(ServicesViewController.didTapCreate), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAutoServices()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    private func requestAutoServices(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServices(limit: 20, offset: 0, sortStatus: [.inProgress, .scheduled, .completed, .canceled], in: privateContext) { autoServiceIDs, error in
                DispatchQueue.main.async {
                    store.mainContext { mainContext in
                        self?.autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
                        completion()
                    }
                }
            }
        }
    }
    
    @IBAction private func didTapCreate() {
        let creator = AutoServiceCreation()
        self.creator = creator
        let pocketController = creator.pocketController!
        present(pocketController, animated: true, completion: nil)
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: nil)
    }
    
    private var creator: AutoServiceCreation?
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ServicesViewController: SelectLocationViewControllerDelegate {
    
    func didSelect(location: Location, viewController: SelectLocationViewController) {
        
    }
    
    func willBeDismissed(viewController: SelectLocationViewController) {
        
    }
    
}

extension ServicesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: autoServices[indexPath.row])
        return cell
    }
    
}

extension ServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoService = autoServices[indexPath.row]
        
        let viewController = AutoServiceDetailsViewController.create(with: autoService)
        show(viewController, sender: self)
    }
    
}
