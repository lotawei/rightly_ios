//
// RTWaterFlowLayout.swift
//  WaterFlowCollectionView
//
//  Created by longwei on 16/9/20.
//  Copyright © 2020年 lotawei All rights reserved.
//

import UIKit

fileprivate func > (left: CGSize, right: CGSize) ->Bool {
    return left.width > right.width && left.height > right.height
}

fileprivate func - (left: CGSize, right: CGSize) ->CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

@objc public protocol RTWaterLayoutDelegate: UICollectionViewDataSource,  UICollectionViewDelegate {
    
    //itemSize宽高比
    @objc optional func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: RTWaterFlowLayout,
                                        ratioForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    //是否含有background
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        hasBackgroundInSection section: Int) -> Bool
    
    //流条数
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout, waterCountForSection section: Int) -> Int
    
    //头视图/脚视图大小
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        sizeForHeaderForFooterInSection section: Int, elementKind: String) -> CGSize
    
    //内边距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        insetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    //同一流中item间距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        minimumItemSpacingForSection section: Int) -> CGFloat
    
    //流间距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        minimumWaterSpacingForSection section: Int) -> CGFloat
    
    //流宽度
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        waterWidthForSection section: Int, at index: Int) -> CGFloat
    
    //修改attributes，background/header/footer/item, kind为nil时为item
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                                        relocationForElement kind: String?, currentAttributes: UICollectionViewLayoutAttributes)
}

public protocol RTWaterLayoutModelable {
    var size: CGSize {get}
}

public protocol YJWaterLayoutMovable: class {
    @available(iOS 9.0, *)
    func enableMoveItem (_ layout: RTWaterFlowLayout) -> Bool
    func itemLayoutDatas (layout collectionViewLayout: RTWaterFlowLayout) -> [RTWaterLayoutModelable]
}

public enum YJCollectionViewLayoutDirection : Int {
    
    case vertical
    
    case horizontal
}

public let YJCollectionSectionHeader = "YJCollectionSectionHeader"
public let YJCollectionSectionFooter = "YJCollectionSectionFooter"
public let YJCollectionSectionBackground = "YJCollectionSectionBackground"

open class RTWaterFlowLayout: UICollectionViewLayout {
    
    public var itemRatio: CGSize = CGSize(width: 50, height: 50)
    //瀑布流的条数（优先级低于代理方法中的设置）
    public var waterCount: Int = 2
    //流间距（优先级低于代理方法中的设置）
    public var minimumWaterSpacing: CGFloat = 10.0
    
    //同一流中item间距（优先级低于代理方法中的设置）
    public var minimumItemSpacing: CGFloat = 10.0
    
    //section头视图大小（优先级低于代理方法中的设置）
    public var headerSize: CGSize = CGSize.zero
    
    //section脚视图大小（优先级低于代理方法中的设置）
    public var footerSize: CGSize = CGSize.zero
    
    //是否包含section背景图（优先级低于代理方法的设置）
    public var hasSectionBackground: Bool = false
    
    //section内边距（优先级低于代理方法中的设置）
    public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    
    //流动方向
    public var layoutDirection: YJCollectionViewLayoutDirection = .vertical
    
    //批量布局个数
    public var unionSize = 15
    
    //代理
    public weak var delegate: RTWaterLayoutDelegate?
    public weak var moveAction: YJWaterLayoutMovable?
    
    fileprivate var itemLayoutDatas: [RTWaterLayoutModelable]?
    
    @available(iOS 9.0, *)
    open func moveItem( _ resource: inout [RTWaterLayoutModelable], moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = resource.remove(at: sourceIndexPath.item)
        resource.insert(temp, at: destinationIndexPath.item)
        
        if longGes.state == .ended {
            resource = itemLayoutDatas!
        }
    }
    
