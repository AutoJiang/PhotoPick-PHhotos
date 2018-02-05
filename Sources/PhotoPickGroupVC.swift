
//  GKitPhotoPickGroupVC.swift
//  PhotoPick
//
//  Created by Auto Jiang on 2016/12/22.
//  Copyright © 2016年 Auto Jiang. All rights reserved.
//

import UIKit

//相册列表
class PhotoPickGroupVC: UIViewController,UITableViewDelegate,UITableViewDataSource,PhotoPickVCDelegate {
    
    private let groupsCell = "groupsCell"
    
    private let cellHeight: CGFloat = 126
    
    private var tableView: UITableView = UITableView()
    
    private var groups = [PhotoGroup]()
    
    var cancelBack: ([PhotoModel])-> Void = {_ in}
    
    var confirmDismiss:([PickedPhoto])-> Void = {_ in}
    
    var bgViewOnClick: () ->Void = {_ in}
    
    var selectedCallBack: (PhotoGroup) -> Void = {_ in}
    
    private static var currentIndex = 0
    
    private let mgr = PhotoGroupManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        let bgView = UIView()
        bgView.frame = view.bounds
        view.addSubview(bgView)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        self.navigationItem.title = "照片"
        let size = self.view.bounds
        let H = self.cellHeight
        
        self.groups = mgr.findGroupGroupAll()
        var height = H * CGFloat(groups.count)
        let maxHeight = size.height - 64 - 88
        if height > maxHeight {
            height = maxHeight
        }
        self.tableView.frame = CGRect(x: 0.0, y: -size.height , width: size.width, height: height)
        self.showView()
        
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgViewTap)))
    }
    
    @objc private func bgViewTap(tapGesture: UITapGestureRecognizer) {
        bgViewOnClick()
    }
    
    func showView() {
        let size = self.tableView.frame.size
        if groups.count == 0 {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame = CGRect(x: 0, y: 64, width: size.width, height: size.height)
        }
    }
    
    func hideView() {
        let size = self.tableView.frame.size
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: 0, y: -size.height, width: size.width, height: size.height)
        }) { (_) in
            self.view.removeFromSuperview()
        }
    }
    
    //MARK: UITableViewDataSourceDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: groupsCell) as? GroupCell
        if cell == nil{
            cell = GroupCell(style: .value1, reuseIdentifier: groupsCell)
            cell?.isUserInteractionEnabled = true
        }
        let group = groups[indexPath.row]
        cell?.bind(model: group, isSelected: PhotoPickGroupVC.currentIndex == indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        selectedCallBack(group)
        PhotoPickGroupVC.currentIndex = indexPath.row
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: PhotoPickVCDelegate
    func photoPick(pickVC: PhotoPickVC, assetImages: [PickedPhoto]) {
        self.confirmDismiss(assetImages);
    }
}

class GroupCell: UITableViewCell {
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bgImageV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "PhotoPick.bundle/icon_albumlist_bg")
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    lazy var imageV: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    //选择图标
    lazy var icon: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "PhotoPick.bundle/icon_albumlist_choosed_arrow")
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .none
        contentView.addSubview(bgImageV)
        contentView.addSubview(imageV)
        contentView.addSubview(subtitle)
        contentView.addSubview(title)
        contentView.addSubview(icon)
        
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 18))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .width, relatedBy: .equal, toItem: imageV, attribute: .height, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80))
        
        contentView.addConstraint(NSLayoutConstraint(item: bgImageV, attribute: .top, relatedBy: .equal, toItem: imageV, attribute: .top, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: bgImageV, attribute: .left, relatedBy: .equal, toItem: imageV, attribute: .left, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: bgImageV, attribute: .width, relatedBy: .equal, toItem: bgImageV, attribute: .height, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: bgImageV, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80))
        
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: bgImageV, attribute: .right, multiplier: 1.0, constant: 18))
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120))
        
        contentView.addConstraint(NSLayoutConstraint(item: subtitle, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: subtitle, attribute: .left, relatedBy: .equal, toItem: bgImageV, attribute: .right, multiplier: 1.0, constant: 18))
        contentView.addConstraint(NSLayoutConstraint(item: subtitle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80))
        
        contentView.addConstraint(NSLayoutConstraint(item: icon, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -18))
        contentView.addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        
    }
    
    func bind(model:PhotoGroup, isSelected: Bool){
        self.title.text = model.name()
        self.imageV.image = model.image
        self.subtitle.text = "(\(model.result.count))"
        self.icon.isHidden = !isSelected
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
