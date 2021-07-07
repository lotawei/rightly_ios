//
//  MatchRanKViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//

import Foundation
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh
import SnapKit
class MatchRanKViewController:BaseViewController {
    var isRresh:Bool = false
    var mjrefreshHead:GlobalRefreshAutoGiftHeader?
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight =    85
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: TopicRankUserCell.self)
        tableview.register(cellType: EmptyContentCell.self)
        return tableview
    }()
    private var dataSource: RxTableViewSectionedReloadDataSource<TopicRankListSection>!
    var  topicRankDatas:BehaviorSubject<[TopicRankListSection]> = BehaviorSubject.init(value: [])
    var  navTop:Constraint?=nil
    var  navHeight:Constraint?=nil
    let  customNav:RankHeadView?=RankHeadView.loadNibView()
    var  topicDetail:BehaviorRelay<DiscoverTopicModel?> = BehaviorRelay.init(value: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        setUpViews() //子视图
        subscribNavAction() //自定义导航事件监听
        topicDetailInital() //话题详情请求
        bindData()
    }
    func setUpViews(){
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        if let  navBarV = self.customNav {
            navBarV.translatesAutoresizingMaskIntoConstraints  = false //防止约束冲突
            self.tableView.tableHeaderView = navBarV
            navBarV.snp.makeConstraints { (maker) in
                navTop = maker.top.equalToSuperview().offset(0).constraint
                maker.centerX.equalToSuperview()
                maker.width.equalTo(screenWidth)
                navHeight = maker.height.equalTo(290).constraint
            }
        }
        mjrefreshHead = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self ,let detail = self.topicDetail.value else {return }
            self.requestDetailTopicRank(detail.topicId)
        })
        self.tableView.rx.didScroll.subscribe(onNext: { [weak self]  in
            guard let `self` = self,let nav = self.customNav else {return }
            self.navHeight?.update(offset: 290 - self.tableView.contentOffset.y)
            self.navTop?.update(offset: self.tableView.contentOffset.y)
            if self.tableView.contentOffset.y < -64 ,let detail = self.topicDetail.value{
                self.requestDetailTopicRank(detail.topicId)
            }
        }).disposed(by: self.rx.disposeBag)
        
    }
    fileprivate func  bindData(){
        dataSource = RxTableViewSectionedReloadDataSource<TopicRankListSection>.init(configureCell: { (datasource, tableview, index, item) -> UITableViewCell in
            switch datasource[index] {
            case .rankUserItem(let rankItem):
                let cell:TopicRankUserCell = tableview.dequeueReusableCell(for: index, cellType: TopicRankUserCell.self)
                cell.updateRankInfo(rankItem,index.row)
                return cell
            default:
                let cell:EmptyContentCell = tableview.dequeueReusableCell(for: index, cellType: EmptyContentCell.self)
                return cell
            }
        })
        self.topicRankDatas.asObserver().asDriver(onErrorJustReturn: []).drive(tableView.rx.items(dataSource: dataSource)).disposed(by: self.rx.disposeBag)
        try? self.tableView.rx.modelSelected(TopicRankItem.self).subscribe(onNext: { [weak self] item in
            guard let `self` = self  else {return }
            switch  item {
            case .rankUserItem(let item):
                //                GlobalRouter.shared.jumpDetailGreeting(greetingId: Int64(item.greetingId ?? 0))
                guard let greetingId = item.greetingId else {
                    return
                }
                GlobalRouter.shared.jumpDynamicDetail("\(greetingId)")
            default:
                break
            }
        }).disposed(by: self.rx.disposeBag)
    }
    /// 自定义导航栏事件
    func subscribNavAction(){
        /// 返回pop按钮
        customNav?.backBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: self.rx.disposeBag)
        ///
        customNav?.matchDetailIconBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.jumpRankTopicDetailInfoDescription()
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// 数据初始化
    func topicDetailInital()  {
        self.topicDetail.subscribe(onNext: { [weak self] (detaildata) in
            guard let `self` = self ,let detail = detaildata else {return }
            self.configTopicDetailDisplay(detail)
            self.requestDetailTopicRank(detail.topicId)
        }).disposed(by: self.rx.disposeBag)
    }
    fileprivate  func configTopicDetailDisplay(_ topicdetail:DiscoverTopicModel)  {
        self.customNav?.configDetail(topicdetail)
    }
    fileprivate func requestDetailTopicRank(_ topicId:Int64)  {
        if isRresh || self.tableView.isDragging{
            return
        }
        isRresh = true
        MBProgressHUD.showStatusInfo("Refreshing".localiz())
        DiscoverProvider.init().topicRankInfo(topicId, self.rx.disposeBag,{
            [weak self] serverDate in
            guard let `self` = self  else {return }
            self.customNav?.configTimerCutDown(serverDate)
        }).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.mjrefreshHead?.endRefreshing()
            self.isRresh = false
            MBProgressHUD.dismiss()
            if let rankinfo = res.modelArrType(TopicRankModel.self) {
                let  rankItem = rankinfo.map { (mode) -> TopicRankItem in
                    return .rankUserItem(mode)
                }
                var  itemSections = [TopicRankListSection]()
                itemSections.append(TopicRankListSection.init(items: rankItem))
                if rankItem.count == 0 {
                    itemSections.append(TopicRankListSection.init(items: [TopicRankItem.emptyItem]))
                }
                self.topicRankDatas.onNext(itemSections)
            }
            //            switch res {
            //            case .success(let info):
            //                guard let rankinfo = info else {
            //                    return
            //                }
            //                let  rankItem = rankinfo.map { (mode) -> TopicRankItem in
            //                    return .rankUserItem(mode)
            //                }
            //                var  itemSections = [TopicRankListSection]()
            //                itemSections.append(TopicRankListSection.init(items: rankItem))
            //                if rankItem.count == 0 {
            //                    itemSections.append(TopicRankListSection.init(items: [TopicRankItem.emptyItem]))
            //                }
            //                self.topicRankDatas.onNext(itemSections)
            //                break
            
            
        },onError: { (err) in
            MBProgressHUD.showError("Network Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
        
    }
    
}
extension MatchRanKViewController {
    func jumpRankTopicDetailInfoDescription(){
        if let topicDes = topicDetail.value?.infodescription, !topicDes.isEmpty {
            let  des = topicDes.replacingOccurrences(of: "#{storageBaseUrl}", with: "\(SystemManager.shared.storage?.storageBaseUrl ?? DominUrl)")
            GlobalRouter.shared.jumpByUrl(html: des, title: topicDetail.value?.name ?? "")
        }
    }
}
