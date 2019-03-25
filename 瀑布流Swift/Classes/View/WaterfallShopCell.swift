//
//  WaterfallShopCell.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/30.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit

class WaterfallShopCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var shop: Shop?{
        didSet{
            // 1.图片
//            imageView.sd_setImageWithURL(NSURL(string: shop!.img), placeholderImage: UIImage(named: "loading"))
            // 2.价格
            priceLabel.text = shop!.price
        }
    }
}
