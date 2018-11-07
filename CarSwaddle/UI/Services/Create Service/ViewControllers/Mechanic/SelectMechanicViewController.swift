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


final class SelectMechanicViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var mechanics: [Mechanic] = []
    
//    let mechanicNetwork: Mech
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupTableView() {
        tableView.register(MechanicSelectCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func requestMechanics() {
        
    }
    
    
}

extension SelectMechanicViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mechanics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MechanicSelectCell = tableView.dequeueCell(for: indexPath)
        cell.configure(with: mechanics[indexPath.row])
        return cell
    }
    
}


extension SelectMechanicViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected mechanic")
    }
    
}
