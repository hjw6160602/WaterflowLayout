//
//  ViewController.swift
//  瀑布流Swift
//
//  Created by shoule on 16/8/26.
//  Copyright © 2016年 SaiDicaprio. All rights reserved.
//

import UIKit


private let ReuseID = "CollectionViewCellReuseID"
private let ShopCell = "WaterfallShopCell"
private let path = Bundle.main.path(forResource: "Shop.plist", ofType: nil)

class ViewController: UIViewController {

    var collectionView: UICollectionView?
    
    lazy var shops:[Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        initRefresh()
    }
    
    private func initCollectionView(){
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



