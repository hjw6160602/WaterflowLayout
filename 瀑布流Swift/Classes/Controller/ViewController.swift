//
//  ViewController.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/26.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit
import Kingfisher

private let ReuseID = "CollectionViewCellReuseID"
private let ShopCell = "WaterfallShopCell"
//private let path = Bundle.main.path(forResource: "Shop.plist", ofType: nil)

class ViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    var collectionView: UICollectionView?
    let ossAuth = OSSAuthSTSToken()
    
    lazy var imgs:[String] = []
    var images = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initOSSImgs()
        initCollectionView()
        initRefresh()
    }
    
    private func initOSSImgs() {
        if let imgs = userDefaults.array(forKey: "imgs") {
            if imgs is [String] {
                self.imgs = imgs as! [String]
                let value = userDefaults.object(forKey: "images")
                if value is NSMutableDictionary {
                    let dict = value as! NSMutableDictionary
                    if dict.count > 0 {
                        self.images = dict
                    }
                }
                ImageCacheManager.FindImageInCache(imgs: self.imgs, dict: self.images)
            }
        } else {
            ossAuth.delegate = self
//            ossAuth.bucketName = "saidicaprio"
//            ossAuth.extType = ".png"
            ossAuth.bucketName = "sai-example"
            ossAuth.extType = ".gif"
            ossAuth.OSSRequestSTSToken()
        }
    }
    
    private func initCollectionView() {
        // 创建布局
        let layout = WaterfallLayout()
        layout.delegate = self
        
        collectionView = UICollectionView(frame:view.bounds, collectionViewLayout: layout)
        
        let nib = UINib(nibName:ShopCell, bundle:nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: ReuseID)

        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = UIColor.clear
        view.addSubview(collectionView!)
    }
    
    private func initRefresh() {
        collectionView!.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ViewController.loadNewItems))
        
        collectionView!.header.beginRefreshing()
        collectionView!.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ViewController.loadMoreItems))
        collectionView!.footer.isHidden = true
    }
    
    @objc func loadNewItems() {
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
//            self.shops.removeAll()
//
//            for dict in shopsDictArray {
//                let shop = Shop(dict: dict)
//                self.shops.append(shop)
//            }
//            // 刷新数据
            self.collectionView!.reloadData()
            self.collectionView!.header.endRefreshing()
        }
    }
    
    @objc func loadMoreItems() {
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
//            for dict in shopsDictArray {
//                let shop = Shop(dict: dict )
//                self.shops.append(shop)
//            }
//
//            // 刷新数据
            self.collectionView!.reloadData()
            self.collectionView!.footer.endRefreshing()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseID, for: indexPath as IndexPath)
            as! WaterfallShopCell
        cell.urlStr = imgs[indexPath.item]
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.images.count > 0 {
            userDefaults.setValue(self.images, forKey: "images")
        }
        collectionView.footer.isHidden = imgs.count == 0
        return imgs.count
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlStr = imgs[indexPath.item]
        if let url = URL(string: urlStr) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    let masterViewController: PictureMasterViewController = PictureMasterViewController(nibName: "PictureMasterViewController", bundle: nil)
                    masterViewController.showImage(value.image, in:self)
                case .failure(let error):
                    print(error)
                }
            }
        }
        //            Initialized with custom gestures enabled
        //                masterViewController.showImage(pictureMasterImageView.image!, in: self, with: [.Rotate, .Zoom, .Drag])
        //            Initialized with no gestures enabled
        //                masterViewController.showImage(pictureMasterImageView.image!, in: self, with: nil)
        //            Initialized with all gestures enabled
    }
}
extension ViewController: WaterflowLayoutDelegate {
    func waterflowLayout(layout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        let url = imgs[index]
        if let item = images.object(forKey: url) {
            if item is CGFloat {
                let aspectRatio = item as! CGFloat
                return itemWidth * aspectRatio;
            }
        }
        return itemWidth * 120 / 100;
    }
}

extension ViewController: OSSAuthSTSTokenDelegate {
    func authSTSTokenFinished(_ imgs: [String]) {
        self.imgs = imgs
        userDefaults.set(imgs, forKey: "imgs")
        ImageCacheManager.FindImageInCache(imgs: self.imgs, dict: self.images)
    }
}
