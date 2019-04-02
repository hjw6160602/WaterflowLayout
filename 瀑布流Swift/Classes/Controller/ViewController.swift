//
//  ViewController.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/26.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit
import AliyunOSSiOS

private let ReuseID = "CollectionViewCellReuseID"
private let ShopCell = "WaterfallShopCell"
private let path = Bundle.main.path(forResource: "Shop.plist", ofType: nil)

private let HPPT_PREFIX = "http://"
private let OSS_ENDPOINT = "oss-cn-shanghai.aliyuncs.com"
private let OSS_BUCKET_NAME = "saidicaprio"

private let OSS_STSTOKEN_URL = "https://saidicaprio.xyz/osssts/"

class ViewController: UIViewController {

    var collectionView: UICollectionView?
    var mClient: OSSClient!
    
//    lazy var shops:[Shop] = []
    lazy var imgs:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initOSSImgs()
        initCollectionView()
        initRefresh()
    }
    
    private func initOSSImgs() {
//        let mProvider = OSSStsTokenCredentialProvider(accessKeyId: STS_KEYID, secretKeyId: STS_SECRET, securityToken: STS_TOKEN)
        let mProvider = OSSAuthCredentialProvider(authServerUrl: OSS_STSTOKEN_URL)
        mClient = OSSClient(endpoint: HPPT_PREFIX + OSS_ENDPOINT, credentialProvider: mProvider)
        getBucket()
    }
    
    private func getBucket() -> Void {
        let request = OSSGetBucketRequest()
        request.bucketName = OSS_BUCKET_NAME
        
        let task = mClient.getBucket(request)
        task.continue( { (t) -> Any? in
            if let result = t.result as? OSSGetBucketResult {
                self.showResult(task: OSSTask(result: result.contents as AnyObject))
            } else {
                self.showResult(task: t)
            }
            return nil
        })
    }
    
    private func showResult(task: OSSTask<AnyObject>?) -> Void {
        if (task?.error != nil) {
            let error: NSError = (task?.error)! as NSError
            print(error.description)
        } else {
            let result = task?.result as? NSArray
            if let array = result {
                for objectInfo in array {
                    let dict = objectInfo as? NSDictionary
                    let name = dict?["Key"] as? String
                    if let str = name {
                        let url = HPPT_PREFIX + OSS_BUCKET_NAME + "." + OSS_ENDPOINT + "/" + str
                        if url.hasSuffix(".png") {
                            self.imgs.append(url)
                        }
                    }
                }
            }
            print(self.imgs)
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
        collectionView?.backgroundColor = UIColor.lightGray
        view.addSubview(collectionView!)
    }
    
    private func initRefresh() {
        collectionView!.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ViewController.loadNewShops))
        
        collectionView!.header.beginRefreshing()
        collectionView!.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ViewController.loadMoreShops))
        collectionView!.footer.isHidden = true
    }
    
    @objc func loadNewShops() {
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
//
//            self.shops.removeAll()
//
//            for dict in shopsDictArray {
//                let shop = Shop(dict: dict)
//                self.shops.append(shop)
//            }
//            // 刷新数据
//            self.collectionView!.reloadData()
//            self.collectionView!.header.endRefreshing()
        }
    }
    
    @objc func loadMoreShops() {
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
//            for dict in shopsDictArray {
//                let shop = Shop(dict: dict )
//                self.shops.append(shop)
//            }
//
//            // 刷新数据
//            self.collectionView!.reloadData()
//            self.collectionView!.footer.endRefreshing()
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseID, for: indexPath as IndexPath)
            as! WaterfallShopCell
        cell.urlStr = self.imgs[indexPath.item]
//        cell.shop = self.shops[indexPath.item]
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.footer.isHidden = imgs.count == 0
//        print("\(imgs.count)")
        return imgs.count
    }
}

extension ViewController: WaterflowLayoutDelegate {
    func waterflowLayout(layout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
//        let imgUrl = self.imgs[index]
//        return itemWidth * shop.h / shop.w;
        return itemWidth * 200 / 100;
    }
}

private let STS_KEYID = "STS.NHBrKCRVjzWq5C3Zr8mesR1kp"
private let STS_SECRET = "EXT11UEXtKuEjdshcxYLFD4ddTDkxfMrz38XKKDC5Cfz"
private let STS_TOKEN = ""
