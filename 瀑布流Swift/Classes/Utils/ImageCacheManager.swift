//
//  ImageCacheManager.swift
//  瀑布流Swift
//
//  Created by saidicaprio on 2019/4/3.
//  Copyright © 2019 SaiDicaprio. All rights reserved.
//

import UIKit
import Kingfisher

struct ImageCacheManager {
    
    static func FindImageInCache(imgs: [String], dict: NSMutableDictionary) {
        for item in imgs {
            if let url = URL(string: item) {
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        switch value.cacheType {
                        case .none:
                            let downloader = ImageDownloader.default
                            downloader.downloadImage(with: url) { result in
                                switch result {
                                case .success(let value):
                                    let size = value.image.size
                                    let image = OSSImage()
                                    image.w = size.width
                                    image.h = size.height
                                    dict.setValue(image, forKey: item)
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        default:
                            let size = value.image.size
                            let image = OSSImage()
                            image.w = size.width
                            image.h = size.height
                            dict.setValue(image, forKey: item)
                            print(image)
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
