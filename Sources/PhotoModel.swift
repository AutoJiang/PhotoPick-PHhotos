//
//  CellModel.swift
//  PhotoPick
//
//  Created by jiang aoteng on 2016/12/18.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit
import Photos

class PhotoModel: NSObject {
    var asset: PHAsset
    var isSelect: Bool = false
    var isLastSelect: Bool = false
    
    let option = PHImageRequestOptions()

    static var idx = 0
    
    private var thumbnail: UIImage?
    
    ///显示缩略图
    func thumbnail(callBack:@escaping ((UIImage?) -> Void)) -> Void {
        var index = 1000
        PhotoModel.idx = PhotoModel.idx + 1
        let idx = PhotoModel.idx
        print("\(idx)-----start-----\(index)-----\(Thread.current)")
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        let imageManager = PHCachingImageManager.default()
//        imageManager.allowsCachingHighQualityImages = false
//        downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];

        let height = 200 * CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth)
        imageManager.requestImage(for: self.asset, targetSize: CGSize(width: 200, height: height), contentMode: .aspectFit, options: self.option) { [weak self] (image, info ) in
//                        !isCacell && !isError && !isDegraded
//            let isCacell = info?[PHImageCancelledKey] as! Bool
//            let isError = info?[PHImageErrorKey] as! Bool
            let isDegraded = info?[PHImageResultIsDegradedKey] as! Bool
            if !isDegraded {
                self?.thumbnail = image
            }
            callBack(self?.thumbnail)
            index = index + 1
            print("\(idx)-----add-----\(index)-----\(Thread.current)")
        }
        print("\(idx)-----end-----\(index)-----\(Thread.current)")
    }
    ///原图
    func originalImage(callBack:@escaping ((UIImage) -> Void)) -> Void {
//        option.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
            guard let image = image else {
                print("error")
                return
            }
            callBack(image)
        }
    }
    
    ///返回压缩图 compress
    public func image(callBack:@escaping ((UIImage?) -> Void)) -> Void {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast;
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        let quality = PhotoPickConfig.shared.jpgQuality
//        let size = CGSize(width: CGFloat(asset.pixelWidth)*quality, height: CGFloat(asset.pixelHeight)*quality)
//        let size = UIScreen.main.bounds.size
        let size = CGSize(width: UIScreen.main.bounds.size.width*2, height: UIScreen.main.bounds.height*2)
        PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
            
//            let isDegraded = info?[PHImageResultIsDegradedKey] as! Bool
//            if !isDegraded {
            if let image = image {
                callBack(image)
            }

//            }
        }
    
//        PHCachingImageManager.default().requestImageData(for: asset, options: option) { (data, dataUTI, orientation, info) in
//            let isCancel = info?[PHImageCancelledKey] as! Bool
//            let isError = info?[PHImageErrorKey] as! Bool
//            let downloadFinined = !(isCancel && !isError)
//            if let data = data {
//                
//                callBack(UIImage(data: data))
//            }
//        }
        
    }
//    ▿ Optional<Dictionary<AnyHashable, Any>>
//    ▿ some : 6 elements
//    ▿ 0 : 2 elements
//    ▿ key : AnyHashable("PHImageResultRequestIDKey")
//    - value : "PHImageResultRequestIDKey"
//    - value : 285
//    ▿ 1 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsPlaceholderKey")
//    - value : "PHImageResultIsPlaceholderKey"
//    - value : 0
//    ▿ 2 : 2 elements
//    ▿ key : AnyHashable("PHImageResultDeliveredImageFormatKey")
//    - value : "PHImageResultDeliveredImageFormatKey"
//    - value : 4035
//    ▿ 3 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsDegradedKey")
//    - value : "PHImageResultIsDegradedKey"
//    - value : 0
//    ▿ 4 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsInCloudKey")
//    - value : "PHImageResultIsInCloudKey"
//    - value : 1
//    ▿ 5 : 2 elements
//    ▿ key : AnyHashable("PHImageResultWantedImageFormatKey")
//    - value : "PHImageResultWantedImageFormatKey"
//    - value : 4035

    
    
//    ▿ Optional<Dictionary<AnyHashable, Any>>
//    ▿ some : 11 elements
//    ▿ 0 : 2 elements
//    ▿ key : AnyHashable("PHImageResultRequestIDKey")
//    - value : "PHImageResultRequestIDKey"
//    - value : 286
//    ▿ 1 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsDegradedKey")
//    - value : "PHImageResultIsDegradedKey"
//    - value : 0
//    ▿ 2 : 2 elements
//    ▿ key : AnyHashable("PHImageFileURLKey")
//    - value : "PHImageFileURLKey"
//    - value : file:///var/mobile/Media/DCIM/101APPLE/IMG_1598.JPG
//    ▿ 3 : 2 elements
//    ▿ key : AnyHashable("PHImageFileSandboxExtensionTokenKey")
//    - value : "PHImageFileSandboxExtensionTokenKey"
//    - value : 03f7353e9e3d78d5f03a88adfaf3dada25f17627;00000000;00000000;000000000000001a;com.apple.app-sandbox.read;00000001;01000004;00000001024bbfd5;/private/var/mobile/Media/DCIM/101APPLE/IMG_1598.JPG
//    ▿ 4 : 2 elements
//    ▿ key : AnyHashable("PHImageResultDeliveredImageFormatKey")
//    - value : "PHImageResultDeliveredImageFormatKey"
//    - value : 9999
//    ▿ 5 : 2 elements
//    ▿ key : AnyHashable("PHImageFileUTIKey")
//    - value : "PHImageFileUTIKey"
//    - value : public.jpeg
//    ▿ 6 : 2 elements
//    ▿ key : AnyHashable("PHImageFileOrientationKey")
//    - value : "PHImageFileOrientationKey"
//    - value : 0
//    ▿ 7 : 2 elements
//    ▿ key : AnyHashable("PHImageResultOptimizedForSharing")
//    - value : "PHImageResultOptimizedForSharing"
//    - value : 0
//    ▿ 8 : 2 elements
//    ▿ key : AnyHashable("PHImageResultWantedImageFormatKey")
//    - value : "PHImageResultWantedImageFormatKey"
//    - value : 4035
//    ▿ 9 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsPlaceholderKey")
//    - value : "PHImageResultIsPlaceholderKey"
//    - value : 0
//    ▿ 10 : 2 elements
//    ▿ key : AnyHashable("PHImageResultIsInCloudKey")
//    - value : "PHImageResultIsInCloudKey"
//    - value : 0

    
    init(asset: PHAsset, isSelect:Bool) {
        self.asset = asset
        self.isSelect = isSelect
        option.resizeMode = .fast;
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .opportunistic
        option.isSynchronous = false
        super.init()
        
//        let imageManager = PHCachingImageManager.default()
//        let height = 200 * CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth)
//        imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: height), contentMode: .aspectFit, options: option) { (image, info ) in
//            self.thumbnail = image
//        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        let obj = object as! PhotoModel
        return obj.asset == self.asset
    }
    
    static func convertToPickedPhotos(photoModels: [PhotoModel]) -> [PickedPhoto] {
        return photoModels.map{ PickedPhoto(asset: $0.asset)}
    }
}
