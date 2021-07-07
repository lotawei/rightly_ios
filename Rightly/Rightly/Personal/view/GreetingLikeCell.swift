//
//  llasld.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/2.
//

import Reusable
import RxSwift
import RxCocoa
import SnapKit
protocol UserFocusDelegate {
    func foucusUser(_ userid:Int64,_ isfocus:Bool)
}

class GreetingLikeCell: UITableViewCell,NibReusable{
    var  delegate:UserFocusDelegate?=nil
    var  operatorClick:((_ greetingResult:GreetingResult)->Void)?=nil
    var   vmData:GreetingResultVModel?=nil
    var  selectItemClick:((_ res:GreetingResult?) -> Void)?=nil
    @IBOutlet weak var cityview: UIStackView!
    @IBOutlet weak var usernickname: UILabel!
    @IBOutlet weak var btncity: UIButton!
    //    @IBOutlet weak var btnlike: UIButton!
    @IBOutlet weak var likeimage: UIImageView!
    @IBOutlet weak var likenumber: UILabel!
    @IBOutlet weak var usericon: UIImageView!
    @IBOutlet weak var userlikeTime: UILabel!
    @IBOutlet weak var isfollowbtn: FollowUIButton!
    @IBOutlet weak var lblupdateAt: UILabel!
    @IBOutlet weak var content: UILabel!
    var disposebag = DisposeBag.init()
    @IBOutlet weak var tasktipView: UIView!
    @IBOutlet weak var tipheight: NSLayoutConstraint!
    var  tipview:TaskTipView? = TaskTipView.loadNibView()
    @IBOutlet weak var cityheight: NSLayoutConstraint!
    @IBOutlet weak var tagsheight: NSLayoutConstraint!
    @IBOutlet weak var usertagView: UIView!
    var  selectagView:TagSelectView =  TagSelectView.init(frame: .zero)
    var islike = true
    
