//
//  PhotoPickVC.swift
//  PhotoPick
//
//  Created by Auto Jiang on 2016/12/14.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit

protocol PhotoPickVCDelegate: class {
    
    func photoPick(pickVC: PhotoPickVC, assetImages: [PickedPhoto]) -> Void
    func photoPickCancel(pickVC: PhotoPickVC) -> Void
}

extension PhotoPickVCDelegate {
    
    func photoPickCancel(pickVC: PhotoPickVC) -> Void {}
    
}

public class PhotoPickVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private static let kCellSpacing: CGFloat = 3
    
    weak var delegate: PhotoPickVCDelegate?
    
    private let config: PhotoPickConfig = PhotoPickConfig.shared
    
    private let groupManager = PhotoGroupManager()
    
    private lazy var menuBtn: TitleButton = {
        let btn = TitleButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        btn.setTitle("所有照片", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setImage(UIImage(named: "PhotoPick.bundle/icon_home_head_drop_arrow"), for: .normal)
        //        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: -50)
        btn.addTarget(self, action: #selector(titleViewOnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy private var  groupVC: PhotoPickGroupVC = {
        let vc = PhotoPickGroupVC()
        vc.cancelBack = { [unowned self] array in
            self.selectedPhotoModels = array
        }
        vc.confirmDismiss = { [unowned self] aassetImages in
            self.performPickDelegate(assetImages: aassetImages)
            self.dismissVC(isCancel: false)
        }
        vc.bgViewOnClick = { [unowned self] in
            self.titleViewOnClick(btn: self.menuBtn)
        }
        vc.selectedCallBack = { [unowned self] group in
            self.photoModels = self.groupManager.findAllPhotoModelsByGroup(by: group)
            self.titleViewOnClick(btn: self.menuBtn)
            self.menuBtn.setTitle(group.name(), for: .normal)
        }
        return vc
    }()
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.sourceType.cellSize, height: self.sourceType.cellSize)
        layout.minimumLineSpacing = PhotoPickVC.kCellSpacing
        layout.minimumInteritemSpacing = PhotoPickVC.kCellSpacing
        let cV = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cV.delegate = self
        cV.dataSource = self
        cV.backgroundColor = UIColor.white
        cV.register(PhotoCell.self ,forCellWithReuseIdentifier: PhotoCell.identifier)
        cV.register(CameraCell.self ,forCellWithReuseIdentifier: CameraCell.identifier)
        return cV
    }()
    
    private lazy var bottomBar: BottomBar = BottomBar()
    
    private enum SourceType {
        case all
        case group(photoGroup: PhotoGroup) //分组内显示照片列表时始终没有拍照功能
        
        var hasCamera: Bool {
            switch self {
            case .group(photoGroup: _):
                return false
            case .all:
                return PhotoPickConfig.shared.needShowCamera
            }
        }
        
        var cellColumnCount: Int {
            switch self {
            case .group(photoGroup: _):
                return 4
            case .all:
                return 3
            }
        }
        
        var cellSize: CGFloat {
            return (CGFloat(UIScreen.main.bounds.width) - CGFloat(cellColumnCount - 1) * PhotoPickVC.kCellSpacing ) / CGFloat(cellColumnCount)
        }
    }
    
    private var sourceType: SourceType = .all
    
    private var photoModels = [PhotoModel](){
        didSet{
            collectionView.reloadData()
        }
    }
    
    public var selectedPhotoModels = [PhotoModel]() {
        didSet{
            bottomBar.updatePickedPhotoCount(count: selectedPhotoModels.count)
            collectionView.reloadData()
        }
    }
    
    /// 对外提供
    public init(isShowCamera: Bool = true, maxSelectImagesCount: Int = 9) {
        config.maxSelectImagesCount = maxSelectImagesCount
        config.jpgQuality = 0.5
        config.needShowCamera = isShowCamera
        super.init(nibName: nil, bundle: nil)
        title = "照片选择"
    }
    
    /// 相册页面初始化
    init(group: PhotoGroup){
        sourceType = .group(photoGroup: group)
        super.init(nibName: nil, bundle: nil)
        title = group.name()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray
        
        view.addSubview(collectionView)
        
        view.addSubview(bottomBar)
        bottomBar.goShowPage = {[unowned self] in
            self.goPhotoShowVC(allAssets: self.selectedPhotoModels, selectedPhotoModels: self.selectedPhotoModels, index: 0)
        }
        bottomBar.onConfirm = {[unowned self] in
            self.confirmOnClick()
        }
        
        // 获取数据
        switch sourceType {
        case .all:
            setupNavigationItemsForSourceTypeAll()
            self.photoModels = self.groupManager.findAllPhotoModels()
            
        case let .group(photoGroup: group):
            self.photoModels = self.groupManager.findAllPhotoModelsByGroup(by: group)
            self.menuBtn.setTitle(group.name(), for: .normal)
        }
        addChildViewController(groupVC)
    }
    
    private func setupNavigationItemsForSourceTypeAll(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelBtnOnClick))
        
        let itemView =  UIBarButtonItem(customView: menuBtn)
        navigationItem.titleView = itemView.customView
    }
    
    func titleViewOnClick(btn: UIButton) {
        //        UIView.animate(withDuration: 0.2) {
        btn.imageView?.transform = btn.isSelected ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        //        }
        btn.isSelected = !btn.isSelected
        //        btn.isSelected ? openGroupPhotoVC(): closeGroupPhotoVC()
        if btn.isSelected {
            view.addSubview(groupVC.view)
            groupVC.showView()
        }else{
            groupVC.hideView()
        }
    }
    
    private func performPickDelegate(assetImages:[PickedPhoto]){
        if let delegate = delegate {
            delegate.photoPick(pickVC: self, assetImages: assetImages)
        }
    }
    
    private func performCancelDelegate(){
        if let delegate = delegate {
            delegate.photoPickCancel(pickVC: self)
        }
    }
    
    private func confirmOnClick(){
        performPickDelegate(assetImages: PhotoModel.convertToPickedPhotos(photoModels: selectedPhotoModels))
        dismissVC(isCancel: false)
    }
    
    @objc private func cancelBtnOnClick() {
        dismissVC(isCancel: true)
    }
    
    private func dismissVC(isCancel:Bool) {
        
        if isCancel {
            performCancelDelegate()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceType.hasCamera ? photoModels.count + 1 : photoModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && sourceType.hasCamera {
            let cell: CameraCell =  collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.identifier, for: indexPath) as! CameraCell
            cell.doneTakePhoto = { [unowned self] models  in
                var pickedPhotos = PhotoModel.convertToPickedPhotos(photoModels: self.selectedPhotoModels)
                pickedPhotos.append(contentsOf: models)
                self.performPickDelegate(assetImages: pickedPhotos)
                self.dismissVC(isCancel: false)
                self.dismissVC(isCancel: false)
            }
            cell.cancelTakePhoto = {
                self.dismissVC(isCancel: false)
            }
            cell.host = self
            return cell
        }
        
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        
        let model: PhotoModel = photoModels[getPhotoRow(indexPath: indexPath)]
        model.thumbnail { (image) in
            cell.bind(image: image, isCloud: model.isCloud)
        }

        if model.isSelect {
            let index = self.selectedPhotoModels.index(of: model)
            cell.cellSelect(animated: model.isLastSelect, index: "\(index!+1)")
            model.isLastSelect = false
        } else {
            cell.cellUnselect()
        }
        
        
        cell.selectChangeCallback = {[unowned self] photoCell in
            //取消选中
            if model.isSelect {
                let index = self.selectedPhotoModels.index(of: model)
                self.selectedPhotoModels.remove(at: index!)
                photoCell.cellUnselect()
                model.isSelect = false
            }
                
                //选中
            else if self.selectedPhotoModels.count < self.config.maxSelectImagesCount {
                self.selectedPhotoModels.append(model)
                model.isSelect = true
                photoCell.cellSelect(animated: true, index: "\(self.selectedPhotoModels.count)")
                model.isLastSelect = true
            }else{//可选图片已达上限
                PhotoPick.showOneCancelButtonAlertView(from: self, title: "可选图片已达上限", subTitle: nil)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && sourceType.hasCamera {
            return
        }
        goPhotoShowVC(allAssets: photoModels, selectedPhotoModels: selectedPhotoModels, index: getPhotoRow(indexPath: indexPath))
    }
    
    private func goPhotoShowVC(allAssets: [PhotoModel], selectedPhotoModels: [PhotoModel], index: Int) {
        let photoShowVC = PhotoShowVC(assets: allAssets, selectedPhotoModels: selectedPhotoModels, index: index, maxSelectImagesCount:config.maxSelectImagesCount)
        photoShowVC.cancelBack = { [unowned self] array in
            self.selectedPhotoModels = array
        }
        photoShowVC.confirmBack = { [unowned self] array in
            self.selectedPhotoModels = array
            self.confirmOnClick()
        }
        self.navigationController?.pushViewController(photoShowVC, animated: true)
    }
    
    private func getPhotoRow(indexPath: IndexPath) -> Int {
        return sourceType.hasCamera ? indexPath.row - 1 : indexPath.row
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TitleButton: UIButton {
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        self.layoutSubviews()
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = titleRect(forContentRect: contentRect)
        return CGRect(x: rect.maxX + 5, y: rect.origin.y + 7, width: 10 , height: 6.5)
    }
}

