//
//  Shop.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/30.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit

class Shop: NSObject {

    var w : CGFloat = 0
    var h : CGFloat = 0
    var img = ""
    var price = ""
    
    init(dict: [String: AnyObject])
    {
        super.init()
        setValuesForKeys(dict)
    }
    
}
