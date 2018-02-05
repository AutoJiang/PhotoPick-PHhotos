//
//  PickedPhoto.swift
//  GKitPhotoPick
//
//  Created by Auto Jiang on 2017/2/13.
//  Copyright © 2017年 Auto Jiang. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
public class PickedPhoto: NSObject {
    enum PhotoType {
        case asset(asset: PHAsset)
        case image(image: UIImage)
    }
    
    private var asset: PHAsset?
    private var privateImage: UIImage?
    private let maxSidePixels: CGFloat = 1280
    private let minStretchSidePixels: CGFloat = 440
    
    static let path = "/Documents/PhotoPick/"
    
    ///原图
    public func originalImage(callBack:@escaping ((UIImage?) -> Void)) -> Void {
        guard let asset = asset else {
            callBack(privateImage)
            return
        }
        let option = PHImageRequestOptions()
        option.resizeMode = .fast;
        option.isNetworkAccessAllowed = true
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
            callBack(image)
        }
    }
    
    ///返回压缩图 compress
    public func image(callBack:@escaping ((UIImage?) -> Void)) -> Void {
        guard let asset = asset else {
            callBack(privateImage?.scaleToMaxSidePixels(maxSidePixels: self.maxSidePixels, minStretchSidePixels: self.maxSidePixels))
            return
        }
        let option = PHImageRequestOptions()
        option.resizeMode = .fast;
        option.isNetworkAccessAllowed = true
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        let quality = PhotoPickConfig.shared.jpgQuality
        let size = CGSize(width: CGFloat(asset.pixelWidth)*quality, height: CGFloat(asset.pixelHeight)*quality)
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option) { (image, info) in
            callBack(image)
        }
//        originalImage { [unowned self] image in
//            let compress = image

//            callBack(image?.scaleToMaxSidePixels(maxSidePixels: self.maxSidePixels, minStretchSidePixels: self.minStretchSidePixels))
//        }
    }
    
    ///是否为gif图
    public var isGIF: Bool
    
    ///若是gif, 使用Data数据流传输到服务器，注意该数据是原始未压缩的数据
    func data(callBack: @escaping ((Data?) -> Void)) {
        guard let asset = asset else {
            callBack(UIImagePNGRepresentation(privateImage!))
            return
        }
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImageData(for: asset, options: option) { (data, dataUTI, orientation, info) in
            let isCancel = info?[PHImageCancelledKey] as! Bool
            let isError = info?[PHImageErrorKey] as! Bool
            let downloadFinined = !(isCancel && !isError)
            if downloadFinined {
                callBack(data)
            }
        }
    }
    
    ///相册获取的图片
    init(asset: PHAsset) {
        self.asset = asset
        self.isGIF = false
        super.init()
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImageData(for: asset, options: option) { [weak self] (data, dataUTI, orientation, info) in
            if let type = dataUTI {
                self?.isGIF = type == kUTTypeGIF as String
            }
        }
    }
    //用于拍照时获取的图片
    init(image: UIImage) {
        self.privateImage = image
        self.isGIF = false
    }
    
    static func clearDisk(){
        let fileManager = FileManager.default
        let imagesPath: String = NSHomeDirectory() + PickedPhoto.path
        do {
            try fileManager.removeItem(atPath: imagesPath)
        } catch {
        }
    }
}
