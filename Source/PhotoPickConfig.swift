//
//  PhotoPickConfig.swift
//  GKitPhotoPick
//
//  Created by Auto Jiang on 2017/2/14.
//  Copyright © 2017年 Auto Jiang. All rights reserved.
//

import Foundation

//TODO 明确定义对外提供的参数（JPG压缩率、图片最大分辨率、长微博图片规则、是否需要GIF、是否显示拍照、选择图片数量控制、单张图片是否可以编辑、是否显示序号）

public class PhotoPickConfig: NSObject {
    
    /// 最多可选图片数量(默认1)
    public var maxSelectImagesCount: Int = 1
    
    /// 当返回JPG图片时自动进行的压缩系数(默认0.5)
    public var jpgQuality: CGFloat = 0.5

    /// TODO
    public var maxLongSidePixel: Int = 1280
    
    /// TODO
    public var maxShortSidePixel: Int = 720
    
    
    
}