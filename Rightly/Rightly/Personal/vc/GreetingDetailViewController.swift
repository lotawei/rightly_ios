////
////  GreetingDetailViewController.swift
////  Rightly
////
////  Created by lejing_lotawei on 2021/3/30.
////
//
//import Foundation
//import MBProgressHUD
//import RxSwift
//import RxCocoa
//import RxDataSources
//import SnapKit
//import URLNavigator
//
//
//class GreetingDetailViewController:BaseViewController {
//    var  isower:Bool = false
//    private var anavigator: NavigatorType? = nil
//    var  voiceWidth:Constraint?=nil
//    var greetid:Int64? = nil {
//        didSet {
//            self.viewModel.input.greetingId.onNext(greetid)
//        }
//    }
//    @IBOutlet weak var tagsheight: NSLayoutConstraint!
//    let  lightTagView = TagSelectView.init()
//    @IBOutlet weak var usertagsView: UIView!
//    lazy var  customView:UIView = {
//        let customTitleView:UIView = UIView.init(frame: .zero)
//        customTitleView.addSubview(self.CustomTitle)
//        self.CustomTitle.snp.makeConstraints { (maker) in
//            maker.center.equalToSuperview()
//            maker.width.lessThanOrEqualTo(140)
//        }
//        return customTitleView
//    }()
//
//    lazy var CustomTitle: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.black
//        label.font = UIFont.systemFont(ofSize: 16)
//        return label
//    }()
//
//    lazy var navBtn: FollowUIButton = {
//        let button = FollowUIButton.init(type: .custom)
//        return button
//    }()
//
//    @IBOutlet weak var scrollerView: UIScrollView!
//    var viewtypeSelectView:PublishViewTypeSelectView?=PublishViewTypeSelectView.loadNibView()
//    var deleteTipView:AlterViewTipView?=AlterViewTipView.loadNibView()
//    var operationView:GreetingItemBottomView?=GreetingItemBottomView.loadNibView()
//    var otherAlterView:OtherAlterTipView?=OtherAlterTipView.loadNibView()
//    var  audioView:ReleaseAudioView?=ReleaseAudioView.loadNibView()
//    @IBOutlet weak var cityview: UIStackView!
//    var viewModel:GreetingDetailVModel = GreetingDetailVModel.init()
//
//    @IBOutlet weak var bodyView: UIView!
//
//    @IBOutlet weak var resourcestackView: UIStackView!
//    @IBOutlet weak var usericon: UIImageView!
//    @IBOutlet weak var usernickname: UILabel!
//    @IBOutlet weak var greetingUpdateAt: UILabel!
//    @IBOutlet weak var followbtn: FollowUIButton!
//    @IBOutlet weak var locationcity: UIButton!
//    @IBOutlet weak var contentlbl: UILabel!
//    @IBOutlet weak var tasktipview: UIView!
////    @IBOutlet weak var likebtn: UIButton!
//    @IBOutlet weak var likeimage: UIImageView!
//    @IBOutlet weak var likenumber: UILabel!
//    @IBOutlet weak var cityBtn: UIButton!
//    let  tiptaskV:TaskTipView? = TaskTipView.loadNibView()
//    @IBOutlet weak var tipheight: NSLayoutConstraint!
//    @IBOutlet weak var likeBtnTop: NSLayoutConstraint!
//
//    lazy var reportBtn: UIButton = {
//        let button = UIButton.init(type: .custom)
//        button.addTarget(self, action: #selector(reportMoreAction), for: .touchUpInside)
//        button.setImage(UIImage.init(named: "vertical_more_black_btn"), for: .normal)
//        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
//        return button
//    }()
//
//    @objc func jumpUserhomePage(_ tap:Any){
//        guard let userid = self.viewModel.output.resultData.value?.user?.userId else {
//            return
//        }
//        if !UserManager.isOwnerMySelf(userid) {
//            self.usericon.jumpUSer(userid: userid)
//        }
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        lightTagView.loadGrayStyle()
//        self.lightTagView.frame = .zero
//        self.usertagsView.addSubview(self.lightTagView)
//        self.lightTagView.snp.makeConstraints { (maker) in
//            maker.edges.equalToSuperview()
//        }
//        self.navigationItem.titleView = self.customView
//        self.CustomTitle.alpha = 0
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpUserhomePage(_:)))
//        self.usericon.addGestureRecognizer(tap)
//        self.usericon.isUserInteractionEnabled = true
//        let spaceitem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spaceitem.width = 15
//        let  navitems = [ UIBarButtonItem.init(customView: self.reportBtn),UIBarButtonItem.init(customView: self.navBtn),spaceitem]
//        self.navigationItem.rightBarButtonItems = navitems
//        self.navBtn.snp.makeConstraints { (maker) in
//            maker.width.equalTo(55)
//            maker.height.equalTo(26)
//        }
//        navBtn.alpha = 0
//        if let taskv = tiptaskV {
//            self.tasktipview.addSubview(taskv)
//            taskv.snp.makeConstraints { (maker) in
//                maker.left.right.top.bottom.equalToSuperview()
//            }
//        }
//        bindViewModel(to: self.viewModel)
//        self.scrollerView.rx.didScroll.subscribe(onNext: { [weak self]  in
//            guard let `self` = self  else {return }
//            let offy = self.scrollerView.contentOffset.y
//            let alpha = 1
//
//            if  offy > 40 {
//                self.CustomTitle.alpha = 1
//                if !self.isower {
//                    self.navBtn.alpha = 1
//                }
//            } else{
//                self.CustomTitle.alpha = 0
//                self.navBtn.alpha = 0
//            }
//        }).disposed(by: self.rx.disposeBag)
//    }
//
//    @IBAction func followAction(_ sender: Any) {
//        guard let userid = self.viewModel.output.resultData.value?.user?.userId else {
//            return
//        }
//        self.followUser(userid: userid)
//
//    }
//
//    //关注用户
//    func followUser(userid:Int64)  {
//
//        UserProVider.focusUser(self.followbtn.isSelected, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
//            guard let `self` = self  else {return }
//            self.viewModel.input.greetingId.onNext(self.greetid)
//        }
//
//    }
//
//    @IBAction func likeaction(_ sender: Any) {
//        guard let greetingid = self.viewModel.output.resultData.value?.greetingId else {
//            self.toastTip("dismiss greetingId".localiz())
//            return
//        }
//
//        MatchTaskGreetingProvider.init().greetingLike(greetingid, self.rx.disposeBag)
//            .subscribe(onNext: { [weak self] (res) in
//                guard let `self` = self  else {return }
//                MBProgressHUD.dismiss()
//                switch res {
//                case .success(let info):
//                    self.viewModel.input.greetingId.onNext(greetingid)
//                    break
//                case .failed(let err):
//                    MBProgressHUD.showError("Like Failed".localiz())
//                }
//
//            }).disposed(by: self.rx.disposeBag)
//    }
//
//    @objc func reportMoreAction() {
//        if UserManager.isOwnerMySelf(self.viewModel.output.resultData.value?.userId) {
//            //弹自己样式的
//            operationView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 232)
//            operationView?.selectItem = self.viewModel.output.resultData.value?.greetingId
//            operationView?.selectItemBlock = {
//                [weak self] itemselect in
//                guard let `self` = self  else {return }
//
//                switch itemselect {
//                case .itemResult(let type, let result):
//                    guard let greetingid =  result as? Int64 else {
//                        return
//                    }
//                    switch type {
//                    case .itemDelete:
//                        self.deleteAction(greetingid: greetingid)
//                    case .itemPrivacy:
//                        self.privacyAction(greetingid)
//                    case .itembeTop:
////                        self.topAction(greetingid)
//                            break
//                    default:
//                        break
//                    }
//                default:
//                    break
//                }
//            }
//
//            operationView?.showOnWindow(direction: .up)
//        } else {
//            otherAlterView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 300)
//            otherAlterView?.showOnWindow( direction:.up)
//            otherAlterView?.hidefollow()
//            otherAlterView?.selectItemBlock = {
//                [weak self] (item,issues) in
//                guard let `self` = self  else {return }
//                switch item {
//                case .itemReport:
//                    guard let greetingid = try? self.viewModel.input.greetingId.value() else {
//                        return
//                    }
//                    self.reportGreeting(greetingid: greetingid, issues)
//                    //
//                    break
//                case .itemFollow:
//                    break
//                default:
//                    break
//
//                }
//            }
//        }
//    }
//
//    //举报打招呼
//    func reportGreeting(greetingid:Int64,_ issues:[String])  {
//        UserProVider.init().reportTarget(2, targetId: greetingid, issues.first?.reportType() ?? 0 ,content: issues.first ?? "other",self.rx.disposeBag)
//            .subscribe(onNext: { [weak self] (res) in
//                guard let `self` = self  else {return }
//                switch res {
//                case .success(_):
//                    self.toastTip("Report success".localiz())
//                    break
//                case .failed(_):
//                    self.toastTip("Report failed".localiz())
//                }
//            }).disposed(by: self.rx.disposeBag)
//    }
//}
//extension GreetingDetailViewController:VMBinding {
//
//    func bindViewModel(to model: GreetingDetailVModel) {
//        self.viewModel.output.resultData.asObservable().subscribe(onNext: { [weak self] (res) in
//            guard let `self` = self ,let detail = res  else {
//                return
//            }
//            self.updateView(detail)
//        }).disposed(by: self.rx.disposeBag)
//
//        self.viewModel.output.greetingLocationdecode.asObservable().subscribe(onNext: { [weak self] (city) in
//            guard let `self` = self  else {return }
//            if let city = city ,!city.isEmpty {
//                self.cityBtn.setTitle(city, for: .normal)
//                self.cityview.isHidden = false
//                self.likeBtnTop.constant = 48
//            } else {
//                self.cityview.isHidden = true
//                self.likeBtnTop.constant = 16
//            }
//        }).disposed(by: self.rx.disposeBag)
//
//        self.viewModel.output.emptydetail.asObserver().subscribe(onNext: { [weak self] (res) in
//            guard let `self` = self  else {return }
//            self.toastTip("Greeting is deleted".localiz())
//            self.afterDelay(2) {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }).disposed(by: self.rx.disposeBag)
//    }
//
//    func updateView(_ detail:GreetingDetail)  {
//        self.isower =   UserManager.isOwnerMySelf(detail.userId)
//        self.CustomTitle.text = detail.user?.nickname
//        self.contentlbl.attributedText =  detail.content?.exportEmojiTransForm(.systemFont(ofSize: 16))
//        self.usernickname.text  = detail.user?.nickname
//        let inbundleimg = UIImage(named: "default_head_image")
//        let ownerAvatarUrl = detail.user?.avatar?.dominFullPath() ?? ""
//        usericon.kf.setImage(with: URL(string:ownerAvatarUrl), placeholder: inbundleimg)
//        self.greetingUpdateAt.text = String.updateTimeToCurrennTime(timeStamp: Double(detail.createdAt ?? 0))
//        if self.isower {
//            self.followbtn.isHidden = true
//            self.navBtn.alpha = 0
//        } else {
//            self.followbtn.isHidden = false
//            self.followbtn.isSelected = detail.user?.isfocused ?? false
//            if self.scrollerView.contentOffset.y == 0  {
//                self.navBtn.alpha = 0
//            } else {
//                self.navBtn.alpha = 1
//            }
//            self.navBtn.isSelected = detail.user?.isfocused ?? false
//        }
//        self.cityBtn.setTitle((detail.location?.city ?? ""), for: .normal)
//        if  (detail.isLike ?? false ) {
//            self.likeimage.image = UIImage.init(named: "like_selected")
//        }else{
//            self.likeimage.image = UIImage.init(named: "like_normal")
//        }
//        self.likenumber.text = "\((detail.likeNum ?? 0))"
//        if let tasktype = detail.taskType {
//            layoutresource(tasktype,resourcelists: detail.resourceList ?? [])
//            self.tiptaskV?.taskType = tasktype
//            self.tiptaskV?.lbldes.text  = ""
//            let tipH = (self.tiptaskV?.lbldes.sizeThatFits(CGSize(width: (screenWidth - 70), height: screenHeight)).height ?? 18) + 16
//            self.tipheight.constant = max(tipH, 34)
//        }
//        var  displayTags:[String] = []
//        if let tags = detail.tags {
//            displayTags = tags.map({ (tag) -> String in
//                return tag.name ?? ""
//            })
//        }
//        else if let topics = detail.topics {
//            displayTags = topics.map({ (topic) -> String in
//                return  "#\(topic.name ?? "")"
//            })
//        }
//        else{
//            self.tagsheight.constant = 0
//        }
//        self.configTags(displayTags)
//        guard let task = detail.task else {
//            self.tipheight.constant = 0
//            return
//        }
//        self.tiptaskV?.taskType = task.type
//        self.tiptaskV?.lbldes.text  = task.descriptionField ?? ""
//        let tipH = (self.tiptaskV?.lbldes.sizeThatFits(CGSize(width: (screenWidth - 70), height: screenHeight)).height ?? 18) + 16
//        self.tipheight.constant = max(tipH, 34)
//
//    }
//    func configTags(_ tags:[String])  {
//        if tags.count > 0 {
//            self.tagsheight.constant = 24
//            self.lightTagView.setTags(tags)
//        }else{
//            self.tagsheight.constant = 0
//        }
//
//    }
//    func cleanSubView()  {
//        for subview in self.resourcestackView.arrangedSubviews {
//            subview.removeFromSuperview()
//        }
//    }
//
//    fileprivate func  layoutresource(_ taskType:TaskType,resourcelists:[GreetingResourceList]){
//        cleanSubView()
//        if taskType == .photo || taskType == .video {
//            var  urls = resourcelists.map { (resourcelist) -> URL? in
//                return  resourcelist.mapUrl(taskType)
//            }
//
//            for (index,var item) in resourcelists.enumerated() {
//                var imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
//                imgphotoView.tag = index
//                self.resourcestackView.addArrangedSubview(imgphotoView)
//                var  height:CGFloat = 0
//                height = CGFloat(item.scaleByWidth(wid: screenWidth - 32))
//                height = height > 0 ? height:375
//                imgphotoView.snp.makeConstraints { (maker) in
//                    maker.height.equalTo(height)
//                }
//                imgphotoView.preViewIndexClick = {  [weak self] selectedindex in
//                    guard let `self` = self  else {return }
//                    self.jumpPreViewResource(resources:urls ,selectindex:selectedindex)
//                }
//            }
//        } else{
//            guard let audioview = self.audioView else {
//                return
//            }
//
//            guard let  audioresource = resourcelists.first , let url = audioresource.url ,let duration = audioresource.duration else {
//                return
//            }
//
//            let widthAndDuration  =  audioview.layoutReleaseAudioView(Int(duration))
//            audioview.audiopath = url.dominFullPath()
//            if audioview.superview == nil {
//                self.resourcestackView.addArrangedSubview(audioview)
//                audioview.snp.makeConstraints { (maker) in
//                    maker.centerY.equalToSuperview()
//                    maker.width.equalTo(widthAndDuration.0 + 80)
//                    maker.height.equalTo(38)
//                }
//            }
//        }
//    }
//
//    fileprivate  func resizeImage(_ height:CGFloat, _ index:Int){
//        if  index <= self.resourcestackView.arrangedSubviews.count - 1{
//            self.resourcestackView.arrangedSubviews[index].snp.remakeConstraints { (maker) in
//                maker.height.equalTo(height)
//            }
//            self.bodyView.layoutIfNeeded()
//        }
//    }
//}
//
//
//extension  GreetingDetailViewController {
//    func deleteAction(greetingid:Int64?)  {
//        guard let greetingid = greetingid else {
//            return
//        }
//        deleteTipView?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
//        deleteTipView?.displayerInfo(.deleteTip)
//        deleteTipView?.doneBlock = {
//            [weak self] in
//            guard let `self` = self  else {return }
////            self.deleteGreetingId(greetingid)
//        }
//        deleteTipView?.showOnWindow( direction: .center)
//    }
//
////    func deleteGreetingId(_ greetingId:Int64){
////        MBProgressHUD.showStatusInfo("deleting...".localiz())
////        UserProVider.init().deleteGreeting(greetingId: greetingId, self.rx.disposeBag)
////            .subscribe(onNext: { [weak self] (res) in
////                guard let `self` = self  else {return }
////                MBProgressHUD.dismiss()
////                switch res {
////                case .success(_):
////                    self.toastTip("Delete success".localiz())
////                    self.navigationController?.popViewController(animated: true)
////                    break
////                case .failed(_):
////                    self.toastTip("Delete failed".localiz())
////                }
////            }).disposed(by: self.rx.disposeBag)
////    }
////
////    func topAction(_ greetingId:Int64)  {
////        UserProVider.init().userTopGreeting(greetingId:greetingId , self.rx.disposeBag)
////            .subscribe(onNext: { [weak self] (res) in
////                guard let `self` = self  else {return }
////                switch res {
////                case .success(_):
////                    self.viewModel.input.greetingId.onNext(self.greetid)
////                case .failed(_):
////                    self.toastTip("Top failed".localiz())
////                }
////            }).disposed(by: self.rx.disposeBag)
////    }
//
//    func privacyAction(_ greetingId:Int64) {
//        self.viewtypeSelectView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 200)
//        self.viewtypeSelectView?.showOnWindow( direction: .up)
//        self.viewtypeSelectView?.clickSenderType =  { [weak self] viewtype in
//            guard let `self` = self  else {return }
//            self.changeprivacy(greetingId, viewtype: viewtype)
//        }
//    }
//
//    func changeprivacy(_ greetingId:Int64,viewtype:Int){
//        UserProVider.init().userEditGreeting(greetingId: greetingId, viewType: viewtype, self.rx.disposeBag)
//            .subscribe(onNext: { [weak self] (res) in
//                guard let `self` = self  else {return }
//                switch res {
//                case .success(_):
//                    self.viewModel.input.greetingId.onNext(self.greetid)
//                case .failed(_):
//                    self.toastTip("Update failed".localiz())
//                }
//            }).disposed(by: self.rx.disposeBag)
//    }
//}
//
//
//
