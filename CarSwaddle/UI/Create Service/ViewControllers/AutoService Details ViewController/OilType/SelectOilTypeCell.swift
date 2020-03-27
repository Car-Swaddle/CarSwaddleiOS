//
//  SelectOilTypeCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Store

protocol SelectOilTypeDelegate: AnyObject {
    func didSelectOilType(oilType: OilType, cell: SelectOilTypeCell)
    func didTapMoreInfo(cell: SelectOilTypeCell)
}

class SelectOilTypeCell: UITableViewCell, NibRegisterable {

    weak var delegate: SelectOilTypeDelegate?
    
    func updateSelectedOilType(oilType: OilType, animated: Bool) {
        selectedOilType = oilType
        updateForCurrentSelectedOilType(animated: animated)
    }
    
    private var selectedOilType: OilType?
    
    private func updateForCurrentSelectedOilType(animated: Bool) {
        guard let oilType = selectedOilType else { return }
        
        let index = oilTypes.firstIndex(of: oilType) ?? 0
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == false {
            let index = oilTypes.firstIndex(of: selectedOilType ?? .synthetic) ?? 0
            let selectedIndexPath = IndexPath(row: index, section: 0)
            collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    var oilTypes: [OilType] = OilType.allCases
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        setupCollectionView()
        
        let index = oilTypes.firstIndex(of: selectedOilType ?? .synthetic) ?? 0
        let selectedIndexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.focusedDelegate = self
        
        collectionView.register(OilTypeCollectionViewCell.self)
        
        collectionView.focusedFlowLayout?.itemSize = CGSize(width: 150, height: 70)
        collectionView.focusedFlowLayout?.shrinkFactor = 0.3
        collectionView.focusedFlowLayout?.minimumLineSpacing = 5
        collectionView.clipsToBounds = false
    }
    
    
    @IBAction func didTapInfo() {
        delegate?.didTapMoreInfo(cell: self)
    }
    
}

extension SelectOilTypeCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return oilTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OilTypeCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: oilTypes[indexPath.item])
        return cell
    }
    
}

extension SelectOilTypeCell: FocusedCollectionViewDelegate {
    
    func didSelectItem(at indexPath: IndexPath, collectionView: FocusedCollectionView) {
        let newOilType = oilTypes[indexPath.row]
//        selectedOilType = newOilType
        updateSelectedOilType(oilType: newOilType, animated: true)
        delegate?.didSelectOilType(oilType: newOilType, cell: self)
    }
    
}
