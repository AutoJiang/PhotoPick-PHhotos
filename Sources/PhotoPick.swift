//
//  PhotoPick.swift
//  GKitPhotoPick
//
//  Created by Auto Jiang on 2017/4/12.
//  Copyright © 2017年 Auto Jiang. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

public enum PhotoPickType {
    case editedSinglePhoto //需要编辑成方形图片的单张图片
    case normal            //无需编辑
    case showCamera        //内部显示显示拍照
    case systemCamera      //直接调用系统拍照
}

public protocol PhotoPickDelegate: class {
    
    func photoPick(photoPick: PhotoPick, assetImages: [PickedPhoto]) -> Void
    
    func photoPickCancel(photoPick: PhotoPick) -> Void
}

public extension PhotoPickDelegate {
    
    func photoPickCancel(photoPick: PhotoPick) -> Void{}
}


open class PhotoPick: NSObject, PhotoPickVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //单例
    static public let shared = PhotoPick()
    
    private override init() {}
    
    public weak var delegate: PhotoPickDelegate?
    
    private var imagePick: UIImagePickerController?
    
    private var type: PhotoPickType = .normal
    
    public func show(fromVC: UIViewController, type: PhotoPickType = .normal, delegate: PhotoPickDelegate) {
        self.delegate = delegate
        self.type = type
        let count = PhotoPickConfig.shared.maxSelectImagesCount
        switch type {
            
        case .normal:
            if !isALAssetsLibraryAvailable(from: fromVC) {
                return
            }
            let pv =  PhotoPickVC(isShowCamera: false, maxSelectImagesCount: count)
            pv.delegate = self
            let nav = defaultNavigationController(pv)
            fromVC.present(nav, animated: true, completion: nil)
            
        case .editedSinglePhoto:
            if !isALAssetsLibraryAvailable(from: fromVC) {
                return
            }
            let imagePC = UIImagePickerController()
            imagePC.delegate = self
            imagePC.sourceType = .photoLibrary
            imagePC.allowsEditing = true
            fromVC.present(imagePC, animated: true, completion: nil)
            imagePick = imagePC
            
        case .showCamera:
            if !isALAssetsLibraryAvailable(from: fromVC) {
                return
            }
            let pv =  PhotoPickVC(isShowCamera: true, maxSelectImagesCount: count)
            pv.delegate = self
            let nav = defaultNavigationController(pv)
            fromVC.present(nav, animated: true, completion: nil)
            
        case .systemCamera:
            if !isCameraAvailable(from: fromVC){
                return
            }
            let imagePC = UIImagePickerController()
            imagePC.delegate = self
            imagePC.sourceType = .camera
            imagePC.allowsEditing = PhotoPickConfig.shared.enableEdit
            fromVC.present(imagePC, animated: true, completion: nil)
            imagePick = imagePC
        }
    }
    
    internal static func showOneCancelButtonAlertView(from: UIViewController, title: String, subTitle: String?) {
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(action)
        from.present(alertController, animated: true, completion: nil)
    }
    
    private func isALAssetsLibraryAvailable(from: UIViewController) -> Bool {
        let authStatus = ALAssetsLibrary.authorizationStatus()
        if authStatus == .restricted || authStatus == .denied {
            PhotoPick.showOneCancelButtonAlertView(from: from, title: "相册无法打开", subTitle: "应用相册权限受限,请在设置中启用")
            return false
        }
        return true
    }
    
    private func isCameraAvailable(from: UIViewController) -> Bool {
        guard UIImagePickerController.isCameraDeviceAvailable(.rear) else {
            PhotoPick.showOneCancelButtonAlertView(from: from, title: "摄像头无法使用", subTitle: nil)
            return false
        }
        
        let mediaType = AVMediaTypeVideo
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        if authStatus == .restricted || authStatus == .denied {
            PhotoPick.showOneCancelButtonAlertView(from: from, title: "相机无法打开", subTitle: "应用相机权限受限,请在设置中启用")
            return false
        }
        return true
    }
    
    private func defaultNavigationController(_ root: UIViewController) -> UINavigationController {
        let navi = UINavigationController(rootViewController: root)
        navi.navigationBar.tintColor = PhotoPickConfig.shared.NaviBarTintColor
        navi.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PhotoPickConfig.shared.NaviBarTintColor]
        navi.navigationBar.shadowImage = UIImage()
        navi.navigationBar.barStyle = .black
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(PhotoPickConfig.shared.NaviBarColor.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        navi.navigationBar.setBackgroundImage(image, for: .default)
        navi.navigationBar.isTranslucent = true
        return navi
    }
    
    
    ///MARK: PhotoPickVCDelegate
    func photoPick(pickVC: PhotoPickVC, assetImages: [PickedPhoto]) {
        if let delegate = self.delegate {
            delegate.photoPick(photoPick: self, assetImages: assetImages)
        }
    }
    
    func photoPickCancel(pickVC: PhotoPickVC) {
        if let delegate = self.delegate {
            delegate.photoPickCancel(photoPick: self)
        }
    }
    
    ///MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var pickedImage: UIImage?
        if type == .editedSinglePhoto || PhotoPickConfig.shared.enableEdit {
            pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        }else {
            pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        guard let image = pickedImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        let model = PickedPhoto(image: image )
        if let delegate = self.delegate {
            delegate.photoPick(photoPick: self, assetImages: [model])
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let delegate = self.delegate {
            delegate.photoPickCancel(photoPick: self)
        }
        guard let vc = imagePick else {
            return
        }
        vc.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        if PhotoPickConfig.shared.isAutoClearDisk {
            PickedPhoto.clearDisk()
        }
    }
}


