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

private let OSS_STSTOKEN_URL: String = "GKAC532YJ813I30Y8EaJWw69e46oBVCMHx6wE2Sh1AxWSnFVFHw2GRzbmJDcv2XN"
private let OSS_ENDPOINT: String = "http://oss-cn-shanghai.aliyuncs.com"
private let OSS_BUCKET_PRIVATE: String = "saidicaprio"

class ViewController: UIViewController {

    var collectionView: UICollectionView?
    var mClient: OSSClient!
    
    lazy var shops:[Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        initRefresh()
        
        initOSSImgs()
    }
    
    private func initOSSImgs() {
        var mProvider = OSSStsTokenCredentialProvider(accessKeyId: "LTAIfMo9OXLcemlR", secretKeyId: "87srILQj0XKblSUtKWAaRVoFoDmutE", securityToken: "GKAC532YJ813I30Y8EaJWw69e46oBVCMHx6wE2Sh1AxWSnFVFHw2GRzbmJDcv2XN") as? OSSCredentialProvider

//        let mProvider = OSSAuthCredentialProvider(authServerUrl: OSS_STSTOKEN_URL)
        
        mClient = OSSClient(endpoint: OSS_ENDPOINT, credentialProvider: mProvider!)
        
        getBucket()
        // 可选参数，具体含义参考：https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucket
        // getBucket.marker = @"";
        // getBucket.prefix = @"";
        // getBucket.delimiter = @"";
        
//        var getBucketTask: OSSTask? = mClient.getBucket(getBucket)
//        getBucketTask?.continue(withBlock: { task in
//            if task?.error == nil {
//                var result: OSSGetBucketResult? = task?.result
//                print("get bucket success!")
//                for objectInfo in (result?.contents)! {
//                    print("list object: \(objectInfo)")
//                }
//            } else {
//                if let error = task?.error {
//                    print("get bucket failed, error: \(error)")
//                }
//            }
//            return nil
//        })
    }
    
    private func getBucket() -> Void {
        let request = OSSGetBucketRequest()
        request.bucketName = OSS_BUCKET_PRIVATE
        
        let task = mClient.getBucket(request)
        task.continue( { (t) -> Any? in
            if let result = t.result as? OSSGetBucketResult {
                self.showResult(task: OSSTask(result: result.contents as AnyObject))
            }else
            {
                self.showResult(task: t)
            }
            return nil
        })
    }
    
    private func showResult(task: OSSTask<AnyObject>?) -> Void {
        if (task?.error != nil) {
            let error: NSError = (task?.error)! as NSError
            self.ossAlert(title: "error", message: error.description)
        }else
        {
            let result = task?.result
            self.ossAlert(title: "notice", message: result?.description)
        }
    }
    
    func ossAlert(title: String?,message:String?) -> Void {
        DispatchQueue.main.async {
            let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alertCtrl.addAction(UIAlertAction(title: "confirm", style: UIAlertAction.Style.default, handler: { (action) in
                print("\(action.title!) has been clicked");
                alertCtrl.dismiss(animated: true, completion: nil)
            }))
            self.present(alertCtrl, animated: true, completion: nil)
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
            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
            
            self.shops.removeAll()
            
            for dict in shopsDictArray {
                let shop = Shop(dict: dict)
                self.shops.append(shop)
            }
            // 刷新数据
            self.collectionView!.reloadData()
            self.collectionView!.header.endRefreshing()
        }
    }
    
    @objc func loadMoreShops() {
        let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            let shopsDictArray = NSArray(contentsOfFile:path!) as! [[String : AnyObject]]
            for dict in shopsDictArray {
                let shop = Shop(dict: dict )
                self.shops.append(shop)
            }
            
            // 刷新数据
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
        
        cell.shop = self.shops[indexPath.item]
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.footer.isHidden = shops.count == 0
        print("\(shops.count)")
        return shops.count
    }
}

extension ViewController: WaterflowLayoutDelegate {
    func waterflowLayout(layout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        let shop = self.shops[index]
        return itemWidth * shop.h / shop.w;
    }
}



