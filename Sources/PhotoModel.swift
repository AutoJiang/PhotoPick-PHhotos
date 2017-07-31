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
    
    private var image: UIImage?
    
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
    public func image(index:Int, callBack:@escaping ((UIImage?, _ index: Int) -> Void)) -> Void {
        let option = PHImageRequestOptions()
        option.resizeMode = .fast;
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = false
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        let quality = PhotoPickConfig.shared.jpgQuality
//        let size = CGSize(width: CGFloat(asset.pixelWidth)*quality, height: CGFloat(asset.pixelHeight)*quality)
//        let size = UIScreen.main.bounds.size
//        let size = CGSize(width: UIScreen.main.bounds.size.width*2, height: UIScreen.main.bounds.height*2)
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
