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

final class ServicesViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    
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
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var autoServices: [AutoService] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupTableView()
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
    
    @IBAction func didTapCreate() {
        let createService = CreateServiceViewController.create(autoServiceID: nil)
        present(createService.inNavigationController(), animated: true, completion: nil)
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
        
    }
    
}