    fileprivate var allItemSizes = [Int: [CGSize]]()
    fileprivate var waterWidths = [Int: [Int: CGFloat]]()
    fileprivate var miniItemSpaces = [Int: CGFloat]()
    fileprivate var miniWaterSpaces = [Int: CGFloat]()
    fileprivate var waterCounts = [Int: Int]()
    fileprivate var sectionInsets = [Int: UIEdgeInsets]()
    
    fileprivate var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    fileprivate var allItemAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var headerAttributes = [Int : UICollectionViewLayoutAttributes]()
    fileprivate var footerAttributes = [Int : UICollectionViewLayoutAttributes]()
    fileprivate var backgroundAttributes = [Int: UICollectionViewLayoutAttributes]()
    fileprivate var unionRects = [CGRect]()
    
    fileprivate var async: Bool = false
    
    @available(iOS 9.0, *)
    fileprivate lazy var longGes: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
    
    fileprivate var enableMove: Bool = false {
        didSet {
            if enableMove == oldValue {
                return
            }
            if #available(iOS 9.0, *) {
                if enableMove == false {
                    collectionView?.removeGestureRecognizer(longGes)
                } else {
                    collectionView?.addGestureRecognizer(longGes)
                }
            }
        }
    }
    
    //有bug
    open func asyncPrepare(_ completeHandler: (()->())?) {
        DispatchQueue.global().async {
            self.async = true
            self.prepareToLayout()
            self.async = false
            DispatchQueue.main.async {
                completeHandler?()
            }
        }
    }
    
    open override func prepare() {
        super.prepare()
        if async && !allItemAttributes.isEmpty {
            return
        }
        prepareToLayout()
    }
    
    fileprivate func prepareToLayout() {
        guard let delegate = self.delegate else {
            return
        }
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        reset()
        
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        var size: CGSize = CGSize.zero
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0..<numberOfSections {
            var itemSizes = allItemSizes[section] ?? [CGSize]()
            
            var widths = waterWidths[section] ?? [Int: CGFloat]()
            
            miniItemSpaces[section] = delegate.collectionView?(collectionView, layout: self, minimumItemSpacingForSection: section) ?? self.minimumItemSpacing
            miniWaterSpaces[section] = delegate.collectionView?(collectionView, layout: self, minimumWaterSpacingForSection: section) ?? self.minimumWaterSpacing
            
            sectionInsets[section] = delegate.collectionView?(collectionView, layout: self, insetForSectionAtIndex: section) ?? sectionInset
            
            if let count = delegate.collectionView?(collectionView, layout: self, waterCountForSection: section), count > 0 {
                waterCounts[section] = count
            } else {
                waterCounts[section] = waterCount
            }
            
            var idx = 0
            while idx < waterCounts[section]! {
                itemSizes.append(CGSize.zero)
                if let w = delegate.collectionView?(collectionView, layout: self, waterWidthForSection: section, at: idx), w > 0 {
                    widths[idx] = w
                } else {
                    widths[idx] = getWaterWidth(section: section, index: idx)
                }
                idx += 1
            }
            allItemSizes[section] = itemSizes
            waterWidths[section] = widths
            
            //获取两个最小
            let minimumItemSpacing: CGFloat = miniItemSpaces[section]!
            let minimumWaterSpacing: CGFloat = miniWaterSpaces[section]!
            
            //header
            layoutHeaders(totalSize: &size, attributes: &attributes, for: section)
            
            //item
            layoutItemsAndBackground(totalSize: &size, attributes: &attributes, minimumWaterSpacing: minimumWaterSpacing, minimumItemSpacing: minimumItemSpacing, for: section)
            
            //footer
            layoutFooters(totalSize: &size, attributes: &attributes, minimumWaterSpacing: minimumWaterSpacing, minimumItemSpacing: minimumItemSpacing, for: section)
            
        }
        
        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            
            idx += 1
        }
    }
    
    open override var collectionViewContentSize: CGSize {
        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        let longest = longestIndex(section: numberOfSections - 1)
        guard let itemSizes = allItemSizes[numberOfSections - 1] else {
            return CGSize.zero
        }
        return layoutDirection == .vertical ? CGSize(width: collectionView!.bounds.width, height: itemSizes[longest].height) : CGSize(width: itemSizes[longest].width, height: collectionView!.bounds.height)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        if indexPath.item >= sectionItemAttributes[indexPath.section].count {
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        let attr = list[indexPath.item]
        
        return attr
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == YJCollectionSectionHeader {
            attribute = headerAttributes[indexPath.section]!
        } else if elementKind == YJCollectionSectionFooter {
            attribute = footerAttributes[indexPath.section]!
        } else if elementKind == YJCollectionSectionBackground {
            attribute = backgroundAttributes[indexPath.section]!
        }
        return attribute
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for i in 0..<end {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        
        for i in (0..<unionRects.count).reversed() {
            
            if rect.intersects(unionRects[i]) {
                end = min((i+1)*unionSize, allItemAttributes.count)
                break
            }
        }
        
        for i in begin..<end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.size != oldBounds.size {
            return true
        }
        return false
    }
    
}

extension RTWaterFlowLayout {
    
    fileprivate func shortestIndex(section: Int) -> Int {
        var index = 0
        var shortestLength = Float.infinity
        guard let itemSizes = allItemSizes[section] else {
            return 0
        }
        for (idx, obj) in itemSizes.enumerated() {
            let length = layoutDirection == .vertical ? obj.height : obj.width
            if Float(length) < shortestLength {
                shortestLength = Float(length)
                index = idx
            }
        }
        return index
    }
    
    fileprivate func longestIndex(section: Int) -> Int {
        var index = 0
        var longestLength: CGFloat = 0.0
        guard let itemSizes = allItemSizes[section] else {
            return 0
        }
        for (idx, obj) in itemSizes.enumerated() {
            let length = CGFloat(layoutDirection == .vertical ? obj.height : obj.width)
            if (length > longestLength){
                longestLength = length
                index = idx
            }
        }
        return index
    }
    
    public func getWaterWidth(section: Int, index: Int) -> CGFloat {
        let miniWaterSpace = miniWaterSpaces[section]!
        var width: CGFloat = 0
        let sectionInset = sectionInsets[section]!
        if layoutDirection == .vertical {
            width = collectionView!.bounds.size.width - sectionInset.left - sectionInset.right - collectionView!.contentInset.left - collectionView!.contentInset.right
        } else {
            width = collectionView!.bounds.size.height - sectionInset.top - sectionInset.bottom - collectionView!.contentInset.top - collectionView!.contentInset.bottom
        }
        let waterCount = waterCounts[section]!
        let spaceWaterCount = CGFloat(waterCount - 1)
        return floor((width - (spaceWaterCount*miniWaterSpace)) / CGFloat(waterCount))
    }
    
    fileprivate func layoutHeaders(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, for section: Int) {
        
        let headerSize: CGSize = delegate?.collectionView?(collectionView!, layout: self, sizeForHeaderForFooterInSection: section, elementKind: YJCollectionSectionHeader) ?? self.headerSize
        
        let h = layoutDirection == .horizontal && headerSize.width > 0
        let v = layoutDirection == .vertical && headerSize.height > 0
        if h || v {
            attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YJCollectionSectionHeader, with: IndexPath(item: 0, section: section))
            
            let x = h ? size.width : 0, y = v ? size.height : 0
            
            attributes.frame = CGRect(x: x, y: y, width: headerSize.width, height: headerSize.height)
            attributes.zIndex = 2
            delegate?.collectionView?(collectionView!, layout: self, relocationForElement: YJCollectionSectionHeader, currentAttributes: attributes)
            headerAttributes[section] = attributes
            allItemAttributes.append(attributes)
            
            size = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
        }
        let sectionInset = sectionInsets[section]!
        size.height += sectionInset.top
        size.width += sectionInset.left
        
        guard var itemSizes = allItemSizes[section] else {
            return
        }
        let count = waterCounts[section]!
        for idx in 0..<count {
            itemSizes[idx] = size
        }
        allItemSizes[section] = itemSizes
    }
    
    fileprivate func layoutFooters(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, minimumWaterSpacing: CGFloat, minimumItemSpacing: CGFloat, for section: Int) {
        
        let longestIdx = longestIndex(section: section)
        guard var itemSizes = allItemSizes[section] else {
            return
        }
        let sectionInset = sectionInsets[section]!
        if layoutDirection == .horizontal {
            size.width = itemSizes[longestIdx].width + sectionInset.right
            size.height = collectionView!.bounds.size.height
        }else {
            size.height = itemSizes[longestIdx].height + sectionInset.bottom
            size.width = collectionView!.bounds.size.width
        }
        
        let footerSize: CGSize = delegate?.collectionView?(collectionView!, layout: self, sizeForHeaderForFooterInSection: section, elementKind: YJCollectionSectionFooter) ?? self.footerSize
        
        let h = layoutDirection == .horizontal && footerSize.width > 0
        let v = layoutDirection == .vertical && footerSize.height > 0
        
        if h || v {
            attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YJCollectionSectionFooter, with: IndexPath(item: 0, section: section))
            
            let x = h ? size.width : 0, y = v ? size.height : 0
            
            attributes.frame = CGRect(x: x, y: y, width: footerSize.width, height: footerSize.height)
            attributes.zIndex = 2
            delegate?.collectionView?(collectionView!, layout: self, relocationForElement: YJCollectionSectionFooter, currentAttributes: attributes)
            footerAttributes[section] = attributes
            allItemAttributes.append(attributes)
            
            size = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
        }
        
        let count = waterCounts[section]!
        for idx in 0..<count {
            itemSizes[idx] = size
        }
        
        allItemSizes[section] = itemSizes
    }
    
    fileprivate func layoutItemsAndBackground(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, minimumWaterSpacing: CGFloat, minimumItemSpacing: CGFloat, for section: Int) {
        
        let itemCount = collectionView!.numberOfItems(inSection: section)
        var itemAttributes = [UICollectionViewLayoutAttributes]()
        guard var itemSizes = allItemSizes[section] else {
            return
        }
        let sectionInset = sectionInsets[section]!
        var preX: CGFloat = 0
        var preY: CGFloat = 0
        
        let nextIdx = allItemAttributes.count
        for idx in 0..<itemCount {
            let indexPath = IndexPath(item: idx, section: section)
            
            let index = shortestIndex(section: section)
            
            let waterWidth = waterWidths[section]![index]!
            
            var preTotalWidth: CGFloat = 0
            if index > 0 {
                preTotalWidth = waterWidths[section]!.reduce(0, { (result, arg) -> CGFloat in
                    if arg.0 >= index {
                        return result
                    }
                    return result + arg.1
                })
            }
            
            let xOffset = layoutDirection == .vertical ? sectionInset.left + preTotalWidth + minimumWaterSpacing * CGFloat(index) : itemSizes[index].width + ((idx > 0 && itemSizes[index].width != preX) ? minimumItemSpacing : 0)
            preX = xOffset
            let yOffset = layoutDirection == .vertical ? itemSizes[index].height + ((idx > 0 && itemSizes[index].height != preY) ? minimumItemSpacing : 0) : sectionInset.top + preTotalWidth + minimumWaterSpacing * CGFloat(index)
            preY = yOffset
            
            var itemSize: CGSize?
            if #available(iOS 9.0, *) {
                if enableMove && longGes.state == .changed {
                    if itemLayoutDatas == nil {
                        itemLayoutDatas = moveAction?.itemLayoutDatas(layout: self)
                    }
                    guard let _ = itemLayoutDatas else { return }
                    itemSize = itemLayoutDatas?[indexPath.item].size
                } else {
                    itemSize = delegate?.collectionView?(collectionView!, layout: self, ratioForItemAtIndexPath: indexPath) ?? itemRatio
                }
            } else {
                itemSize = delegate?.collectionView?(collectionView!, layout: self, ratioForItemAtIndexPath: indexPath) ?? itemRatio
            }
            
            
            var itemLength: CGFloat = 0.0
            
            let scale = layoutDirection == .vertical ? (itemSize!.height/itemSize!.width) : (itemSize!.width/itemSize!.height)
            if itemSize! > CGSize.zero {
                itemLength = waterWidth * scale
            }
            
            attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: layoutDirection == .vertical ? waterWidth : itemLength, height: layoutDirection == .vertical ? itemLength : waterWidth)
            attributes.zIndex = 1
            delegate?.collectionView?(collectionView!, layout: self, relocationForElement: nil, currentAttributes: attributes)
            itemAttributes.append(attributes)
            allItemAttributes.append(attributes)
            
            itemSizes[index] = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
            allItemSizes[section] = itemSizes
        }
        if let firstItemAttr = itemAttributes.first {
            let hasBackground = delegate?.collectionView?(collectionView!, layout: self, hasBackgroundInSection: section) ?? hasSectionBackground
            if hasBackground {
                let backgroundAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YJCollectionSectionBackground, with: IndexPath(item: 0, section: section))
                backgroundAttr.frame.origin.x = firstItemAttr.frame.minX
                backgroundAttr.frame.origin.y = firstItemAttr.frame.minY
                backgroundAttr.frame.size.width = layoutDirection == .vertical ? collectionView!.bounds.size.width - sectionInset.left - sectionInset.right : itemSizes[longestIndex(section: section)].width - firstItemAttr.frame.minX
                backgroundAttr.frame.size.height = layoutDirection == .horizontal ? collectionView!.bounds.size.height - sectionInset.top - sectionInset.bottom : itemSizes[longestIndex(section: section)].height - firstItemAttr.frame.minY
                backgroundAttr.zIndex = 0
                delegate?.collectionView?(collectionView!, layout: self, relocationForElement: YJCollectionSectionBackground, currentAttributes: backgroundAttr)
                backgroundAttributes[section] = backgroundAttr
                allItemAttributes.insert(backgroundAttr, at: nextIdx)
            }
        }
        
        
        sectionItemAttributes.append(itemAttributes)
    }
    
    fileprivate func reset() {
        headerAttributes.removeAll(keepingCapacity: false)
        footerAttributes.removeAll(keepingCapacity: false)
        unionRects.removeAll(keepingCapacity: false)
        allItemSizes.removeAll(keepingCapacity: false)
        waterWidths.removeAll(keepingCapacity: false)
        miniItemSpaces.removeAll(keepingCapacity: false)
        miniWaterSpaces.removeAll(keepingCapacity: false)
        waterCounts.removeAll(keepingCapacity: false)
        sectionInsets.removeAll(keepingCapacity: false)
        allItemAttributes.removeAll(keepingCapacity: false)
        sectionItemAttributes.removeAll(keepingCapacity: false)
        backgroundAttributes.removeAll(keepingCapacity: false)
        
        if #available(iOS 9.0, *) {
            if let enable = moveAction?.enableMoveItem(self) {
                enableMove = enable
            }
        }
    }
    
    @available(iOS 9.0, *)
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            if let datas = moveAction?.itemLayoutDatas(layout: self) {
                itemLayoutDatas = datas
                collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            }
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView?.endInteractiveMovement()
            itemLayoutDatas = nil
        default:
            collectionView?.cancelInteractiveMovement()
            itemLayoutDatas = nil
        }
    }
}


// MARK: - move
extension RTWaterFlowLayout {
    @available(iOS 9.0, *)
    open override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        //同一分区，不同item
        if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
            if let _ = itemLayoutDatas {
                moveItem(&itemLayoutDatas!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.first!)
            }
        }
        
        return context
    }
    
    @available(iOS 9.0, *)
    open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attr = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attr.alpha = 0.75
        
        return attr
    }
}


