//
//  CameraCell.swift
//  PhotoPick
//
//  Created by Auto Jiang on 2016/12/23.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit
import AVFoundation

class CameraCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    static let identifier = "CameraCell"
    
    weak var host: PhotoPickVC?
    
    var doneTakePhoto: ([PickedPhoto]) -> Void = {_ in }
    var cancelTakePhoto: () -> Void = {_ in}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let session = AVCaptureSession()
        let output = AVCaptureStillImageOutput()
        session.addOutput(output)
        let possibleDevices: [AVCaptureDevice] = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        let device: AVCaptureDevice? = possibleDevices.first
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput.init(device: device)
            session.sessionPreset = AVCaptureSessionPresetMedium
            session.addInput(input)
        } catch let e as NSError {
            print(e.description)
        }
        if let previewLayer = AVCaptureVideoPreviewLayer.init(session: session){
            let rate = UIScreen.main.bounds.height / UIScreen.main.bounds.width
            let height = bounds.width * rate
            let X = (height - bounds.height) / 2
            previewLayer.frame = CGRect(x: -X, y: 0, width: height, height: height)
            contentView.layer.addSublayer(previewLayer)
            session.startRunning()
        }
        clipsToBounds = true
        let imageV = UIImageView()
        imageV.image = UIImage(named: "PhotoPick.bundle/icon_album_open_camera")
        contentView.addSubview(imageV)
        imageV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        backgroundColor = UIColor.gray
        
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
        if vc.selectedPhotoModels.count >= PhotoPickConfig.shared.maxSelectImagesCount {
            PhotoPick.showOneCancelButtonAlertView(from: vc, title: "可选图片已达上限", subTitle: nil)
            return
        }
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .restricted || authStatus == .denied {
            PhotoPick.showOneCancelButtonAlertView(from: vc, title: "相机无法打开", subTitle: "应用相机权限受限,请在设置中启用")
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
            
            //图片存入相册
            //UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil);
            
            let assetimage = PickedPhoto(image: image)
            doneTakePhoto([assetimage])
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelTakePhoto()
    }
}

