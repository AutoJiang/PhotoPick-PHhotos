//
//  BigPhotoCell.swift
//  PhotoPick
//
//  Created by jiang aoteng on 2016/12/18.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit
import Foundation

class BigPhotoCell: UICollectionViewCell,UIAccelerometerDelegate{
    
    public var zoomScrollView = PhotoZoomScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(zoomScrollView);
    }
    
    static var index: Int = 0
    
    func bind(model: PhotoModel, index: Int){
        BigPhotoCell.index = index
        print("BigPhotoCell.index = \(BigPhotoCell.index)    index = \(index)")
        //之前已经加载过的直接拿来用
//        if let image = model.thumbnail {
//            setLayoutScrollView(image: image)
//            return
//        }
        model.image(index: index) { (image, idx) in
            print("BigPhotoCell.index = \(BigPhotoCell.index)    index = \(idx)")
            guard BigPhotoCell.index == idx, let image = image else {
                return
            }
            self.setLayoutScrollView(image: image)
        }

    }
    
    func setLayoutScrollView(image: UIImage) -> Void {
        print(Thread.current)
        self.zoomScrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.zoomScrollView.zoomScale = 1.0
        // 将scrollview的contentSize还原成缩放前
        
        self.zoomScrollView.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        //            AssetTool.imageFromAsset(representation: representation)
        self.zoomScrollView.zoomImageView.image = image
        let width = self.frame.width
        let height = (width * CGFloat(image.size.height)) / CGFloat(image.size.width)
        self.zoomScrollView.zoomImageView.frame.size = CGSize(width: width, height: height)
        self.zoomScrollView.zoomImageView.center = CGPoint(x: width/2, y: self.frame.height/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
