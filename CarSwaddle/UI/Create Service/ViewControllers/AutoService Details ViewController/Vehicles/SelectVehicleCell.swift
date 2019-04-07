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


protocol SelectVehicleCellDelegate: AnyObject {
    func didSelectAdd(cell: SelectVehicleCell)
    func didSelectVehicle(vehicle: Vehicle, cell: SelectVehicleCell)
}

class SelectVehicleCell: UITableViewCell, NibRegisterable {
    
    weak var delegate: SelectVehicleCellDelegate?
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    var vehicles: [Vehicle] = [] {
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
        
        if vehicles.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            delegate?.didSelectVehicle(vehicle: vehicles[0], cell: self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        vehicles = Array(User.currentUser(context: store.mainContext)?.vehicles ?? [])
        selectFirstVehicleIfPossible()
    }
    
    private func selectFirstVehicleIfPossible() {
        if vehicles.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func setupCollectionView() {
        collectionView.focusedFlowLayout?.itemSize = CGSize(width: 165, height: 115)
        collectionView.dataSource = self
        collectionView.focusedDelegate = self
        
        collectionView.register(AddCollectionViewCell.self)
        collectionView.register(VehicleCollectionViewCell.self)
        
        collectionView.focusedFlowLayout?.shrinkFactor = 0.3
        collectionView.focusedFlowLayout?.minimumLineSpacing = 15
        collectionView.clipsToBounds = false
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
            delegate?.didSelectAdd(cell: self)
        } else {
            print("selected vehicle")
            delegate?.didSelectVehicle(vehicle: vehicles[indexPath.item], cell: self)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
}


