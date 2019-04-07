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
}

class SelectOilTypeCell: UITableViewCell, NibRegisterable {

    weak var delegate: SelectOilTypeDelegate?
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    var oilTypes: [OilType] = OilType.allCases
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        setupCollectionView()
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
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
        delegate?.didSelectOilType(oilType: oilTypes[indexPath.row], cell: self)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}
