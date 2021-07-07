//
//  NewMatchViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/12.
//

import Foundation

import UIKit
import RxSwift
import SnapKit
import MJRefresh
import RxDataSources
import NIMSDK
import URLNavigator
import NVActivityIndicatorView
class NewMatchingViewController: BaseViewController {
    var  currentDisplayCell:MatchCardViewCell?=nil
    var emptyview:MatchRrefreshEmptyView?=MatchRrefreshEmptyView.loadNibView()
    let locationmanager = LocationManager.init()
    let loadingV:UIImageView = UIImageView.init()
    lazy var containerBodyView:UIView = {
        let bodyV = UIView.init()
        bodyV.backgroundColor = TaskType.photo.taskNewVersionColor()
        return bodyV
    }()
    lazy var topV:UIView = {
        let  topv = UIView.init()
        topv.backgroundColor = UIColor.clear
        topv.addSubview(self.rigthlyIcon)
        self.rigthlyIcon.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.equalTo(scaleWidth(78))
        }
        topv.addSubview(self.filterBtn)
        self.filterBtn.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-43)
            maker.width.height.equalTo(30)
            maker.centerY.equalTo(rigthlyIcon)
        }
        topv.addSubview(self.topstackV)
        self.topstackV.snp.makeConstraints { (maker) in
            maker.left.equalTo(24)
            maker.centerY.equalToSuperview()
            maker.width.lessThanOrEqualTo(240)
            maker.height.equalTo(23)
        }
        return topv
    }()
    lazy var rigthlyIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleToFill
        img.image = UIImage.init(named: "newRightly_icon")
        return img
    }()
    
    /// 头部视图 显示 几个图标和数字的
    lazy  var topstackV:UIStackView = {
        let stackv = UIStackView.init()
        stackv.axis = .horizontal
        stackv.alignment = .center
        stackv.spacing = 5
        stackv.addArrangedSubview(self.addIcon)
        stackv.addArrangedSubview(self.matchCountDisplayLbl)
        return stackv
    }()
    /// 跳转获取更多
    lazy  var  addIcon:UIImageView = {
        let iconV = UIImageView.init(image: UIImage.init(named: "newaddicon"))
        iconV.contentMode = .scaleToFill
        iconV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpreleaseHotVc))
        iconV.addGestureRecognizer(tap)
        return iconV
    }()
    
    /// 匹配次数
    lazy var matchCountDisplayLbl: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    lazy  var filterBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        let img = UIImage(named: "filter_white")
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(gotoFilterVC), for: .touchUpInside)
        return btn
    }()
    var cellCount:Int = 4
    private lazy var cardBodyView: YHDragCard = {
        let card = YHDragCard.init(frame: .zero)
        card.dataSource = self
        card.delegate = self
        card.minScale = 0.9
        card.visibleCount = 4
        card.infiniteLoop = false
        card.removeDirection = .horizontal
        return card
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        subScribeData()
        
    }
    
    func setUpView(){
        self.fd_prefersNavigationBarHidden = true
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
            maker.height.equalTo(scaleHeight(488))
            maker.centerX.equalToSuperview()
            maker.top.equalTo(topV.snp.bottom).offset(23)
        }
        self.containerBodyView.addSubview(self.loadingV)
        self.loadingV.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(100)
            maker.center.equalToSuperview()
        }
        loadingV.contentMode = .center
        self.emptyview?.btncontent.rx.tap.subscribe(onNext: {
            MatchLimitCountManager.shared.firstRefreshLimit(true)
        }).disposed(by: self.rx.disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RTUploadFileTool.init().updateLocation(0, 0, disposebag: self.rx.disposeBag)
        self.locationmanager.startOnceLocation()
        //        self.afterDelay(4) {
        //            self.testVideo()
        //        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationmanager.stopLocation()
    }
    func subScribeData()  {
        MatchLimitCountManager.shared.viewModel.output.outsideGreetingDatas.asObservable().subscribe(onNext: { [weak self] (matchData) in
            guard let `self` = self  else {return }
            self.cellCount = matchData.count
            if self.cardBodyView.bounds.size.height > 0 {
                self.cardBodyView.reloadData(animation: false)
            }
            if self.cellCount == 0 {
                self.cardBodyView.setNeedsLayout()
            }
        }).disposed(by: self.rx.disposeBag)
        MatchLimitCountManager.shared.reduceCount.asObservable().subscribe(onNext: { [weak self] (info) in
            guard let `self` = self  else {return }
            self.matchCountDisplayLbl.text = "\(info.0)/\(info.1)"
        }).disposed(by: self.rx.disposeBag)
        MatchLimitCountManager.shared.currentGreeting.asObservable().subscribe(onNext: { [weak self] (currentDisplayGreeting) in
            guard let `self` = self  else {return }
            //            if let tasktype = currentDisplayGreeting?.task?.type {
            //                self.containerBodyView.backgroundColor = tasktype.taskNewVersionColor()
            //            }else{
            //                self.containerBodyView.backgroundColor =  themeBarColor
            //            }
            self.containerBodyView.animateCircular(withDuration: 0.4, center: self.view.center) {
                if let tasktype = currentDisplayGreeting?.task?.type {
                    self.containerBodyView.backgroundColor = tasktype.taskNewVersionColor()
                }else{
                    self.containerBodyView.backgroundColor =  themeBarColor
                }
            }
        }).disposed(by: self.rx.disposeBag)
        MatchLimitCountManager.shared.viewModel.output.startAniation.subscribe(onNext: { [weak self] (showAnimation) in
            guard let `self` = self  else {return }
            if  showAnimation {
                self.startEndLoadingAimation(true)
            }
            else{
                self.startEndLoadingAimation(false)
            }
        }).disposed(by: self.rx.disposeBag)
        MatchLimitCountManager.shared.viewModel.output.emptyDataShow.subscribe(onNext: { [weak self] (empty) in
            guard let `self` = self  else {return }
            self.showEMptyView(empty)
        }).disposed(by: self.rx.disposeBag)
        self.locationmanager.curlocationinfo.asObserver().subscribe(onNext: { [weak self] (location) in
            guard let `self` = self  else {return }
            if location.coordinate.latitude > 0 && location.coordinate.longitude > 0 {
                RTUploadFileTool.init().updateLocation(location.coordinate.latitude, location.coordinate.longitude,disposebag: self.rx.disposeBag)
            }
            
        }).disposed(by: self.rx.disposeBag)
    }
    func startEndLoadingAimation(_ start:Bool)  {
        self.loadingV.alpha = start ? 1:0
        var  images = [UIImage]()
        for i  in 1...11 {
            images.append(UIImage.init(named: "card_loading\(i)")!)
        }
        self.loadingV.animationImages = images
        if start == true {
            self.loadingV.startAnimating()
        }else{
            self.loadingV.stopAnimating()
        }
    }
    
    func showEMptyView(_ show:Bool) {
        self.emptyview?.removeFromSuperview()
        if show {
            self.containerBodyView.addSubview(self.emptyview!)
            self.emptyview?.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.topV.snp.bottom)
                maker.bottom.equalToSuperview().offset(-safeBottomH - 20)
                maker.left.right.equalToSuperview()
            }
            self.containerBodyView.backgroundColor =  themeBarColor
        }
        
        
    }
    @objc func  gotoFilterVC(){
        
        let filterView = MatchFilterConfigView.loadNibView()
        filterView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 600)
        filterView?.showOnWindow( direction: .up, duration: 0.4)
        filterView?.applyAction = {
            [weak self] in
            guard let `self` = self  else {return }
            //            self.guideCheckProcess()
            MatchLimitCountManager.shared.updateFilterMatch()
        }
        
    }
    @objc func jumpreleaseHotVc(){
        
        let  releaseVc = GetMoreChanceViewController.loadFromNib()
        self.navigationController?.pushViewController(releaseVc, animated: true)
    }
}
extension NewMatchingViewController:YHDragCardDataSource,YHDragCardDelegate{
    func numberOfCount(_ dragCard: YHDragCard) -> Int {
        return self.cellCount
    }
    
