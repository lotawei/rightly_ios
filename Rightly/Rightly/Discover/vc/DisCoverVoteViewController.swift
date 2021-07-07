//
//  DisCoverVoteViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MJRefresh
import RxDataSources
import NIMSDK
import URLNavigator
import NVActivityIndicatorView
class DisCoverVoteViewController: BaseViewController {
    var  voteManager:VoteTopicUserManager! //投票管理器
    var emptyview:MatchRrefreshEmptyView?=MatchRrefreshEmptyView.loadNibView()
//    var shadowEmptyView:SignleZStackShadowView?=nil
    let loadingV:NVActivityIndicatorView = NVActivityIndicatorView.init(frame: .zero, type: .ballBeat, color: UIColor.black)
    var  matchVoteTopicDetail:BehaviorRelay<DiscoverTopicModel?> = BehaviorRelay.init(value: nil)
    lazy var containerBodyView:UIView = {
        let bodyV = UIView.init()
        bodyV.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return bodyV
    }()
    lazy var topV:UIView = {
        let  topv = UIView.init()
        topv.backgroundColor = UIColor.clear
        topv.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
            maker.width.height.equalTo(24)
        }
        topv.addSubview(self.customLbl)
        customLbl.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(closeBtn)
            maker.centerX.equalToSuperview()
        }
        return topv
    }()
    lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        button.setBackgroundImage(UIImage.init(named: "arrow_white_left"), for: .normal)
        return button
    }()
    lazy var customLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        return lbl
    }()
    var cellCount:Int = 4
    private lazy var cardBodyView: YHDragCard = {
        let card = YHDragCard.init(frame: CGRect.init(x: 0, y: 44, width: screenWidth*0.8, height: scaleHeight(488)))
        card.dataSource = self
        card.delegate = self
        card.minScale = 0.9
        card.infiniteLoop = false
        card.visibleCount = 4
        card.removeDirection = .horizontal
        return card
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        subScribeData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        
    }
    func setUpView(){
        self.fd_prefersNavigationBarHidden = true
        self.fd_interactivePopDisabled = true //禁用手势防止和左右滑动冲突
        self.view.addSubview(self.containerBodyView)
        self.containerBodyView.snp.makeConstraints { (maker) in
            maker.top.right.left.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        self.containerBodyView.addSubview(self.topV)
        self.topV.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(44)
            maker.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
        }
        self.containerBodyView.addSubview(self.cardBodyView)
        self.cardBodyView.snp.makeConstraints { (maker) in
            maker.width.equalToSuperview().dividedBy(10.0/9.0)
            maker.height.equalToSuperview().dividedBy(10.0/7.0)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(topV.snp.bottom).offset(23)
        }
        self.containerBodyView.addSubview(self.loadingV)
        self.loadingV.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(50)
            maker.center.equalToSuperview()
        }
        self.emptyview?.btncontent.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            if self.voteManager != nil {
                self.voteManager.shouldRefresh.onNext({}())
            }
        }).disposed(by: self.rx.disposeBag)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func subScribeData()  {
        matchVoteTopicDetail.subscribe(onNext: { [weak self] (info) in
            guard let `self` = self  else {return }
            self.customLbl.text = "#\(info?.name ?? "")"
            if let topicId = info?.topicId {
                self.initalVoteManger(topicId)
            }
        }).disposed(by: self.rx.disposeBag)
    }
    fileprivate func initalVoteManger(_ topicId:Int64) {
        self.voteManager = VoteTopicUserManager.init(topicId)
        self.voteManager.shouldRefresh.onNext({}())
        self.voteManager.startAnimation.subscribe(onNext: { [weak self] (showAnimation) in
            guard let `self` = self  else {return }
            showAnimation ?  self.loadingV.startAnimating():self.loadingV.stopAnimating()
        }).disposed(by: self.rx.disposeBag)
        self.voteManager.itemVoteresults.subscribe(onNext: { [weak self] (votes) in
            guard let `self` = self  else {return }
            self.cellCount = votes.count
            if self.cardBodyView.bounds.size.height > 0 {
                self.cardBodyView.reloadData(animation: false)
            }
            self.showEMptyView(self.cellCount == 0)
        }).disposed(by: self.rx.disposeBag)
        self.voteManager.currentVoteDisplayItem.subscribe(onNext: { [weak self] (item) in
            guard let `self` = self  else {return }
            if let tasktype = item?.taskType {
                self.containerBodyView.backgroundColor = tasktype.taskNewVersionColor()
            }else{
                self.containerBodyView.backgroundColor =  themeBarColor
            }
        }).disposed(by: self.rx.disposeBag)
        
    }
    func showEMptyView(_ show:Bool) {
        self.emptyview?.removeFromSuperview()
        if show {
            self.containerBodyView.addSubview(self.emptyview!)
            self.emptyview?.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.topV.snp.bottom)
                maker.left.right.bottom.equalToSuperview()
            }
            self.containerBodyView.backgroundColor = themeBarColor
        }
    }
    @objc func  forceRrefresh(_ sender:UITapGestureRecognizer){
        MatchLimitCountManager.shared.firstRefreshLimit(true)
    }
    @objc func closeAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
