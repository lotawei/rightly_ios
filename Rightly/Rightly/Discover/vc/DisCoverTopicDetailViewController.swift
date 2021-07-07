//
//  DisCoverTopicDetailViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh
import SnapKit
class DisCoverTopicDetailViewController:BaseViewController {
    var isRfrresh:Bool = false
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight =    85
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        
        if safeBottomH > 0 {
            let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: safeBottomH))
            footerView.backgroundColor = .white
            tableview.tableFooterView = footerView
        }
        return tableview
        
    }()
    var  navTop:Constraint?=nil
    var  navHeight:Constraint?=nil
    let  customNav:DisCoverTopicHeadView?=DisCoverTopicHeadView.loadNibView()
    lazy var  bottomFloatView:UIStackView = {
        let  stackV = UIStackView.init()
        stackV.axis = .horizontal
        stackV.distribution = .fillProportionally
        stackV.alignment = .center
        stackV.spacing = 39
        stackV.addArrangedSubview(self.joinVoteBtn)
        self.joinVoteBtn.snp.makeConstraints { (maker) in
            maker.width.equalTo(scaleWidth(136))
            maker.height.equalToSuperview()
        }
        stackV.addArrangedSubview(self.joinMatchBtn)
        self.joinMatchBtn.snp.makeConstraints { (maker) in
            maker.width.equalTo(scaleWidth(136))
            maker.height.equalToSuperview()
        }
        return stackV
    }()
    
    lazy var joinMatchBtn:ItemFloatViewButton = {
        let joinMatchBtn = ItemFloatViewButton.init()
        joinMatchBtn.isHidden = false
        joinMatchBtn.setConfigStyle(.joinMatch)
        joinMatchBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.jumpJoinTopicVc()
        }).disposed(by: self.rx.disposeBag)
        
        return joinMatchBtn
    }()
    lazy var joinVoteBtn:ItemFloatViewButton = {
        let joinVoteBtn = ItemFloatViewButton.init()
        joinVoteBtn.isHidden = true
        joinVoteBtn.setConfigStyle(.joinVote)
        joinVoteBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.jumpVoteVc()
        }).disposed(by: self.rx.disposeBag)
        return joinVoteBtn
    }()
    
    var  topicId:BehaviorRelay<Int64?> = BehaviorRelay.init(value: nil)
    fileprivate var  topicDetail:DiscoverTopicModel?=nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        setUpViews() //子视图
        subscribNavAction() //自定义导航事件监听
        topicDetailInital() //话题详情请求
    }
    func setUpViews(){
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.top.left.right.bottom.equalToSuperview()
        }
        if let  navBarV = self.customNav {
            navBarV.translatesAutoresizingMaskIntoConstraints  = false //防止约束冲突
            self.tableView.tableHeaderView = navBarV
            navBarV.snp.makeConstraints { (maker) in
                navTop = maker.top.equalToSuperview().offset(0).constraint
                maker.centerX.equalToSuperview()
                maker.width.equalTo(screenWidth)
                navHeight = maker.height.equalTo(scaleHeight(170)).constraint
            }
        }
        self.tableView.rx.didScroll.subscribe(onNext: { [weak self]  in
            guard let `self` = self,let nav = self.customNav else {return }
            self.navHeight?.update(offset: scaleHeight(170) - self.tableView.contentOffset.y)
            self.navTop?.update(offset: self.tableView.contentOffset.y)
            nav.layoutIfNeeded()
            if self.tableView.contentOffset.y < -64 ,let topid = self.topicId.value{
                self.requestDetailTopic(topid)
            }
        }).disposed(by: self.rx.disposeBag)
        if let topicid  = self.topicId.value {
            let  vc = DynamicListViewController.init(.topic, "\(topicid)")
            vc.addParents(self, self.view)
            vc.view.snp.makeConstraints { (maker) in
                maker.left.right.bottom.equalToSuperview()
                maker.top.equalToSuperview().offset(scaleHeight(170))
            }
        }
        
        self.view.addSubview(self.bottomFloatView)
        self.bottomFloatView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-20)
            maker.height.equalTo(scaleHeight(48))
        }
    }
    func subscribNavAction(){
        /// 返回pop按钮
        customNav?.backBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: self.rx.disposeBag)
        /// 排行榜
        customNav?.matchRankBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.jumpTopicRankVc()
        }).disposed(by: self.rx.disposeBag)
        
        //        /// 参与话题 其实就是发布动态
        //        customNav?.joinMatchBtn.rx.tap.subscribe(onNext: { [weak self]  in
        //            guard let `self` = self  else {return }
        //            self.jumpJoinTopicVc()
        //        }).disposed(by: self.rx.disposeBag)
        //        /// 投票
        //        customNav?.matchVoteBtn.rx.tap.subscribe(onNext: { [weak self]  in
        //            guard let `self` = self  else {return }
        //            self.jumpVoteVc()
        //        }).disposed(by: self.rx.disposeBag)
    }
    
    func topicDetailInital()  {
        self.topicId.subscribe(onNext: { [weak self] (tid) in
            guard let `self` = self ,let id = tid else {return }
            self.requestDetailTopic(id)
        }).disposed(by: self.rx.disposeBag)
    }
    fileprivate func requestDetailTopic(_ topicId:Int64)  {
        if isRfrresh {
            return
        }
        isRfrresh = true
        DiscoverProvider.init().topicDetailInfo(topicId, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.isRfrresh = false
            if let dicData = res.data as? [String:Any] {
                let  topicInfo =   dicData.kj.model(DiscoverTopicModel.self)
                self.topicDetail = topicInfo
                self.customNav?.updateTopicInfo(topicInfo)
                //如果是比赛且比赛未结束才展示引导
                self.displayBottomV(topicInfo)
                if !(topicInfo.isMatchEnd ?? true) && (topicInfo.isMatch ?? false){
                    self.afterDelay(0.01) {
                        self.guideCheck()
                    }
                }
                
            }
            
        },onError: {(err) in
            MBProgressHUD.showError("Network Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
        
    }
    
    func displayBottomV(_ info:DiscoverTopicModel){
        if (info.isMatch ?? false) {
            self.joinVoteBtn.isHidden = false
            if info.isMatchEnd ?? false {
                self.joinVoteBtn.isHidden = true
            }else{
                self.joinVoteBtn.isHidden = false
            }
        }else{
            self.joinVoteBtn.isHidden = true
        }
        if let isjoin =  info.isJoin {
            if isjoin {
                joinMatchBtn.imageTag(UIImage.init(named: "topic_take_in_icon")  ??  UIImage.init())
            }else{
                joinMatchBtn.imageTag(UIImage.init())
            }
        }
    }
}


extension  DisCoverTopicDetailViewController {
    func jumpJoinTopicVc(){
        guard let  topicInfo = self.topicDetail else {
            return
        }
        if (topicInfo.isJoin ?? true){
            self.toastTip("不可重复参加该话题".localiz())
            return
        }
        let  joinVc =  UserLightOrJoinTopicViewController.init()
        joinVc.processType = .joinTopic(topicInfo)
        joinVc.blockRefresh = {
            [weak self] in
            guard let `self` = self ,let topicid = self.topicId.value else {return }
            self.requestDetailTopic(topicid)
        }
        self.navigationController?.pushViewController(joinVc, animated: false)
        
    }
    
    /// 排行榜
    func jumpTopicRankVc(){
        guard let  topicInfo = self.topicDetail else {
            return
        }
        let  rankVc =  MatchRanKViewController.init()
        rankVc.topicDetail.accept(topicInfo)
        self.navigationController?.pushViewController(rankVc, animated: false)
    }
    ///投票
    func  jumpVoteVc(){
        guard let  topicInfo = self.topicDetail else {
            return
        }
        let  voteVc =  DisCoverVoteViewController.init()
        voteVc.matchVoteTopicDetail.accept(topicInfo)
        self.navigationController?.pushViewController(voteVc, animated: false)
    }
}





extension  DisCoverTopicDetailViewController {
    func guideCheck()  {
        if !GuideConfig.checkGuideend(GuideEnter.TopicDetailGuide.rawValue) {
            let guideV = DisCoverGuideView.loadNibView()!
            guideV.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            guideV.configHoloVs(guideId:GuideEnter.TopicDetailGuide.rawValue ,self.configholViews())
            guideV.showOnWindow(direction: .center,coverColor: nil)
            guideV.doneBlock = {[weak self]
                gid in
                guard let `self` = self  else {return }
                GuideConfig.updateGuide(gid, true)
            }
        }
        
    }
    func configholViews() -> [DisTopicEnterType] {
        var  holViews = [UIView]()
        var  enterTypes:[DisTopicEnterType] = [DisTopicEnterType]()
        holViews.append(self.joinMatchBtn)
        holViews.append(self.joinVoteBtn)
        if let  navView = customNav {
            holViews.append(navView.matchRankBtn)
        }
        for(index, holV) in holViews.enumerated() {
            var enterType:DisTopicEnterType!
            let image = holV.snapViewImage()
            let size = holV.bounds.size
            let  point = keyWindow?.convert(holV.bounds, from: holV).origin ?? .zero
            if index == 0 {
                enterType = DisTopicEnterType.join(image, size, point)
            }else if index  == 1{
                enterType = DisTopicEnterType.vote(image, size, point)
            }else{
                enterType = DisTopicEnterType.rank(image, size, point)
            }
            enterTypes.append(enterType)
        }
        return enterTypes
        
    }
}