    func dragCard(_ dragCard: YHDragCard, indexOfCell index: Int) -> YHDragCardCell {
        var cell = dragCard.dequeueReusableCell(withIdentifier: "ID") as? MatchCardViewCell
        if cell == nil {
            cell = UINib.init(nibName: "MatchCardViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? MatchCardViewCell
        }
        let info = MatchLimitCountManager.shared.viewModel.output.outsideGreetingDatas.value[index]
        info.backImageDecodeProcess(targetSize:CGSize.init(width: screenWidth*0.8*0.9 - 20 , height:screenWidth*0.8*0.9 - 20 )) //提前下载下图片 可优化一组的提前显示  
        cell?.updateInfo(info)
        cell?.removeAction = {
            [weak self] in
            guard let `self` = self  else {return }
            dragCard.nextCard(direction: .left)
        }
        return cell!
    }
    func dragCard(_ dragCard: YHDragCard, didSelectIndexAt index: Int, with cell: YHDragCardCell) {
        
    }
    
    func dragCard(_ dragCard: YHDragCard, didDisplayCell cell: YHDragCardCell, withIndexAt index: Int) {
        let info =  MatchLimitCountManager.shared.updateCurrentIndex(index)
        if let card = cell as? MatchCardViewCell {
            self.currentDisplayCell = card
            self.afterDelay(0.0001) {
                card.lbldetail.centerVertically() //  需要加一点延迟才有效
                self.guideCheckProcess() //不加延迟首次会有偏移 导致扣图引导扣图位置不准确 api肯定没问题
            }
            UIView.animate(withDuration: 0.2) {
                card.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                card.lbldetail.alpha = 1
                card.transform = .identity
            }
        }
    }
    //MARK:  需要注意的点是 这个方法调用需注意 nextcard方法会再次触发回调  那么就会调用两次
    /// 直接移出的逻辑后续
    /// - Parameters:
    ///   - dragCard: <#dragCard description#>
    ///   - index: <#index description#>
    fileprivate func dealLeftAction(_ dragCard: YHDragCard, _ index: Int) {
        debugPrint("====== ")
        MatchLimitCountManager.shared.reduceMatchCount {[weak self] (finish) in
            guard let `self` = self  else {return }
            if finish == .reducefailed {
                dragCard.revoke(direction: .left)
                self.toastTip("Network failed".localiz())
                //由于revoke只能revoke大于1数组的所以
                if self.cellCount == 1 {
                    self.cardBodyView.reloadData(animation: false)
                }
            }
            //扣不动了则revoke调
            else if finish == .reducenomatch{
                dragCard.revoke(direction: .left)
                if self.cellCount == 1 {
                    self.cardBodyView.reloadData(animation: false)
                }
            }
            else{
                self.checkRefresh(index)
            }
        }
    }
    
    /// 左滑右划的渐变效果
    /// - Parameters:
    ///   - dragCard: <#dragCard description#>
    ///   - cell: <#cell description#>
    ///   - index: <#index description#>
    ///   - direction: <#direction description#>
    ///   - canRemove: <#canRemove description#>
    func dragCard(_ dragCard: YHDragCard, currentCell cell: YHDragCardCell, withIndex index: Int, currentCardDirection direction: YHDragCardDirection, canRemove: Bool) {
        guard let moveCell = cell as? MatchCardViewCell else {
            return
        }
        let ratio = abs(direction.horizontalRatio)
        switch direction.horizontal{
        case .left:
            moveCell.leftAnimation.alpha = ratio
            
        case  .right:
            moveCell.rightAniamtion.alpha = ratio
        default:
            break
        }
        if ratio < 0.1 {
            moveCell.leftAnimation.alpha = 0
            moveCell.rightAniamtion.alpha = 0
        }
    }
    
    fileprivate func checkRefresh(_ currentIndex:Int) {
        if  MatchLimitCountManager.shared.reduceCount.value.0  != 0{
            if currentIndex == self.cellCount - 1 {
                MatchLimitCountManager.shared.firstRefreshLimit()
            }
        }
    }
    
    fileprivate func goUserChat(_ index:Int) {
        if index <= MatchLimitCountManager.shared.viewModel.output.outsideGreetingDatas.value.count - 1 {
            let  greet = MatchLimitCountManager.shared.viewModel.output.outsideGreetingDatas.value[index]
            guard let uid = greet.userId else {
                return
            }
            if !UserManager.isOwnerMySelf(uid) {
                GlobalRouter.shared.dotaskUser(uid)
            }
        }
    }
    
    /// 进入聊天页面
    /// - Parameters:
    ///   - dragCard: <#dragCard description#>
    ///   - index: <#index description#>
    ///   - andNext: <#andNext description#>
    fileprivate func dealRightAction(_ dragCard: YHDragCard, _ index: Int,andNext:Bool = false) {
        if MatchLimitCountManager.shared.reduceCount.value.0 == 0 {
            dragCard.revoke(direction: .right)
            goUserChat(index)
            return
        }
        MatchLimitCountManager.shared.reduceMatchCount {[weak self] (finish) in
            guard let `self` = self  else {return }
            if finish == .reducefailed {
                dragCard.revoke(direction: .right)
                if self.cellCount == 1 {
                    self.cardBodyView.reloadData(animation: false)
                }
                self.toastTip("Network failed".localiz())
            }else if finish == .reducenomatch{
                
                dragCard.revoke(direction: .right)
                if self.cellCount == 1 {
                    self.cardBodyView.reloadData(animation: false)
                }
            }else{
                self.goUserChat(index)
                self.checkRefresh(index)
            }
        }
    }
    
    func dragCard(_ dragCard: YHDragCard, didRemoveCell cell: YHDragCardCell, withIndex index: Int, removeDirection: YHDragCardMoveDirection) {
        print("索引为\(index)的卡片滑出去了")
        switch removeDirection {
        case .up:
            print("向上移除")
        case .down:
            print("向下移除")
        case .left:
            dealLeftAction(dragCard, index)
        case .right:
            dealRightAction(dragCard, index)
        case .none:
            print("default")
        }
        
    }
    
}



extension  NewMatchingViewController {
    