extension DisCoverVoteViewController:YHDragCardDataSource,YHDragCardDelegate{
    func numberOfCount(_ dragCard: YHDragCard) -> Int {
        return self.cellCount
    }
    
    func dragCard(_ dragCard: YHDragCard, indexOfCell index: Int) -> YHDragCardCell {
        var cell = dragCard.dequeueReusableCell(withIdentifier: "VoteId") as? VoteTopicCardCell
        if cell == nil {
            cell = UINib.init(nibName: "VoteTopicCardCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? VoteTopicCardCell
        }
        let  info = self.voteManager.originalResult[index]
        info.backImageDecodeProcess(targetSize:CGSize.init(width: screenWidth*0.8*0.9 - 20 , height:screenWidth*0.8*0.9 - 20 ))
        cell?.updateInfo(info,index: index, voteManager: self.voteManager)
        cell?.removeAction = {
            [weak self] v in
            guard let `self` = self  else {return }
            dragCard.nextCard(direction: .left)
        }
        cell?.supportAction = {
            [weak self] v in
            guard let `self` = self  else {return }
            dragCard.nextCard(direction: .right)
        }
        return cell!
    }
    func dragCard(_ dragCard: YHDragCard, didDisplayCell cell: YHDragCardCell, withIndexAt index: Int) {
        if self.voteManager != nil {
            self.voteManager.updateCurrentItem(index)
            if let  voteCell = cell as? VoteTopicCardCell {
                self.afterDelay(0.0001) {
                    voteCell.cellAppearPlay()
                    UIView.animate(withDuration: 0.2) {
                        voteCell.lbldetail.alpha = 1
                        voteCell.lbldetail.centerVertically()
                    }
                }
              
                
            }
        }
    }
    func dragCard(_ dragCard: YHDragCard, didRemoveCell cell: YHDragCardCell, withIndex index: Int, removeDirection: YHDragCardMoveDirection) {
        print("索引为\(index)的卡片滑出去了")
        self.voteManager.stopCurrent()
        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        switch removeDirection {
        case .up:
            print("向上移除")
        case .down:
            print("向下移除")
        case .left:
            if self.voteManager != nil {
                self.voteIndexofTopic(self.voteManager.originalResult[index], votetype: .unSupport, isLeft: true ,indexCheck:index)
            }
            break
        case .right:
            if self.voteManager != nil {
                    self.voteIndexofTopic(self.voteManager.originalResult[index], votetype: .likeSupport, isLeft: false,indexCheck:index)
            }
            break
        case .none:
            print("default")
        }
    }
    
    func nextDataRequest()  {
        if self.voteManager != nil {
            self.voteManager.shouldRefresh.onNext({}())
        }
        
    }
    /// 投票
    /// - Parameters:
    ///   - vote: <#vote description#>
    ///   - votetype: <#votetype description#>
    ///   - isLeft:
    ///   - andNext: 主要用于是否 进入下次滑动 主要在点击时有用
    func voteIndexofTopic(_ vote:VoteResultModel, votetype:VoteType,isLeft:Bool, indexCheck:Int) {
        self.voteManager.stopCurrent()
        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        self.voteManager.voteTopicUser(vote: vote, votetype: votetype) {[weak self] (result) in
            guard let `self` = self  else {return }
            switch result {
            case .likeSupport:
                self.toastTip("Vote success hot increase".localiz() + "10")
                if indexCheck == self.cellCount - 1{
                    self.nextDataRequest()
                }
                break
            case .unSupport:
                if indexCheck == self.cellCount - 1{
                    self.nextDataRequest()
                }
                break
            case .operatorFailed:
                self.toastTip("Network failed".localiz())
                if isLeft {
                    //表示只有一个数据源失败的就只有在拉一次数据了
                    self.cardBodyView.revoke(direction: .left)
                }else{
                    self.cardBodyView.revoke(direction: .right)
                }
                if self.cellCount == 1 {
                    self.cardBodyView.reloadData(animation: false)
                }
            }
        }
    }
    
}

