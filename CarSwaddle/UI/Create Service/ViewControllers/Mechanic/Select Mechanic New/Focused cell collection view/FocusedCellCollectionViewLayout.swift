//
//  FocusedCellCollectionViewLayout.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/29/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

private let defaultActiveDistance: CGFloat = 200

public class FocusedCellCollectionViewLayout: UICollectionViewFlowLayout {
    
    public var shrinkFactor: CGFloat = 0.3
    
    
    private var activeDistance: CGFloat = defaultActiveDistance
    
    public override init() {
        super.init()
        
        setup()
    }
    
    private func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = 40
        itemSize = CGSize(width: 150, height: 150)
    }
    
    private var maxDistance: CGFloat = 0
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
        setup()
    }
    
    public override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.2)
        
        updateActiveDistance()
        
        super.prepare()
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
        let layoutElements = super.layoutAttributesForElements(in: rect) else { return nil }
        let rectAttributes = layoutElements.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        
        let visibleRect = collectionView.visibleRect
        // Zoom cells when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let zoom = self.zoom(for: attributes, visibleRect: visibleRect)
            attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
            attributes.zIndex = Int(zoom * 100)
        }
        
        return rectAttributes
    }
    
    private func zoom(for attributes: UICollectionViewLayoutAttributes, visibleRect: CGRect) -> CGFloat {
        let distance = (attributes.center.x - visibleRect.midX).magnitude
        let normalizedDistance = 1 - (distance / activeDistance).magnitude
        let zoomLevel = shrinkFactor * (1 - normalizedDistance)
        return 1 - zoomLevel
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        
        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        updateActiveDistance()
    }
    
    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let viewLayoutContext = super.invalidationContext(forBoundsChange: newBounds)
        guard let context = viewLayoutContext as? UICollectionViewFlowLayoutInvalidationContext else {
            return viewLayoutContext
        }
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        updateActiveDistance()
        return context
    }
    
    private func updateActiveDistance() {
        activeDistance = ((collectionView?.frame.width ?? defaultActiveDistance) / 2) + (itemSize.width / 2)
    }
    
}


extension UICollectionView {
    
    public var visibleRect: CGRect {
        return CGRect(origin: contentOffset, size: frame.size)
    }
    
    public var focusedFlowLayout: FocusedCellCollectionViewLayout? {
        return (collectionViewLayout as? FocusedCellCollectionViewLayout)
    }
    
    public var flowLayout: UICollectionViewFlowLayout? {
        return (collectionViewLayout as? UICollectionViewFlowLayout)
    }
    
}


