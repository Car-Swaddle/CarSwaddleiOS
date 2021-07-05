//
//  SelectMechanicProfileCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore


protocol SelectMechanicProfileCellDelegate: AnyObject {
    func didSelect(mechanic: Mechanic, cell: SelectMechanicProfileCell)
}

final class SelectMechanicProfileCell: UITableViewCell, NibRegisterable {
    
    weak var delegate: SelectMechanicProfileCellDelegate?
    
    var hasFetchedMechanics: Bool = false {
        didSet {
            updateShowNoMechanicsLabel()
        }
    }
    
    var mechanics: [Mechanic] = [] {
        didSet {
            collectionView.reloadData()
            updateShowNoMechanicsLabel()
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
            
            let indexPath = IndexPath(item: index, section: 0)
            if collectionView.indexPathsForSelectedItems?.contains(indexPath) == false {
                collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    @IBOutlet private weak var selectMechanicLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noMechanicsTitleLabel: UILabel!
    @IBOutlet private weak var noMechanicsSubtitleLabel: UILabel!
    @IBOutlet private weak var noMechanicsStackView: UIStackView!
    
    private var showsNoMechanicsLabel: Bool {
        return hasFetchedMechanics && mechanics.count == 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        selectMechanicLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        noMechanicsTitleLabel.font = UIFont.appFont(type: .semiBold, size: 20)
        noMechanicsSubtitleLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        setupCollectionView()
    }
    
    private func updateShowNoMechanicsLabel() {
        noMechanicsStackView.isHiddenInStackView = !showsNoMechanicsLabel
    }
    
    private func setupCollectionView() {
        collectionView.register(MechanicProfileCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.focusedFlowLayout?.itemSize = CGSize(width: 230, height: 323)
        collectionView.focusedFlowLayout?.shrinkFactor = 0.3
        collectionView.focusedFlowLayout?.minimumLineSpacing = 0
        collectionView.clipsToBounds = false
        collectionView.allowsMultipleSelection = false
    }
    
}

extension SelectMechanicProfileCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mechanics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MechanicProfileCell = collectionView.dequeueCell(for: indexPath)
        let mechanic = mechanics[indexPath.item]
        cell.configure(with: mechanic)
        cell.isSelected = mechanic == selectedMechanic
        return cell
    }
    
}

extension SelectMechanicProfileCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMechanic = mechanics[indexPath.item]
        delegate?.didSelect(mechanic: mechanics[indexPath.item], cell: self)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Prevents stutter
        collectionView.setContentOffset(targetContentOffset.pointee, animated: true)
    }
    
}




extension Collection where Element: Equatable {
    func firstIndexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
