//
//  WaterfallLayout.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/26.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit


protocol ConnectionDelegate {
    func onResponseResult(response:NSDictionary)
}

protocol WaterflowLayoutDelegate{
    func waterflowLayout(layout:WaterfallLayout, heightForItemAtIndex index:Int, itemWidth:CGFloat) -> CGFloat
    
}

class WaterfallLayout: UICollectionViewLayout {
    /** 代理 */
    var delegate:WaterflowLayoutDelegate?
    /** 内容的高度 */
    var contentHeight:CGFloat = 0
    /** 边缘间距 */
    lazy var edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    /** 默认的列数 */
    lazy var columnCount = 3;
    /** 每一列之间的间距 */
    lazy var columnMargin = 10;
    /** 每一行之间的间距 */
    lazy var rowMargin = 10;
    /** cell的属性数组 */
    lazy var attrsArray:[UICollectionViewLayoutAttributes] = []
    /** cell的高度数组 */
    lazy var columnHeights:[CGFloat] = []
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentHeight = 0
        
        // 清除以前计算的所有高度
        columnHeights.removeAll()
        
        for _ in 0 ..< columnCount {
            columnHeights.append(edgeInsets.top)
        }
        
        // 清除之前所有的布局属性
        attrsArray.removeAll()
        
        // 开始创建每一个cell对应的布局属性
        let count = collectionView!.numberOfItemsInSection(0)
        
        for i in 0..<count{//注意这里必须是 ..< 小于 不然会报错
            // 创建位置
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            
            // 获取indexPath位置cell对应的布局属性
            let attrs = layoutAttributesForItemAtIndexPath(indexPath)
            
            attrsArray.append(attrs!)
        }
    }
    
    /**
     * 返回indexPath位置cell对应的布局属性
     * 这个方法拿不到cell
     */
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        // 创建布局属性
        let attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

        // collectionView的宽度
        let collectionViewW = collectionView!.frame.size.width;

        // 设置布局属性的frame

        let w = (collectionViewW - edgeInsets.left - edgeInsets.right - CGFloat((columnCount - 1) * columnMargin)) / CGFloat(columnCount)
        
        let h = delegate!.waterflowLayout(self, heightForItemAtIndex: indexPath.item, itemWidth: w)

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
        attrs.frame = CGRectMake(x, y, w, h)

        // 更新最短那列的高度
        columnHeights[destColumn] = CGRectGetMaxY(attrs.frame)

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
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSizeMake(0, contentHeight + edgeInsets.bottom);
    }
}

/** 
 * 总结：
 * 1. 重写方法：prepareLayout 中初始化布局属性数组 (只有在这个方法需要调用super)
 * 2. 重写方法：layoutAttributesForItemAtIndexPath 中为每一个indexPath对应的cell初始化布局属性attrs
 * 3. 重写方法：layoutAttributesForElementsInRect 中返回所有cell的布局属性数组 attrsArray
 **/
