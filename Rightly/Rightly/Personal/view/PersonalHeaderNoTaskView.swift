//
//  PersonalHeaderNoTaskView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/24.
//

import UIKit

class PersonalHeaderNoTaskView: UIView, NibLoadable {
    @IBOutlet weak var bgImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var userInfoViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var userDescLabel: UILabel!
    
    @IBOutlet weak var tagListView: UIView!
    
    fileprivate var userid:Int64?=nil
    fileprivate var tags:[ItemTag]?
    
    var tagsField = TagSelectView.init(frame: CGRect.init(origin: .zero, size: CGSize(width: 0, height: 30))) //用户标签
    lazy var actionTagButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(tapTagManagerAction), for: .touchUpInside)
        button.setImage(UIImage.init(named: "user_tags_preview_btn"), for: .normal)
        return button
    }()
    
    public func configTagsView(_ atags:[ItemTag]){
        self.tags = atags
        let tags = atags.map { (itemtag) -> String in
            return  itemtag.name ?? "--"
        }
        
        var tagListHidden = false
        var userInfoH:CGFloat = 136.0
        if tags.count == 0 {
            tagListHidden = true
            userInfoH = 100.0
        }
        
        self.userInfoViewHeight.constant = userInfoH
        self.tagListView.isHidden = tagListHidden
        
        if !tagListHidden {
            self.tagListView.addSubview(self.tagsField)
            self.tagListView.frame = .zero
            self.tagsField.setTags(tags)
            self.tagsField.snp.updateConstraints { (maker) in
                maker.centerX.equalToSuperview().offset(-24)
                maker.height.equalToSuperview()
                maker.centerY.equalToSuperview()
                maker.width.equalTo((tagsField.contensizeWidth > screenWidth - 64) ?  screenWidth - 64:tagsField.contensizeWidth )
            }
            
            self.configAddButton()
            tagsField.tagIndexBlock =  { [weak self] index in
                guard let `self` = self  else {return }
                self.tapTagManagerAction()
            }
        }
    }
    func updateBgViewType(_ viewtype:ViewType)  {
        switch viewtype {
        case .Private:
            self.visualEffectView.alpha = 1
        default:
            self.visualEffectView.alpha = 0.1
        }
        
    }
    
    fileprivate func configAddButton() {
        self.actionTagButton.setImage(UIImage.init(named: "user_tags_preview_btn"), for: .normal)
        
        if self.actionTagButton.superview == nil {
            self.tagListView.addSubview(self.actionTagButton)
            self.actionTagButton.snp.makeConstraints { (maker) in
                maker.left.equalTo(self.tagsField.snp.right)
                maker.width.height.equalTo(30)
                maker.centerY.equalToSuperview()
            }
        }
    }
    
    @objc func tapTagManagerAction() {
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        let tagmanagervc = TagSelectViewController.init()
        if UserManager.isOwnerMySelf(self.userid) {
            if let tags = self.tags {
                if tags.count > 0 {
                    tagmanagervc.loadStyle = .tagViewType(.pub)
                } else{
                    tagmanagervc.loadStyle = .emptyTag
                }
            }
        } else {
            if let otherid = self.userid {
                tagmanagervc.loadStyle = .otherTag(otherid)
            }
        }
        currentvc.navigationController?.pushViewController(tagmanagervc, animated: false)
    }
    
    func updateUserInfo(_ addinfo:UserAdditionalInfo?) {
        self.userid = addinfo?.userId
        let backHeadURL = URL(string: addinfo?.backgroundUrl?.dominFullPath() ?? "")
        let backPlaceImg = UIImage(named:"images")
        let headHeadURL = URL(string: addinfo?.avatar?.dominFullPath() ?? "")
        let headPlaceImg = UIImage(named: addinfo?.gender?.defHeadName ?? "head_boy")

        self.bgImageView.kf.setImage(with: backHeadURL, placeholder: backPlaceImg)
        self.userHeadImageView.kf.setImage(with: headHeadURL, placeholder: headPlaceImg)
        
//        if UserManager.isOwnerMySelf(addinfo?.userId) {
//            self.isOnlineView.isHidden = true
//        } else {
//            self.isOnlineView.backgroundColor = (addinfo?.isOnline ?? false) ? .init(hex: "1BD2CA") : .init(hex: "AAAAAA")
//        }
        
        self.nickNameLabel.text = addinfo?.nickname
        //只要解锁了就显示
        if (addinfo?.isUnlock ?? false){
            self.visualEffectView.alpha = 0.1
            return
        }
        updateBgViewType(addinfo?.bgViewType ?? .Public)
        self.updateUserDesc(addinfo)
    }
    
    private func updateUserDesc(_ addinfo:UserAdditionalInfo?) {
        var prefix = ""
        if let gen = addinfo?.gender?.desGender.localiz(), !gen.isEmpty  {
            if prefix.isEmpty {
                prefix = "\(gen)"
            } else {
                prefix = prefix + "," + "\(gen)"
            }
        }

        if let ag = addinfo?.age,ag > 0 {
            if prefix.isEmpty {
                prefix = "\(ag)"
            } else{
                prefix = prefix + "," + "\(ag)"
            }
        }
        
        if let country = addinfo?.address,!country.isEmpty {
            if prefix.isEmpty {
                prefix = "\(country)"
            }else{
                prefix  = prefix +  "," +  "\(country)"
            }
           
        }
        
        self.userDescLabel.text = prefix
    }
}
