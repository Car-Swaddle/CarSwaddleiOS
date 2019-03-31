//
//  SelectVehicleCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData

class SelectVehicleCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    private var vehicles: [Vehicle] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var vehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        setupCollectionView()
        vehicles = Array(User.currentUser(context: store.mainContext)?.vehicles ?? [])
        selectFirstVehicleIfPossible()
        
        requestVehicles()
        
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private func selectFirstVehicleIfPossible() {
        if vehicles.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func setupCollectionView() {
        collectionView.focusedFlowLayout?.itemSize = CGSize(width: 115, height: 115)
        collectionView.dataSource = self
        collectionView.focusedDelegate = self
        
        collectionView.register(AddCollectionViewCell.self)
        collectionView.register(VehicleCollectionViewCell.self)
        
        collectionView.focusedFlowLayout?.shrinkFactor = 0.3
        collectionView.focusedFlowLayout?.minimumLineSpacing = 15
        collectionView.clipsToBounds = false
    }
    
    private func requestVehicles() {
        store.privateContext { [weak self] privateContext in
            self?.vehicleNetwork.requestVehicles(limit: 10, offset: 0, in: privateContext) { vehicles, error in
                store.mainContext { mainContext in
                    self?.vehicles = Vehicle.fetchObjects(with: vehicles, in: mainContext)
                    self?.selectFirstVehicleIfPossible()
                }
            }
        }
    }
    
}


extension SelectVehicleCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vehicles.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isAddIndexPath(indexPath) {
            let cell: AddCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            return cell
        } else {
            let cell: VehicleCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: vehicles[indexPath.item])
            return cell
        }
    }
    
    private func isAddIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == vehicles.count
    }
    
}

extension SelectVehicleCell: FocusedCollectionViewDelegate {
    
    func didSelectItem(at indexPath: IndexPath, collectionView: FocusedCollectionView) {
        if isAddIndexPath(indexPath) {
            print("add vehicle")
        } else {
            print("selected vehicle")
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
}


