//
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
    
    private let cellHeight: CGFloat = 60
    
    private var tableView = UITableView()
    
    private var groups = [PhotoGroup]()
    
    var cancelBack: ([PhotoModel])-> Void = {_ in}
    
    var confirmDismiss:([PickedPhoto])-> Void = {_ in}
    
    private let mgr = PhotoGroupManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        self.navigationItem.title = "照片"
        
        self.groups = mgr.findGroupGroupAll()
    }

//MARK: UITableViewDataSourceDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: groupsCell) as? GroupCell
        if cell == nil{
            cell = GroupCell(style: .value1, reuseIdentifier: groupsCell)
        }
        let group = groups[indexPath.row]
        cell?.bind(model: group)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        let photoPick = PhotoPickVC(group: group)
        photoPick.delegate = self
        self.navigationController?.pushViewController(photoPick, animated: true)
        return
    }
    
    //MARK: PhotoPickVCDelegate
    func photoPick(pickVC: PhotoPickVC, assetImages: [PickedPhoto]) {
        self.confirmDismiss(assetImages);
    }
}

class GroupCell: UITableViewCell {
    
    let imageV = UIImageView()
    let title = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
//        imageV.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        contentView.addSubview(imageV)
        imageV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: imageV, attribute: .width, relatedBy: .equal, toItem: imageV, attribute: .height, multiplier: 1.0, constant: 0))
    
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: imageV, attribute: .right, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: title, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: -10))
    }
    
    func bind(model:PhotoGroup){
        self.title.text = model.name()
        self.imageV.image = model.image

        self.detailTextLabel?.text = "(\(model.result.count))"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
