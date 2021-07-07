//
//  PersonalOwerHeadView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/18.
//

import Foundation
import RxSwift
import MBProgressHUD
class PersonalOwerHeadView: UIView,NibLoadable {
    var  clickTapIndexBlock:((_ index:Int) -> Void)?=nil
    var  avatarClick:(()-> Void)?=nil
    var  nicknameClick:(()-> Void)?=nil
    var  userIsEmptyBlock:(()->Void)?=nil
    var  userPageClickBlock:(()->Void)?=nil //跳转主页
    var   backGroundImgBlock:(()->Void)?=nil
    var  isfriendBlock:((_ isfriend:Bool)->Void)?=nil
    var  refreshInfoBlock:(()->Void)?=nil
    lazy var actionTagButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapTagManagerAction), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return button
    }()
    @IBOutlet weak var visualbackView: UIVisualEffectView!
    @IBOutlet var itemLabel: [UILabel]!
    @IBOutlet weak var usericon: UIImageView!
    @IBOutlet weak var btnfollow: UIButton!
    @IBOutlet weak var followinglbl: UILabel!
    @IBOutlet weak var followerlbl: UILabel!
    @IBOutlet weak var likeslbl: UILabel!
    @IBOutlet weak var vistorlbl: UILabel!
    @IBOutlet var itemviews: [UIStackView]!
    @IBOutlet weak var btnpage: UIButton!
    
    var  tagsField = TagSelectView.init()
    //    @IBOutlet weak var itemuserinfoView: UIStackView!
    @IBOutlet weak var bottomView: UIStackView!
    @IBOutlet weak var usertagView: UIView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var lblfrom: UILabel!
    @IBOutlet weak var btnedit: UIButton!
    @IBOutlet weak var backheadView: UIImageView!
    fileprivate var userid:Int64?=nil
    @IBOutlet weak var lightBackImg: UIView!
    
    @IBOutlet weak var backHeadViewTop: NSLayoutConstraint!
    
    var offyCallBack:((_ offy:CGFloat) -> Void)?=nil
    var isfriendCheck:((_ isfriend:Bool) -> Void)?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        usericon.image = UIImage(named: UserManager.manager.currentUser?.additionalInfo?.gender?.defHeadName ?? "head_boy")
        lightBackImg.isUserInteractionEnabled = true
        let tapicon =  UITapGestureRecognizer.init(target: self, action: #selector(chooseBackImg))
        self.lightBackImg.addGestureRecognizer(tapicon)
        usericon.isUserInteractionEnabled = true
        let  avatarTap =  UITapGestureRecognizer.init(target: self, action: #selector(chooseAvatar))
        self.usericon.addGestureRecognizer(avatarTap)
        self.clipsToBounds = true
        offyCallBack = { [weak self] offy  in
            guard let `self` = self  else {return}
            self.backHeadViewTop.constant = offy > 0 ? 0 : offy
        }
        
        for item in itemviews {
            item.isUserInteractionEnabled = true
            let ges = UITapGestureRecognizer.init(target: self, action: #selector(itemViewClick(_:)))
            item.addGestureRecognizer(ges)
        }
        
        //国际化适配
        for itemlbl in itemLabel {
            itemlbl.text = itemlbl.text?.localiz()
        }
    }
    
    @objc func  itemViewClick(_ tap:UITapGestureRecognizer){
        guard let tag = tap.view?.tag else {
            return
        }
        self.clickTapIndexBlock?(tag)
    }
    
    @IBAction func followActionClick(_ sender: UIButton) {
        if !UserManager.isOwnerMySelf(self.userid) {
            if UserManager.manager.currentUser == nil {
                AppDelegate.jumpLogin()
                return
            }
            guard let userid = self.userid else {
                return
            }
            UserProVider.focusUser(sender.isSelected, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
                guard let `self` = self  else {return }
                self.btnfollow.isSelected =  isfocus
                self.refreshInfoBlock?() //刷新个数
            }
        } else{
            self.chooseAvatar()
        }
    }
    @objc func  chooseBackImg(){
        //选择背景
        self.backGroundImgBlock?()
    }
    
    func updateUserInfo(_ addinfo:UserAdditionalInfo?){
        self.userid = addinfo?.userId
        self.isfriendBlock?(addinfo?.isFriend ?? false)
        let placeImage = UIImage(named: addinfo?.gender?.defHeadName ?? "head_boy")
        let headURL = URL(string: (addinfo?.avatar?.dominFullPath() ?? ""))
        usericon.kf.setImage(with: headURL, placeholder: placeImage)
        nickname.text = addinfo?.nickname ?? "None"
        var prefix = ""
        if let country = addinfo?.address,!country.isEmpty {
            prefix  = "\(country)"
        }
        if let gen = addinfo?.gender?.desGender.localiz(), !gen.isEmpty  {
            if prefix.isEmpty {
                prefix = "\(gen)"
            } else{
                prefix = prefix + "," + "\(gen)"
            }
        }
        if let ag = addinfo?.age,ag > 0 {
            if prefix.isEmpty {
                prefix = "\(ag)"
            }else{
                prefix = prefix + "," + "\(ag)"
            }
        }
        lblfrom.text =  prefix
//        addinfo?.parseUserAddress({ [weak self](displayTxt) in
//            guard let `self` = self  else {return }
//            self.lblfrom.text = displayTxt
//        })
        followinglbl.text = "\(addinfo?.followNum ?? 0)"
        followerlbl.text =  "\(addinfo?.fansNum ?? 0)"
        likeslbl.text = "\(addinfo?.likeNum ?? 0)"
        vistorlbl.text = "\(addinfo?.viewMeNum ?? 0)"
        let backHeadURL = URL(string: addinfo?.backgroundUrl?.dominFullPath() ?? "")
        let backPlaceImg = UIImage(named:"images")
        backheadView.kf.setImage(with: backHeadURL, placeholder: backPlaceImg)
        if UserManager.isOwnerMySelf(addinfo?.userId) {
            btnedit.isHidden = false
            btnfollow.isSelected = false
            btnfollow.setBackgroundImage(UIImage.init(named: "avtarrefresh"), for: .normal)
            btnfollow.setTitle("", for: .normal)
        } else{
            btnedit.isHidden = true
            btnfollow.isHidden = false
            btnfollow.isSelected = addinfo?.isfocused ?? false
            btnfollow.setBackgroundImage(UIImage.init(), for: .normal)
            btnfollow.setTitle("+", for: .normal)
        }
        self.isfriendCheck?(addinfo?.isFriend ?? false)
        if let viewtype = addinfo?.bgViewType {
            switch viewtype {
            case .Private:
                self.visualbackView.alpha = visualAlpha
            default:
                self.visualbackView.alpha = 0.1
            }
        }
        
    }
    
    /// 更新用户标签
    func updateTags()  {
        var  uid:Int64? = userid
        if self.userid == nil {
            uid = UserManager.manager.currentUser?.additionalInfo?.userId
        }else{
            uid = self.userid
        }
        guard let uuid = uid else {
            return
        }
        UserTagsManager.shared.requestUserItemTags(uuid) { (tags) in
            self.configTagsView(tags)
        }
    }
    
    fileprivate func configTagsView(_ atags:[ItemTag]){
        var  tags  = atags.map { (itemtag) -> String in
            return  itemtag.name ?? "--"
        }
        var  isother  = !UserManager.isOwnerMySelf(self.userid)
        if !isother &&  tags.count == 0 {

            tags.append("My Tag".localiz())
        }
        self.usertagView.addSubview(self.tagsField)
        self.usertagView.frame = .zero
        self.tagsField.setTags(tags)
        self.tagsField.snp.updateConstraints { (maker) in
            maker.centerX.equalToSuperview().offset(-24)
            maker.top.bottom.equalToSuperview()
            maker.height.equalTo(24)
            maker.width.equalTo((tagsField.contensizeWidth > screenWidth - 64) ?  screenWidth - 64:tagsField.contensizeWidth )
        }
//        configAddButton(isother, hastags: tags.count > 0)
        tagsField.tagIndexBlock =  { [weak self]
            index in
            guard let `self` = self  else {return }
            self.tapTagManagerAction()
        }
        tagsField.isHidden = true
    }
    fileprivate func configAddButton(_ isother:Bool,hastags:Bool){
        if isother {
            self.actionTagButton.setTitle(">", for: .normal)
            actionTagButton.isHidden = !hastags
        }else{
            self.actionTagButton.setTitle("+", for: .normal)
            actionTagButton.isHidden = false
        }
        if self.actionTagButton.superview == nil {
            self.usertagView.addSubview(self.actionTagButton)
            self.actionTagButton.snp.makeConstraints { (maker) in
                maker.left.equalTo(self.tagsField.snp.right)
                maker.width.height.equalTo(24)
                maker.centerY.equalToSuperview()
            }
        }
    }
    @objc  func tapTagManagerAction()  {
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        let   tagmanagervc = TagSelectViewController.init()
        if UserManager.isOwnerMySelf(self.userid) {
            if let tags =  UserTagsManager.shared.usertags.value {
                if tags.count > 0 {
                    tagmanagervc.loadStyle = .tagViewType(.pub)
                }else{
                    tagmanagervc.loadStyle = .emptyTag
                }
            }
        }else{
            if  let otherid = self.userid {
                tagmanagervc.loadStyle = .otherTag(otherid)
            }
        }
        currentvc.navigationController?.pushViewController(tagmanagervc, animated: false)
    }
    @IBAction func editoraction(_ sender: Any) {
        self.nicknameClick?()
    }
    @objc func  chooseAvatar() {
        self.avatarClick?()
    }
    @IBAction func gopageClick(_ sender: Any) {
        self.userPageClickBlock?()
    }
}


