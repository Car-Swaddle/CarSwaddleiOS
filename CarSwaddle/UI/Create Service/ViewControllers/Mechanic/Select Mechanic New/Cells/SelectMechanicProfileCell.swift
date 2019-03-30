//
//  SelectMechanicProfileCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store


protocol SelectMechanicProfileCellDelegate: AnyObject {
    func didSelect(mechanic: Mechanic, cell: SelectMechanicProfileCell)
}

final class SelectMechanicProfileCell: UITableViewCell, NibRegisterable {
    
    weak var delegate: SelectMechanicProfileCellDelegate?
    
    var mechanics: [Mechanic] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedMechanic: Mechanic? {
        didSet {
            if oldValue == selectedMechanic {
                return
            }
            guard let selectedMechanic = selectedMechanic else {
                if let previousMechanic = oldValue,
                    let previousIndex = mechanics.firstIndexDistance(of: previousMechanic) {
                    collectionView.deselectItem(at: IndexPath(item: previousIndex, section: 0), animated: true)
                }
                return
            }
            guard let index = mechanics.firstIndexDistance(of: selectedMechanic) else {
                return
            }
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    @IBOutlet private weak var selectMechanicLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        selectMechanicLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(MechanicProfileCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.2)
        collectionView.focusedFlowLayout?.itemSize = CGSize(width: 230, height: 303)
        collectionView.focusedFlowLayout?.shrinkFactor = 0.3
        collectionView.focusedFlowLayout?.minimumLineSpacing = 0
        collectionView.clipsToBounds = false
        
//        collectionView.selecte
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

extension SelectMechanicProfileCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mechanics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MechanicProfileCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: mechanics[indexPath.item])
        return cell
    }
    
}

extension SelectMechanicProfileCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMechanic = mechanics[indexPath.item]
        delegate?.didSelect(mechanic: mechanics[indexPath.item], cell: self)
    }
    
}




extension Collection where Element: Equatable {
    func firstIndexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
