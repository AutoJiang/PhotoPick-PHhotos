//
//  CellModel.swift
//  PhotoPick
//
//  Created by jiang aoteng on 2016/12/18.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit
import Photos

public class PhotoModel: NSObject {
    var asset: PHAsset
    var isSelect: Bool = false
    var isLastSelect: Bool = false
    
    let option = PHImageRequestOptions()

    static var idx = 0
    
    var thumbnail: UIImage?
    
    var isCloud: Bool = false
    
    private var image: UIImage?
    
    ///显示缩略图
    func thumbnail(callBack:@escaping ((UIImage?) -> Void)) -> Void {
        var index = 1000
        PhotoModel.idx = PhotoModel.idx + 1
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize

        self.option.isNetworkAccessAllowed = false
        self.option.isSynchronous = true
        self.option.deliveryMode = .highQualityFormat
        
        let width: CGFloat = 250
        let height = width * CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth)
        
        PHImageManager.default().requestImage(for: self.asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: self.option) { [weak self] (image, info ) in
//                        !isCacell && !isError && !isDegraded
//            let isCacell = info?[PHImageCancelledKey] as! Bool
//            let isError = info?[PHImageErrorKey] as! Bool
            guard let info = info else {
                return
            }

            let isDegraded = info[PHImageResultIsDegradedKey] as! Bool
            if !isDegraded {
                self?.thumbnail = image
            }
            callBack(self?.thumbnail)
            
            if info.keys.contains(PHImageResultIsInCloudKey) {
//                self?.isCloud = !(info[PHImageResultIsInCloudKey] != nil)
                self?.isCloud = info[PHImageResultIsInCloudKey] as! Bool
//                let isCancelled = info[PHImageCancelledKey] as! Bool
//                let isError = info[PHImageErrorKey] as! Bool
                let isDegraded = info[PHImageResultIsDegradedKey] as! Bool
                if !isDegraded {
                    self?.isCloud = false
                }else{
                    self?.isCloud = true
                }
            }else{
                self?.isCloud = false
            }
            index = index + 1
        }
    }
    ///原图
    func originalImage(callBack:@escaping ((UIImage) -> Void)) -> Void {
//        option.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
            guard let image = image else {
                return
            }
            callBack(image)
        }
    }
    
    ///返回压缩图 compress
    public func image(index:Int, callBack:@escaping ((UIImage?, _ index: Int) -> Void)) -> Void {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast;
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = false
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        let quality = PhotoPickConfig.shared.jpgQuality
        PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { [weak self] (image, info) in
            let isDegraded = info?[PHImageResultIsDegradedKey] as! Bool
            if !isDegraded {
                self?.image = image
            }
            callBack(self?.image, index)
        }
    }

    
    init(asset: PHAsset, isSelect:Bool) {
        self.asset = asset
        self.isSelect = isSelect
        option.resizeMode = .fast;
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .opportunistic
        option.isSynchronous = false
        super.init()
    }

    override public func isEqual(_ object: Any?) -> Bool {
        let obj = object as! PhotoModel
        return obj.asset == self.asset
    }
    
    static func convertToPickedPhotos(photoModels: [PhotoModel]) -> [PickedPhoto] {
        return photoModels.map{ PickedPhoto(asset: $0.asset)}
    }
}
