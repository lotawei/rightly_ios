//
//  PersonalHeaderHasTaskView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/24.
//

import UIKit

class PersonalHeaderHasTaskView: UIView, NibLoadable {
    @IBOutlet weak var bgImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var userInfoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nicknameLeft: NSLayoutConstraint!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var taskTypeImageView: UIImageView!
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var taskDescLabel: UILabel!
    @IBOutlet weak var taskBtn: UIButton!
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var userDescLabel: UILabel!
    @IBOutlet weak var followBtn: FollowUIButton!
    
    @IBOutlet weak var tagListView: UIView!
    
    fileprivate var userid:Int64?=nil
    fileprivate var tags:[ItemTag]?
    fileprivate var taskInfo:TaskInfo?
    
    var tagsField = TagSelectView.init(frame: CGRect.init(origin: .zero, size: CGSize(width: 0, height: 30))) //用户标签
    lazy var actionTagButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(tapTagManagerAction), for: .touchUpInside)
        button.setImage(UIImage.init(named: "user_tags_preview_btn"), for: .normal)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let norImage = UIImage.createSolidImage(color: .black, size: CGSize.init(width: 200, height: 68))
        let disImage = UIImage.createSolidImage(color: .init(white: 0, alpha: 0.1), size: CGSize.init(width: 200, height: 68))
        self.taskBtn.setBackgroundImage(norImage, for: .normal)
        self.taskBtn.setBackgroundImage(disImage, for: .disabled)
    }
    
    @IBAction func taskBtnAction(_ sender: UIButton) {
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        
        if self.userid == nil || UserManager.isOwnerMySelf(self.userid) {
            let releaseVc = ReleaseTaskViewController.loadFromNib()
            releaseVc.task = self.taskInfo?.task
            currentvc.navigationController?.pushViewController(releaseVc, animated: false)
        } else {
            guard let otherid = self.userid else {
                return
            }
            
            let greetInfo = GreetInfoViewController.init(otherid.description)
            currentvc.navigationController?.pushViewController(greetInfo, animated: true)
        }
    }
    
    public func configTagsView(_ atags:[ItemTag], isMy:Bool){
        self.tags = atags
        var tags = atags.map { (itemtag) -> String in
            return  itemtag.name ?? "--"
        }
        
        var tagListHidden = false
        var userInfoH:CGFloat = 100.0
        if tags.count == 0 {
            if isMy {
                tags.append("My Tag".localiz())
            } else {
                tagListHidden = true
                userInfoH = 66.0
            }
        }
        
        self.userInfoViewHeight.constant = userInfoH
        self.tagListView.isHidden = tagListHidden
        
        if !tagListHidden {
            self.tagListView.addSubview(self.tagsField)
            self.tagsField.setTags(tags)
            self.tagsField.snp.updateConstraints { (maker) in
                maker.left.equalToSuperview()
                maker.centerY.equalToSuperview()
                maker.height.equalToSuperview()
                maker.width.equalTo((tagsField.contensizeWidth > screenWidth - 64) ?  screenWidth - 64:tagsField.contensizeWidth )
            }
            self.configAddButton(!isMy, hastags: tags.count > 0)
            tagsField.layoutIfNeeded()
            self.tagsField.tagIndexBlock =  { [weak self]
                index in
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
    fileprivate func configAddButton(_ isother:Bool, hastags:Bool){
        if isother {
            self.actionTagButton.setImage(UIImage.init(named: "user_tags_preview_btn"), for: .normal)
            actionTagButton.isHidden = !hastags
        } else {
            self.actionTagButton.setImage(UIImage.init(named: "user_tags_add_btn"), for: .normal)
            actionTagButton.isHidden = false
        }
        
        if self.actionTagButton.superview == nil {
            self.tagListView.addSubview(self.actionTagButton)
            self.actionTagButton.snp.makeConstraints { (maker) in
                maker.left.equalTo(self.tagsField.snp.right)
                maker.width.height.equalTo(24)
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
    
    func updateUserInfo(_ addinfo:UserAdditionalInfo?){
        self.userid = addinfo?.userId
        let backHeadURL = URL(string: addinfo?.backgroundUrl?.dominFullPath() ?? "")
        let backPlaceImg = UIImage(named:"images")
        let headHeadURL = URL(string: addinfo?.avatar?.dominFullPath() ?? "")
        let headPlaceImg = UIImage(named: addinfo?.gender?.defHeadName ?? "head_boy")

        self.bgImageView.kf.setImage(with: backHeadURL, placeholder: backPlaceImg)
        self.followBtn.isSelected = addinfo?.isfocused ?? false
        self.userHeadImageView.kf.setImage(with: headHeadURL, placeholder: headPlaceImg)
        self.nickNameLabel.text = addinfo?.nickname
        self.updateUserDesc(addinfo)
        
        if UserManager.isOwnerMySelf(addinfo?.userId) {
            self.followBtn.isHidden = true
            self.taskBtn.setTitle("Reset".localiz(), for: .normal)
            self.taskBtn.setTitle("Reset".localiz(), for: .disabled)
            self.taskBtn.isEnabled = true
        } else {
            self.followBtn.isHidden = false
            self.taskBtn.setTitle("Do it now".localiz(), for: .normal)
            self.taskBtn.setTitle("Accpet_btn".localiz(), for: .disabled)
            self.taskBtn.isEnabled = !(addinfo?.isUnlock ?? false)
        }
        //只要解锁了就显示
        if (addinfo?.isUnlock ?? false){
            self.visualEffectView.alpha = 0.1
            return
        }
        self.updateBgViewType(addinfo?.bgViewType ?? .Public)
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
    
    func updateTaskInfo(_ taskInfo:TaskInfo?) {
        self.taskInfo = taskInfo
        switch taskInfo?.task?.type {
        case .photo:
            self.taskTypeImageView.image = UIImage.init(named: "medium_photo_task")
          
        case .voice:
            self.taskTypeImageView.image = UIImage.init(named: "medium_voice_task")
            
        case .video:
            self.taskTypeImageView.image = UIImage.init(named: "medium_video_task")
           
        default:
            self.taskTypeImageView.image = nil
          
        }
        self.taskTypeLabel.text = taskInfo?.task?.type.typeTitle()
        let norImage = UIImage.createSolidImage(color: taskInfo?.task?.type.taskNewVersionColor() ?? TaskType.photo.taskNewVersionColor(), size: CGSize.init(width: 200, height: 68))
        self.taskBtn.setBackgroundImage(norImage, for: .normal)
        self.taskTypeLabel.textColor = taskInfo?.task?.type.NewTaskTipStyleTextColor()
        self.taskDescLabel.text = taskInfo?.task?.descriptionField
    }
}
