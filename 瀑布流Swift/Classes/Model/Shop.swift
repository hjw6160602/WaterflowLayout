//
//  Shop.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/30.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit

class Shop: NSObject {

    @objc var w : CGFloat = 0
    @objc var h : CGFloat = 0
    @objc var img = ""
    @objc var price = ""

    init(dict: [String: Any]) {
        super.init()
//        setValuesForKeys([String : Any])
        setValuesForKeys(dict)
    }
}
