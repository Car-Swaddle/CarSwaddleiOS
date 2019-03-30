//
//  FocusedCollectionView.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

protocol FocusedCollectionViewDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath, collectionView: FocusedCollectionView)
}

final class FocusedCollectionView: UICollectionView {
    
    weak var focusedDelegate: FocusedCollectionViewDelegate?
    
    private var selectedIndexPath: IndexPath?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = FocusedCellCollectionViewLayout()
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    private func setup() {
        delegate = self
    }
    
}

extension FocusedCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        focusedDelegate?.didSelectItem(at: indexPath, collectionView: self)
    }
    
}

