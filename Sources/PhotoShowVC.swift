//
//  PhotoShowVC.swift
//  PhotoPick
//
//  Created by jiang aoteng on 2016/12/18.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit

//大图显示控制器
class PhotoShowVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    private let tabH: CGFloat = 40 + (isIphoneX ? 34.0 : 0)
    private var collectionView: UICollectionView?
    private var showLbl = CircleLabel()
    private var assets: [PhotoModel]
    private var selectedPhotoModels: [PhotoModel]
    private var index: Int
    //返回
    var cancelBack: ([PhotoModel])->Void = {_ in }
    
    //确认
    var confirmBack: ([PhotoModel])->Void = {_ in }
    
    //进度条
    private let titleLbl = UILabel()
    
    //头部栏
    private let navBarView = UIView()
    
    //底部栏
    private let BottomBar = UIView()
    
    //选择圈圈
    private var circleBtn = CircleButton()
    
    //弹出圆圈
    private var circelLbl = CircleLabel()
    
    private var confirmBtn = UIButton()
    
    private let maxSelectImagesCount: Int
    
    init(assets: [PhotoModel], selectedPhotoModels: [PhotoModel], index: Int, maxSelectImagesCount: Int ) {
        self.assets = assets
        self.selectedPhotoModels = selectedPhotoModels
        self.index = index
        self.maxSelectImagesCount = maxSelectImagesCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cV = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cV.delegate = self
        cV.dataSource = self
        cV.backgroundColor = UIColor.black
        cV.isPagingEnabled = true
        self.view.addSubview(cV)
        cV.register(BigPhotoCell.self ,forCellWithReuseIdentifier: "PhotoPick.bigCell")
        collectionView = cV
        if 0 < index && index < assets.count {
            collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: false)
        }


        self.createView()
    }
    
    private func createView(){
        let y = self.view.frame.height - tabH
        let width = self.view.frame.width
        BottomBar.frame = CGRect(x: 0, y: y, width: width, height: tabH)
        BottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(BottomBar)
        
        //右下角确定按钮
        confirmBtn.frame = CGRect(x: width - 100, y: 0, width: 100, height: tabH)
        confirmBtn.setTitle("确定", for: .normal)
        confirmBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        confirmBtn.setTitleColor(PhotoPickConfig.shared.tintColor, for: .normal)
        confirmBtn.backgroundColor = UIColor.clear
        confirmBtn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        BottomBar.addSubview(confirmBtn)
        confirmBtn.isHidden = !(selectedPhotoModels.count > 0)
        
        self.showLbl = CircleLabel(frame: CGRect(x: self.view.frame.width - 80, y: 13, width: 25, height: 25))
        
        self.navBarView.frame = CGRect(x: 0, y: 0, width: width, height: 64)
        navBarView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(navBarView)
        
        //返回按钮
        let dismissBtn = UIButton(frame: CGRect(x: 20, y: 30, width: 38, height: 25))
        dismissBtn.setTitle("返回", for: .normal)
        dismissBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        dismissBtn.setTitleColor(UIColor.white, for: .normal)
        dismissBtn.backgroundColor = UIColor.clear
        dismissBtn.addTarget(self, action: #selector(popVC), for: .touchUpInside)
        navBarView.addSubview(dismissBtn)
        
        //选择圈圈
        circleBtn = CircleButton(frame:CGRect(x: width - 38 , y: 30, width: 28, height: 28))
        circleBtn.addTarget(self, action: #selector(selectEvent), for:.touchUpInside)
        navBarView.addSubview(circleBtn)
        
        self.titleLbl.frame = CGRect(x: 0, y: 0, width: 70, height: 25)
        titleLbl.center = CGPoint(x: width/2, y: 44)
        titleLbl.textAlignment = .center
        titleLbl.font = UIFont.systemFont(ofSize: 15)
        titleLbl.textColor = UIColor.white
        updateTitle(animate: false)
        view.addSubview(titleLbl)
    }
        
    @objc private func selectEvent() {
        let element = assets[index]
        if selectedPhotoModels.count >= maxSelectImagesCount && !element.isSelect {
            PhotoPick.showOneCancelButtonAlertView(from: self, title: "可选图片已达上限", subTitle: nil)
            return
        }
        element.isSelect = !element.isSelect
        if element.isSelect {
            self.selectedPhotoModels.append(element)
        }else{
            let i = self.selectedPhotoModels.index(of: element)
            self.selectedPhotoModels.remove(at: i!)
        }
        updateTitle(animate: true)
        confirmBtn.isHidden = !(selectedPhotoModels.count > 0)
    }
    
    @objc private func popVC(){
        let _ = self.navigationController?.popViewController(animated: true)
        self.navigationController?.isNavigationBarHidden = false
        self.cancelBack(self.selectedPhotoModels)
    }
    
    @objc private func confirm() {
        self.confirmBack(self.selectedPhotoModels)
    }
    
    private func updateTitle(animate:Bool){
        circelLbl.removeFromSuperview()
        self.titleLbl.text = "\(index+1)/\(self.assets.count)"
        let element = self.assets[index]
        if element.isSelect {
            circelLbl = CircleLabel(frame: circleBtn.frame)
            circelLbl.text = "\(self.selectedPhotoModels.index(of: element)!+1)"
            navBarView.addSubview(circelLbl)
            if animate {
                circelLbl.addAnimate()
            }
        }
    }
    
// MARK: - UICollectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell :BigPhotoCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPick.bigCell", for: indexPath) as! BigPhotoCell
        let data : PhotoModel = assets[indexPath.row]
        cell.bind(model: data, index: indexPath.row)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position :Int = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        if index != position  {
            index = position
            self.updateTitle(animate: false)
        }
    }
}
