//
//  DiscoverTopicViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/22.
//

import Foundation
import JXSegmentedView
import RxDataSources
//话题比赛
class DisCoverTopicViewController: BaseViewController {
    var emptyView:UIView?
    var isEmpty:Bool = false
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    var mjrefreshfooter:GlobalRefreshFooter?
    var  datasource:RxTableViewSectionedReloadDataSource<DiscoverItemListSection>!
    var  cellHeightDic:[Int:CGFloat] = [:]
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight = 10
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: DisCoverTopicVoiceCell.self)
        tableview.register(cellType: DiscoverTopicImageAndVideoCell.self)
        return tableview
    }()
    var viewModel: DisCoverVmModel  = DisCoverVmModel.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.bindViewModel(to: self.viewModel)
        self.viewModel.input.requestCommand.onNext({}())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func setupView()  {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self  else {return }
            self.viewModel.input.requestCommand.onNext({}())
        })
        self.tableView.mj_header = self.mjrefreshHeader
        self.mjrefreshfooter = GlobalRefreshFooter.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self  else {return }
            self.viewModel.input.requestFoot.onNext({}())
        })
        self.tableView.mj_footer = self.mjrefreshfooter
        self.viewModel.output.autoSetRefreshHeaderStatus(header: mjrefreshHeader, footer: self.mjrefreshfooter).disposed(by: self.rx.disposeBag)
        _ = self.tableView.rx.setDelegate(self)
    }
    override func forceRefresh(notification: NSNotification? = nil) {
        self.viewModel.input.requestCommand.onNext({}())
    }
}
extension DisCoverTopicViewController:VMBinding {
    func bindViewModel(to model: DisCoverVmModel) {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.viewModel.output.emptyDataShow.subscribe(onNext: { [weak self] (empty) in
            guard let `self` = self  else {return }
            self.isEmpty = empty
            self.tableView.setNeedsLayout()
        }).disposed(by: self.rx.disposeBag)
        datasource = RxTableViewSectionedReloadDataSource<DiscoverItemListSection>.init(configureCell: { (datasource, tableview, index, item) -> UITableViewCell in
            switch datasource[index] {
            case .topic(let item):
                if item.type == .photo || item.type == .video{
                    let cell:DiscoverTopicImageAndVideoCell = tableview.dequeueReusableCell(for: index, cellType: DiscoverTopicImageAndVideoCell.self)
                    cell.updateDisPlay(item)
                    cell.actionDetailMore = {
                        [weak self] topic in
                        guard let `self` = self  else {return }
                        self.jumpDetailTopic(item: topic)
                    }
                    return cell
                }else{
                    let cell:DisCoverTopicVoiceCell = tableview.dequeueReusableCell(for: index, cellType: DisCoverTopicVoiceCell.self)
                    cell.updateDisPlay(item)
                    cell.actionDetailMore = {
                        [weak self] topic in
                        guard let `self` = self  else {return }
                        self.jumpDetailTopic(item: topic)
                    }
                    return cell
                }
            case .recommend(_):
                let cell:DiscoverRecommendCell = tableview.dequeueReusableCell(for: index, cellType: DiscoverRecommendCell.self)
                return cell
            }
        })
        self.viewModel.output.disCoverDatas.asDriver().drive(tableView.rx.items(dataSource: datasource)).disposed(by: self.rx.disposeBag)
        
        self.tableView.rx.modelSelected(DiscoverItem.self)
          .subscribe(onNext: { [weak self] item in
            guard let `self` = self  else {return }
            switch  item {
            case .topic(let item):
                self.jumpDetailTopic(item: item)
            default:
                break
            }
        }).disposed(by: self.rx.disposeBag)
    }
    func jumpDetailTopic(item:DiscoverTopicModel){
        let detailVc = DisCoverTopicDetailViewController.init()
        detailVc.topicId.accept(item.topicId)
        self.navigationController?.pushViewController(detailVc, animated: true)
        
    }
}
extension DisCoverTopicViewController:JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}
extension DisCoverTopicViewController:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return  self.isEmpty
        }
    }
    func configEmptyView() -> UIView? {
        if let view = self.emptyView {
            return view
        }
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.tableView.bounds
        emptyv?.placeimage.image = UIImage(named: "emptyview")
        self.emptyView = emptyv
        return emptyv
    }
}
extension  DisCoverTopicViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1){
            return
        }
        UIView.stackViewEffect(view: cell, offsetY: 8, duration: 0.2)
    }
}
