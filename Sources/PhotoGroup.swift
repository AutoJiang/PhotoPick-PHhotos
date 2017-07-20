//
//  PhotoGroup.swift
//  GKitPhotoPick
//
//  Created by Auto Jiang on 2017/2/14.
//  Copyright © 2017年 Auto Jiang. All rights reserved.
//

import Foundation
import AssetsLibrary
import Photos

class PhotoGroup {
    
    var assetModels: [PhotoModel]?
    var assetGroup: PHAssetCollection
    
    init(assetGroup: PHAssetCollection) {
        self.assetGroup = assetGroup
    }
    
    func name() -> String? {
        let title = assetGroup.localizedTitle
        if title == "Slo-mo" {
            return "慢动作"
        }else if title == "Recently Added" {
            return "最近添加"
        }else if title == "Favorites" {
            return "最爱"
        }else if title == "Recently Deleted" {
            return "最近删除"
        }else if title == "Videos" {
            return "视频"
        }else if title == "All Photos" {
            return "所有照片"
        }else if title == "Selfies" {
            return "自拍"
        }else if title == "Screenshots" {
            return "屏幕快照"
        }
        else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    
}

class PhotoGroupManager {
    
    private func findAllGroups(groupType: PHAssetCollectionSubtype) -> [PhotoGroup] {
        var groups = Array<PhotoGroup>()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: groupType, options: nil)
        smartAlbums.enumerateObjects({ (collection, idx, stop) in
            groups.append(PhotoGroup(assetGroup: collection))
        })
        
        return groups
    }

    func findGroupGroupAll() -> [PhotoGroup]{
        return findAllGroups(groupType: .albumRegular)
    }
    
//pragma mark - 获取指定相册内的所有图片
    func findAllPhotoModelsByGroup(by group: PhotoGroup) -> [PhotoModel]{
        var photoModels = [PhotoModel]()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(in: group.assetGroup, options: options)
        result.enumerateObjects({ (obj, idx, stop) in
            photoModels.append(PhotoModel(asset: obj, isSelect: false))
        })
        return photoModels
    }
    
    func findAllPhotoModels() -> [PhotoModel]{
        let groups = findAllGroups(groupType: .smartAlbumUserLibrary)
        var photoModels = [PhotoModel]()
        for group in groups {
            let models = self.findAllPhotoModelsByGroup(by: group)
            photoModels.append(contentsOf: models)
        }
        return photoModels
    }
}
