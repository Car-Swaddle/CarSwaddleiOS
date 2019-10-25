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
import CoreData


protocol SelectVehicleCellDelegate: AnyObject {
    func didSelectAdd(cell: SelectVehicleCell)
    func didSelectVehicle(vehicle: Vehicle?, cell: SelectVehicleCell)
}

class SelectVehicleCell: UITableViewCell, NibRegisterable {
    
    weak var delegate: SelectVehicleCellDelegate?
    
    var addVehicleCell: AddCollectionViewCell? {
        return collectionView.firstVisibleCell(of: AddCollectionViewCell.self)
    }
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    func reloadVehiclesLocally() {
        vehicles = Vehicle.fetchVehiclesForCurrentUser(in: store.mainContext)
    }
    
    var selectedVehicle: Vehicle? {
        didSet {
            reloadVehiclesLocally()
            if let selectedVehicle = selectedVehicle,
                let index = vehicles.firstIndex(of: selectedVehicle) {
                let intIndex = vehicles.startIndex.distance(to: index)
                let indexPath = IndexPath(item: intIndex, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            } else if let previousIndex = collectionView.indexPathsForSelectedItems?.first {
                collectionView.deselectItem(at: previousIndex, animated: true)
            }
        }
    }
    
    var vehicles: [Vehicle] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var vehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        reloadVehiclesLocally()
        setupCollectionView()
        selectFirstVehicleIfPossible()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reloadVehiclesLocally()
//        selectFirstVehicleIfPossible()
    }
    
    private func selectFirstVehicleIfPossible() {
        if vehicles.count > 0 && selectedVehicle == nil {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            delegate?.didSelectVehicle(vehicle: vehicles[0], cell: self)
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
            cell.showGuideLabel = vehicles.count == 0
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
            collectionView.deselectItem(at: indexPath, animated: false)
            delegate?.didSelectVehicle(vehicle: nil, cell: self)
            delegate?.didSelectAdd(cell: self)
        } else {
            delegate?.didSelectVehicle(vehicle: vehicles[indexPath.item], cell: self)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
//    func shouldSelectItem(at indexPath: IndexPath, collectionView: FocusedCollectionView) -> Bool {
//        return !isAddIndexPath(indexPath)
//    }
    
}




extension Vehicle {
    
    public static func fetchVehiclesForCurrentUser(in context: NSManagedObjectContext) -> [Vehicle] {
        guard let userID = User.currentUserID else { return [] }
        return Vehicle.fetchVehicles(forUserID: userID, in: context)
    }
    
}
