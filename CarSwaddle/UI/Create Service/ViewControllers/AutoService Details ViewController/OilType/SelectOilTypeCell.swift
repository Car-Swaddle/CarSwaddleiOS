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


class SelectOilTypeCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: FocusedCollectionView!
    
    private var oilTypes: [OilType] = OilType.allCases
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        setupCollectionView()
        
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
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
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}
