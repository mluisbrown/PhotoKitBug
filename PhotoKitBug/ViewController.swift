//
//  ViewController.swift
//  PhotoKitBug
//
//  Created by Michael Brown on 15/03/2016.
//  Copyright © 2016 Michael Brown. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btn256: UIButton!
    @IBOutlet weak var btn512: UIButton!
    
    var allAssets: PHFetchResult?
    let TARGET_SIZE = CGSize(width: 400, height: 400)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            if status == .Authorized {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.allAssets = self.allAssetsInDateOrder()
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func loadImage(sender: UIButton) {
        let targetSize = (sender == btn256 ? CGSize(width: 256, height: 256) : CGSize(width: 512, height: 512))

        if let firstAsset = allAssets?.firstObject as? PHAsset {
            let options = PHImageRequestOptions()
            
            options.networkAccessAllowed = false
            options.deliveryMode = .Opportunistic
            options.synchronous = false
            
            PHImageManager.defaultManager().requestImageForAsset(firstAsset, targetSize: targetSize, contentMode: .AspectFit, options: options) { (result, userInfo) -> Void in
                if let image = result {
                    NSLog("Image returned. Size: \(image.size.width)x\(image.size.height)")
                    self.imageView.image = image
                }
            }
        }
    }
    
    
    private func allAssetsInDateOrder() -> PHFetchResult {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.includeAssetSourceTypes = [.TypeUserLibrary, .TypeiTunesSynced, .TypeCloudShared]
        
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
    
}

