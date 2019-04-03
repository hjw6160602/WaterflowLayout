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
        for urlStr in imgs {
            if dict[urlStr] != nil {
                break
            }
            if let url = URL(string: urlStr) {
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        switch value.cacheType {
                        case .none:
                            self.DownloadImage(urlStr: urlStr, dict: dict)
                        default:
                            let size = value.image.size
                            let aspectRatio = size.height / size.width
                            dict.setValue(aspectRatio, forKey: urlStr)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    static func DownloadImage(urlStr: String, dict: NSMutableDictionary) {
        if dict[urlStr] != nil {
            return
        }
        if let url = URL(string: urlStr) {
            let downloader = ImageDownloader.default
            downloader.downloadImage(with: url) { result in
                switch result {
                case .success(let value):
                    let size = value.image.size
                    let aspectRatio = size.height / size.width
                    dict.setValue(aspectRatio, forKey: urlStr)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

}