    //资源视图
    @IBOutlet weak var resourceView: UIStackView!
    var  audioView:ReleaseAudioView?=ReleaseAudioView.loadNibView()
    var  voiceWidth:Constraint?=nil
    override func prepareForReuse() {
        super.prepareForReuse()
        disposebag = DisposeBag.init()
        self.tipheight.constant = 0
        self.tagsheight.constant = 0
        self.audioView?.removeFromSuperview()
        for subview in self.resourceView.arrangedSubviews{
            subview.removeFromSuperview()
        }
        self.isfollowbtn.isHidden = false
    }
    @IBAction func focusAction(_ sender: UIButton) {
        
        guard let userid = vmData?.greetingresult.user?.userId else {
            return
        }
        self.delegate?.foucusUser(userid,sender.isSelected)
        
    }
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        guard let tipview = tipview else {
            return
        }
        self.tasktipView.addSubview(tipview)
        tipview.snp.makeConstraints { (maker) in
            maker.left.right.bottom.top.equalToSuperview()
        }
        self.usertagView.addSubview(self.selectagView)
        selectagView.loadGrayStyle()
    }
    func bindVmData(_  vmdata:GreetingResultVModel)  {
        self.vmData = vmdata
        vmdata.output.greetingReultData.asObservable().subscribe(onNext: { [weak self] (resultdata) in
            guard let `self` = self  else {return }
            self.likenumber.text = "\(resultdata.likeNum ?? 0)"
            let liketime = String.updateTimeToCurrennTime(timeStamp: Double(resultdata.likeAt ?? 0))
            self.userlikeTime.text = "I".localiz() + "\(liketime ?? "...")" + "liked this post".localiz()
            self.lblupdateAt.text =  String.updateTimeToCurrennTime(timeStamp: Double(resultdata.createdAt ?? 0))
            self.content.attributedText = resultdata.content?.exportEmojiTransForm()
            var  displayTags:[String]?
            if  let tags = resultdata.tags {
                displayTags = tags.map({ (tag) -> String in
                    return tag.name ?? ""
                })
            }
            
            if let topics = resultdata.topics {
                displayTags = topics.map({ (tag) -> String in
                    return "#\((tag.name ?? ""))"
                })
            }
            if  let displayTopicorTags = displayTags {
                self.tagsheight.constant = 24
                self.selectagView.setTags(displayTopicorTags)
                self.selectagView.snp.updateConstraints { (maker) in
                    maker.width.equalTo(self.selectagView.contensizeWidth)
                    maker.left.top.bottom.equalToSuperview()
                }
            }else{
                self.tagsheight.constant = 0
            }
            
            if let taskBrief = resultdata.task {
                if let tipv = self.tipview {
                    tipv.taskType = taskBrief.type
                    tipv.lbldes.text  = "     "  + (taskBrief.descriptionField ?? "")
                    let tipH = (tipv.lbldes.sizeThatFits(CGSize(width: (screenWidth - 70), height: screenHeight)).height ?? 18) + 16
                    self.tipheight.constant = max(tipH, 34)
                }
            }else{
                self.tipheight.constant = 0
            }
            if let tasktype = resultdata.taskType {
                self.layoutresource(tasktype,resourcelists: resultdata.resourceList ?? [])
            }
        }).disposed(by: self.rx.disposeBag)
        vmdata.output.greetingLocationdecode.asObservable().subscribe(onNext: { [weak self] (city) in
            guard let `self` = self  else {return }
            if let city = city ,!city.isEmpty {
                self.btncity.setTitle(city, for: .normal)
                self.cityview.alpha = 1
                
            }
            else{
                self.cityview.alpha = 0
                
            }
            
        }).disposed(by: self.rx.disposeBag)
        
        vmdata.output.likestate.asObservable().subscribe(onNext: { [weak self] (islike) in
            guard let `self` = self  else {return }
            if  islike {
                self.likeimage.image = UIImage.init(named: "like_selected")
            }else{
                self.likeimage.image = UIImage.init(named: "like_normal")
            }
            self.islike = islike
            
        }).disposed(by: self.rx.disposeBag)
        vmdata.output.userInfo.asObservable().subscribe(onNext: { [weak self] (userinfo) in
            guard let `self` = self  else {return }
            guard let userinfo = userinfo else{return }
            self.usernickname.text = userinfo.nickname
            let inbundleimg = UIImage(named: "default_head_image")
            let ownerAvatarUrl = userinfo.avatar?.dominFullPath() ?? ""
            self.usericon.kf.setImage(with: URL(string:ownerAvatarUrl), placeholder: inbundleimg)
            
            self.updateLikeState(userinfo.userId)
            
        }).disposed(by: self.rx.disposeBag)
        
        vmdata.output.greetingLocationdecode.asObservable().subscribe(onNext: { [weak self] (city) in
            guard let `self` = self  else {return }
            if let city = city ,!city.isEmpty {
                self.btncity.setTitle(city, for: .normal)
                self.cityview.isHidden = false
            }
            else{
                self.cityview.isHidden = true
            }
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    //模型未返回只有再请求一次详情
    func updateLikeState(_ userid:Int64?){
        if UserManager.isOwnerMySelf(userid) {
            self.isfollowbtn.isHidden = true
        }
        else{
            guard let userid = userid else {
                return
            }
            self.isfollowbtn.isHidden = false
            UserProVider.init().userAdditionalInfo("\(userid)",self.disposebag).subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (userdetail) in
                guard let `self` = self  else {return }
                if let dicData = userdetail.data as? [String:Any] {
                    let  auser = dicData.kj.model(UserAdditionalInfo.self)
                    self.isfollowbtn.isSelected = auser.isfocused ?? false
                }
            })
            .disposed(by: self.disposebag)
        }
    }
    
    @IBAction  func likeAction(_ sender:UIButton) {
        
        guard let greetingid = self.vmData?.greetingresult.greetingId else {
            
            return
        }
        
        MatchTaskGreetingProvider.init().greetingLike(greetingid, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                if  self.islike {
                    self.likeimage.image = UIImage.init(named: "like_normal")
                    let  decrese = (Int(self.likenumber.text ?? "0") ?? 0) - 1
                    self.likenumber.text  = "\((decrese > 0 ? decrese:0))"
                }else{
                    self.likeimage.image = UIImage.init(named: "like_selected")
                    let  increase = (Int(self.likenumber.text ?? "0") ?? 0) + 1
                    self.likenumber.text  = "\(increase > 0 ? increase:0)"
                }
                self.islike = !self.islike
                
            },onError: { (err) in
                MBProgressHUD.showError("Like Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func  layoutresource(_ taskType:TaskType,resourcelists:[GreetingResourceList]){
        
        if taskType == .photo || taskType == .video {
            var  urls = resourcelists.map { (resourcelist) -> URL? in
                return  resourcelist.mapUrl(taskType)
            }
            for (index,var item) in resourcelists.enumerated() {
                var imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
                imgphotoView.tag = index
                self.resourceView.addArrangedSubview(imgphotoView)
                var  height:CGFloat = 0
                height = CGFloat(item.scaleByWidth(wid: screenWidth - 32))
                height = height > 0 ? height:375
                imgphotoView.snp.makeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
                imgphotoView.preViewIndexClick = {  [weak self] selectedindex in
                    guard let `self` = self  else {return }
                    self.jumpNewPreViewResource(resources:urls ,selectindex:IndexPath.init(item: selectedindex, section: 0))
                    
                }
                //
            }
            
        }
        else{
            
            
            guard let audioview = self.audioView else {
                return
            }
            
            guard let  audioresource = resourcelists.first , let url = audioresource.url ,let duration = audioresource.duration else {
                
                return
            }
            let widthAndDuration  =  audioview.layoutReleaseAudioView(Int(duration))
            audioview.audiopath = url.dominFullPath()
            if audioview.superview == nil {
                self.resourceView.addArrangedSubview(audioview)
                audioview.snp.makeConstraints { (maker) in
                    maker.centerY.equalToSuperview() 
                    maker.width.equalTo(widthAndDuration.0 + 80)
                    maker.height.equalTo(38)
                }
            }
            
        }
        
        
    }
    
    fileprivate  func resizeImage(_ height:CGFloat, _ index:Int){
        if  index <= self.resourceView.arrangedSubviews.count - 1{
            UIView.animate(withDuration: 0.5) {
                self.resourceView.arrangedSubviews[index].snp.remakeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
            }
        }
        
    }
    
    
}




