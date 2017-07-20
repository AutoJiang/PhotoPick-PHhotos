//
//  CameraCell.swift
//  PhotoPick
//
//  Created by Auto Jiang on 2016/12/23.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit
import Photos

class CameraCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    static let identifier = "CameraCell"
    
    weak var host: UIViewController?
    
    var doneTakePhoto: ([PickedPhoto]) -> Void = {_ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let title = UILabel(frame: frame)
        title.text = "拍摄"
        title.font = UIFont.systemFont(ofSize: 30)
        title.textColor = PhotoPickConfig.shared.tintColor
        title.textAlignment = .center
        self.addSubview(title)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture));
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapGesture() {
        guard let vc = host else {
            return
        }
        if !PhotoPick.isCameraAvailable(from: vc){
            return
        }
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        vc.present(controller, animated: true, completion: nil)

    }
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.sourceType == .camera {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            let url = info[UIImagePickerControllerReferenceURL] as! URL
//            let result = PHAsset.fetchAssets(withALAssetURLs: [URL(fileURLWithPath: url)], options: nil)
//            if let asset = result.firstObject {
//                let assetimage = PickedPhoto(asset: asset)
//                doneTakePhoto([assetimage])
//            }
//            PHAssetResourceManager.default()
            
            let assetimage = PickedPhoto(image: image)
            doneTakePhoto([assetimage])
        }
    }
}
