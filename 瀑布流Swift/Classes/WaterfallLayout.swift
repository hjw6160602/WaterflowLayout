//
//  WaterfallLayout.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/26.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit

//MARK:- 提供代理来提供一些自定义参数
protocol WaterflowLayoutDelegate{
    
    /** 
     * requried: 提供每一个cell的高度
     */
    func waterflowLayout(layout:WaterfallLayout, heightForItemAtIndex index:Int, itemWidth:CGFloat) -> CGFloat
    
    /**
     * optional: 提供列数
     */
//    func columnCountInWaterflowLayout(waterflowLayout : WaterfallLayout) -> CGFloat
    
    /**
     * optional: 提供列间距
     */
//    func columnMarginInWaterflowLayout(waterflowLayout : WaterfallLayout) -> CGFloat
    
    /**
     * optional: 提供行间距
     */
//    func rowMarginInWaterflowLayout(waterflowLayout : WaterfallLayout) -> CGFloat
    
    /**
     * optional: 提供edgeInsets
     */
//    func edgeInsetsInWaterflowLayout(waterflowLayout : WaterfallLayout) -> UIEdgeInsets
}

class WaterfallLayout: UICollectionViewLayout {
    /** 代理 */
    var delegate:WaterflowLayoutDelegate?
    /** 内容的高度 */
    var contentHeight:CGFloat = 0
    /** 边缘间距 */
    lazy var edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    /** 默认的列数 */
    lazy var columnCount = 2
    /** 每一列之间的间距 */
    lazy var columnMargin = 10
    /** 每一行之间的间距 */
    lazy var rowMargin = 10
    /** cell的属性数组 */
    lazy var attrsArray:[UICollectionViewLayoutAttributes] = []
    /** cell的高度数组 */
    lazy var columnHeights:[CGFloat] = []
    
    override func prepare() {
        super.prepare()
        
        contentHeight = 0
        
        // 清除以前计算的所有高度
        columnHeights.removeAll()
        
        for _ in 0 ..< columnCount {
            columnHeights.append(edgeInsets.top)
        }
        
        // 清除之前所有的布局属性
        attrsArray.removeAll()
        
        // 开始创建每一个cell对应的布局属性
        let count = collectionView!.numberOfItems(inSection: 0)
        
        for i in 0..<count{//注意这里必须是 ..< 小于 不然会报错
            // 创建位置
            let indexPath = NSIndexPath(item: i, section: 0)
            
            // 获取indexPath位置cell对应的布局属性
            let attrs = layoutAttributesForItem(at: indexPath as IndexPath)
            
            attrsArray.append(attrs!)
        }
    }
    
    /**
     * 返回indexPath位置cell对应的布局属性
     * 这个方法拿不到cell
     */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // 创建布局属性
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)

        // collectionView的宽度
        let collectionViewW = collectionView!.frame.size.width;

        // 设置布局属性的frame

        let w = (collectionViewW - edgeInsets.left - edgeInsets.right - CGFloat((columnCount - 1) * columnMargin)) / CGFloat(columnCount)
        
        let h = delegate!.waterflowLayout(layout: self, heightForItemAtIndex: indexPath.item, itemWidth: w)

        // 找出高度最短的那一列
        var destColumn = 0
        var minColumnHeight = columnHeights[0]
        for i in 0 ..< columnCount {
            // 取得第i列的高度
            let columnHeight = columnHeights[i]

            if minColumnHeight > columnHeight {
                minColumnHeight = columnHeight
                destColumn = i
            }
        }

        let x = edgeInsets.left + CGFloat(destColumn) * (w + CGFloat(columnMargin))
        var y = minColumnHeight
        if y != edgeInsets.top {
            y += CGFloat(rowMargin)
        }
        attrs.frame = CGRect(x: x, y: y, width: w, height: h)
        
        // 更新最短那列的高度
        columnHeights[destColumn] = attrs.frame.maxY

        // 记录内容的高度
        let columnHeight = columnHeights[destColumn]
        if contentHeight < columnHeight{
            contentHeight = columnHeight
        }
        return attrs;
    }
    
    /**
     * 决定cell的排布
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: contentHeight + edgeInsets.bottom)
    }
}

/** 
 * 总结：
 * 1. 重写方法：prepareLayout 中初始化布局属性数组 (只有在这个方法需要调用super)
 * 2. 重写方法：layoutAttributesForItemAtIndexPath 中为每一个indexPath对应的cell初始化布局属性attrs
 * 3. 重写方法：layoutAttributesForElementsInRect 中返回所有cell的布局属性数组 attrsArray
 **/