    //处理链式 需再优化处理流程
    /// 第一页引导 左右滑动的
    fileprivate func checkFirstGuide() {
        if !GuideConfig.checkGuideend(GuideEnter.MacthOtherDisLikeTip.rawValue) {
            if let currentCell = self.currentDisplayCell, self.cellCount > 0 ,let currentDislikeBtn = currentCell.disLikeBtn {
                let point = keyWindow?.convert(currentDislikeBtn.bounds, from: currentDislikeBtn).origin ?? .zero
                let snapimage = currentDislikeBtn.snapViewImage()
                let guidV = GuideMatchTipView.loadNibView()
                guidV?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                guidV?.configGuideView(.MacthOtherDisLikeTip, holoView: snapimage, size: currentDislikeBtn.bounds.size, point:point)
                guidV?.showOnWindow(direction: .center,coverColor: nil, enableclose: false)
                guidV?.doneBlock = {
                    [weak self] guideEnter in
                    guard let `self` = self  else {return }
                    GuideConfig.updateGuide(guideEnter, true)
                    self.guideCheckProcess()
                }
            }
        }
    }
    
    
    /// 第二页引导
    fileprivate func checkSecondGuide() {
        if !GuideConfig.checkGuideend(GuideEnter.MacthOtherLikeTip.rawValue) {
            if let currentCell = self.currentDisplayCell, self.cellCount > 0,let currentlikeBtn =  currentCell.taskBtn {
                let point = keyWindow?.convert(currentlikeBtn.bounds, from: currentlikeBtn).origin ?? .zero
                let snapimage = currentlikeBtn.snapViewImage()
                let guidV = GuideMatchTipView.loadNibView()
                guidV?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                guidV?.configGuideView(.MacthOtherLikeTip, holoView: snapimage, size: currentlikeBtn.bounds.size, point: point)
                guidV?.showOnWindow(direction: .center,coverColor: nil, enableclose: false)
                guidV?.doneBlock = {
                    [weak self] guideEnter in
                    guard let `self` = self  else {return }
                    GuideConfig.updateGuide(guideEnter, true)
                    self.guideCheckProcess()
                }
            }
        }
    }
    
