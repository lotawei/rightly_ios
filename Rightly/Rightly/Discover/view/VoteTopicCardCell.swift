//
//  VoteTopicCardCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/28.
//
import Foundation
import Kingfisher
import Reusable
import RxSwift
import NVActivityIndicatorView
class VoteTopicCardCell: YHDragCardCell,NibReusable{
    @IBOutlet weak var loadingV: NVActivityIndicatorView! //音频动效
    var  removeAction:((_ vote:VoteResultModel)->Void)?=nil
    var  supportAction:((_ vote:VoteResultModel)->Void)?=nil
    var  indexTag:Int = 0
    let disposebag:DisposeBag = DisposeBag.init()
    @IBOutlet weak var lblhot: UILabel!
    fileprivate  var  info:VoteResultModel?=nil
    @IBOutlet weak var backimg: UIImageView!
    @IBOutlet weak var displayLbl: UILabel!
    @IBOutlet weak var usernickname: UILabel!
    @IBOutlet weak var lbldetail: UITextView!
    @IBOutlet weak var visualView: UIView!
    
    @IBOutlet weak var contanierView: UIView!
    @IBOutlet weak var supportBtn: UIButton!
    @IBOutlet weak var audioVideoBtn: UIButton!
    var voteManager:VoteTopicUserManager!
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.shadow(type: .all, color: UIColor.black, opactiy: 0.2, shadowSize: 3,radius: 32)
    }
    func  updateInfo(_ info:VoteResultModel,index:Int,voteManager:VoteTopicUserManager) {
        
        self.loadingV.stopAnimating()
        self.info = info
        self.voteManager = voteManager
        self.usernickname.text = info.user?.nickname
        let headURL = URL.init(string: (info.user?.avatar?.dominFullPath() ?? ""))
        let backPlaceImg = UIImage(named:"images", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        //        if let age = info.user?.age {
        //            self.displayLbl.text = "\(age)"
        //        }
        //        if let gender = info.user?.gender{
        //            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + gender.desGender
        //        }
        //        if let city = info.user?.address ,!city.isEmpty{
        //            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + city
        //        }
        info.user?.parseUserAddress({ [weak self](displayTxt) in
            guard let `self` = self  else {return }
            self.displayLbl.text = displayTxt
        })
        
        self.lblhot.text = "\(info.hotNum ?? 0)"
        self.lbldetail.attributedText = info.content?.exportEmojiTransForm(UIFont.systemFont(ofSize: 24))
        self.lbldetail.textAlignment = .center
        //跟任务类型耦合的逻辑
        if  info.taskType  == .voice {
            self.visualView.alpha = 0.7 //音频的加点模糊
        }
        else if info.taskType == .video{
            self.visualView.alpha = 0.1 //不想多写个手势处理 给个0.1 可点击
        }
        else{
            self.visualView.alpha = 0.1
        }
        self.supportBtn.setBackgroundImage(info.taskType.taskBtnBackGroundImage(), for: .normal)
        info.preBackImageProcess.asObservable().subscribe(onNext: { [weak self] (res) in
             guard let `self` = self  else {return }
            if  res == nil {
                self.backimg.image = backPlaceImg
            }else{
                self.backimg.image = res
            }
        }).disposed(by: self.rx.disposeBag)
        self.indexTag = index
        self.lbldetail.alpha  = 0
    }
    
    func cellAppearPlay()  {
        self.startPlayResource(self.audioVideoBtn)
    }
    
    /// 播放音视频资源
    /// - Parameter info: <#info description#>
    @IBAction func startPlayResource(_ sender:UIButton)  {
        guard let voteres  = self.info  else {
            return
        }
        self.audioVideoBtn.isHidden = true
        if voteres.taskType == .voice {
            self.contanierView.isHidden = true
            if  let resourceurl = info?.resourceList?.first?.url?.dominFullPath() {
                self.loadingV.type = .audioEqualizer
                self.loadingV.startAnimating()
                RTVoiceRecordManager.shareinstance.startPlayerAudio(audiopath: resourceurl) { [weak self](finish) in
                    guard let `self` = self  else {return }
                    self.loadingV.stopAnimating()
                    self.audioVideoBtn.isHidden = false
                    self.startPlayResource(sender)
                }
            }
        }
        else if voteres.taskType == .video{
            self.contanierView.isHidden = false
            //              let   testVideo = "https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"
            //       voteManager.createPlayer(containerView: self.contanierView, videoUrl,coverUrl)
            if  let videoUrl = info?.resourceList?.first?.url?.dominFullPath() , !videoUrl.isEmpty{
                var coverUrl:URL?
                if let preView = info?.resourceList?.first?.previewUrl?.dominFullPath(), !preView.isEmpty{
                    coverUrl = URL.init(string: preView)
                }
                voteManager.createPlayer(containerView: self.contanierView, videoUrl,coverUrl)
            }
        }else{
            self.contanierView.isHidden = true
        }
        
    }
    
    
    @objc func jumpUserhomePage(_ sender:UITapGestureRecognizer){
        guard let usid = info?.userId else {
            return
        }
        if !UserManager.isOwnerMySelf(usid) {
            self.jumpUSer(userid: usid)
        }
        
    }
    
    
    @IBAction func dislikeAction(_ sender: Any) {
        guard let v = self.info else {
            return
        }
        self.removeAction?(v)
    }
    @IBAction func showGift(_ sender: Any) {
        let  giftV = GiftListView.loadNibView()
        giftV?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: scaleHeight(200))
        giftV?.showOnWindow(direction: .up)
    }
    
    @IBAction func supportUser(_ sender: Any) {
        guard let v = self.info else {
            return
        }
        self.supportAction?(v)
    }
}
