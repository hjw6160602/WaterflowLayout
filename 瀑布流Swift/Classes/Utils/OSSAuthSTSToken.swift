//
//  OSSAuthSTSToken.swift
//  瀑布流Swift
//
//  Created by saidicaprio on 2019/4/3.
//  Copyright © 2019 SaiDicaprio. All rights reserved.
//

import UIKit
import AliyunOSSiOS

fileprivate let HPPT_PREFIX = "http://"
fileprivate let OSS_ENDPOINT = "oss-cn-shanghai.aliyuncs.com"
fileprivate let OSS_STSTOKEN_URL = "https://saidicaprio.xyz/osssts/"

protocol OSSAuthSTSTokenDelegate {
    func authSTSTokenFinished(_ imgs:[String])
}

class OSSAuthSTSToken: NSObject {
    var delegate:OSSAuthSTSTokenDelegate?
    var bucketName = ""
    var extType = ""
    
    // client 要当成属性 否则会报错
    var mClient: OSSClient!
    
    override init() {
        super.init()
    }
    
    convenience init(delegate:OSSAuthSTSTokenDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public func OSSRequestSTSToken() {
//      let mProvider = OSSStsTokenCredentialProvider(accessKeyId: STS_KEYID, secretKeyId: STS_SECRET, securityToken: STS_TOKEN)
        let mProvider = OSSAuthCredentialProvider(authServerUrl: OSS_STSTOKEN_URL)
        mClient = OSSClient(endpoint: HPPT_PREFIX + OSS_ENDPOINT, credentialProvider: mProvider)
        getBucket()
    }
    
    private func getBucket() -> Void {
        let request = OSSGetBucketRequest()
        request.bucketName = bucketName
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
            var imgs:[String] = []
            if let array = result {
                for objectInfo in array {
                    let dict = objectInfo as? NSDictionary
                    let name = dict?["Key"] as? String
                    if let str = name {
                        let url = HPPT_PREFIX + bucketName + "." + OSS_ENDPOINT + "/" + str
                        if url.hasSuffix(extType) {
                            imgs.append(url)
                        }
                    }
                }
            }
            self.delegate?.authSTSTokenFinished(imgs)
        }
    }
}

fileprivate let STS_KEYID = "STS.NHBrKCRVjzWq5C3Zr8mesR1kp"
fileprivate let STS_SECRET = "EXT11UEXtKuEjdshcxYLFD4ddTDkxfMrz38XKKDC5Cfz"
fileprivate let STS_TOKEN = ""