    /// 第三页引导
    fileprivate func checkThirdGuide() {
        if !GuideConfig.checkGuideend(GuideEnter.MatchViewFilter.rawValue) {
            let guidV = GuideMatchTipView.loadNibView()!
            guidV.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            let size = filterBtn.bounds.size
            let snapimage = filterBtn.snapViewImage()
            let  point = keyWindow?.convert(filterBtn.bounds, from: filterBtn).origin ?? .zero
            guidV.configGuideView(.MatchViewFilter, holoView: snapimage, size: CGSize.init(width: size.width + 4, height: size.height + 4), point:CGPoint.init(x: point.x - 2, y: point.y - 2))
            guidV.showOnWindow(direction: .center,coverColor: nil, enableclose: false)
            guidV.doneBlock = {
                [weak self] guideEnter in
                guard let `self` = self  else {return }
                GuideConfig.updateGuide(guideEnter, true)
                self.guideCheckProcess()
            }
        }
    }
    /// 进入检查引导流程
    func guideCheckProcess()  {
        //引导完毕直接return
        if GuideConfig.checkStep() == -1 {
            return
        }
        if GuideConfig.checkStep() == 0 {
            self.checkFirstGuide()
        }else if GuideConfig.checkStep() == 1 {
            self.checkSecondGuide()
        }
        else if GuideConfig.checkStep() == 2{
            self.checkThirdGuide()
        }
    }
    
}



extension  NewMatchingViewController {
//    func  testVideo(){
//        self.navigationController?.pushViewController(TestVideoVc.init(), animated: false)
//    }
}
