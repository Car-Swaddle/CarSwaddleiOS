//
//  OilTypeSelectionViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI

protocol SelectOilTypeViewControllerDelegate: class {
    func didChangeOilType(oilType: OilType, viewController: SelectOilTypeViewController)
}

class SelectOilTypeViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(with autoService: AutoService) -> SelectOilTypeViewController {
        let viewController = SelectOilTypeViewController.viewControllerFromStoryboard()
        viewController.selectedOilType = autoService.oilChange?.oilType ?? OilChange.defaultOilType
        return viewController
    }
    
    weak var delegate: SelectOilTypeViewControllerDelegate?

    private var oilTypes: [OilType] = [.conventional, .blend, .synthetic]
    
    private var selectedOilType: OilType! {
        didSet {
            var indexPaths: [IndexPath] = []
            if let oldValue = oldValue {
                let oldIndex = oilTypes.index(of: oldValue) ?? 0
                let oldIndexPath = IndexPath(row: oldIndex, section: 0)
                indexPaths.append(oldIndexPath)
            }
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            indexPaths.append(indexPath)
            tableView?.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    private var selectedIndex: Int {
        return oilTypes.index(of: selectedOilType) ?? 0
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(OilTypeCell.self)
        tableView.tableFooterView = UIView()
    }
    
}

extension SelectOilTypeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oilTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OilTypeCell = tableView.dequeueCell()
        let oilType = oilTypes[indexPath.row]
        cell.configure(with: oilType)
        cell.isSelectedOilType = oilType == selectedOilType
        return cell
    }
    
}

extension SelectOilTypeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOilType = oilTypes[indexPath.row]
        delegate?.didChangeOilType(oilType: selectedOilType, viewController: self)
    }
    
}
