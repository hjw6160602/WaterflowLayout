//
//  WaterfallShopCell.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/30.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit
import Kingfisher

class WaterfallShopCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var urlStr: String = "" {
        didSet {
            let url = URL(string: urlStr)
            // 1.图片
            imageView.kf.indicatorType = .activity
            
            imageView.kf.setImage(with: url)
            
            // 2.价格
//            priceLabel.text = shop!.price
        }
    }
    
    /// 获取网络图片尺寸
    ///
    /// - Parameter url: 网络图片链接
    /// - Returns: 图片尺寸size
    class func getImageSize(_ url: String?) -> CGSize {
        guard let urlStr = url else {
            return CGSize.zero
        }
        
        let tempUrl = URL(string: urlStr)
        let imageSourceRef = CGImageSourceCreateWithURL(tempUrl! as CFURL, nil)
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if let imageSRef = imageSourceRef {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSRef, 0, nil)
            if let imageP = imageProperties {
                let imageDict = imageP as Dictionary
                width = imageDict[kCGImagePropertyPixelWidth] as! CGFloat
                height = imageDict[kCGImagePropertyPixelHeight] as! CGFloat
            }
        }
        return CGSize(width: width, height: height)
    }
}
