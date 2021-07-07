//
//  PersonalNoticeViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/1.
//

import Foundation
import JXSegmentedView
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh
class PersonalNotifyViewController:BaseViewController {
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    var mjrefreshfooter:GlobalRefreshFooter?
    var emptyview:UIView?
    var emptyShow = false
    var  displayNotifyType:[NotifycationType] = [NotifycationType]() {
        didSet {
            self.viewModel.input.typesselected.accept(displayNotifyType)
            self.viewModel.input.requestCommand.onNext(nil)
            
        }
    }
    var viewModel: UserNotifyVModel =  UserNotifyVModel.init()
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = 100
        tableview.estimatedSectionHeaderHeight = 0
        tableview.register(cellType: NoticeMetionCell.self)
        tableview.register(cellType: SystemNoticeCell.self)
        return tableview
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.height.equalToSuperview()
            
        }
        
        self.mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            [weak self] in
            self?.viewModel.input.requestCommand.onNext(nil)
            
        })
        self.tableView.mj_header = self.mjrefreshHeader
        self.mjrefreshfooter = GlobalRefreshFooter.init(refreshingBlock: {
            [weak self] in
            self?.viewModel.input.requestfootCommand.onNext(nil)
            
        })
        self.tableView.mj_footer = self.mjrefreshfooter
        
        bindViewModel(to: self.viewModel)

        self.viewModel.output.autoSetRefreshHeaderStatus(header: mjrefreshHeader, footer: self.mjrefreshfooter).disposed(by: self.rx.disposeBag)
    }
    
    
    @objc func tapActionButton(_ sender:Any){
        UserManager.manager.cleanUser()
        AppDelegate.reloadRootVC()
    }
    
    
}
extension PersonalNotifyViewController:VMBinding {
    func bindViewModel(to model: UserNotifyVModel) {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.viewModel  = model
        guard let  datasource = self.viewModel.output.dataSource else {
            return
        }
        self.viewModel.output.itemNotifyDatas.asDriver(onErrorJustReturn: []).drive(self.tableView.rx.items(dataSource: datasource))
            .disposed(by: self.rx.disposeBag)
        self.viewModel.output.emptyDataShow.asObserver().subscribe(onNext: { [weak self] (show) in
            guard let `self` = self  else {return }
            self.emptyShow = show
            self.tableView.setNeedsLayout()
        }).disposed(by: self.rx.disposeBag)
        try? self.tableView.rx.modelSelected(NotifyItem.self)
          .subscribe(onNext: { [weak self] item in
            guard let `self` = self  else {return }
            
            switch  item {
            case .notifyItem(let item):
                guard let  greetid = item.extraData?.greetingId else {
                    return
                }
//                let vc = GreetingDetailViewController.loadFromNib()
//                vc.greetid = greetid
//                self.navigationController?.pushViewController(vc, animated: true)
                GlobalRouter.shared.jumpDynamicDetail("\(greetid)")
            }
           
          }).disposed(by: self.rx.disposeBag)
    }
}


extension PersonalNotifyViewController:JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

extension PersonalNotifyViewController:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return self.emptyShow
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyview {
            return view
        }
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.tableView.bounds
        self.emptyview = emptyv
        return emptyv
        
    }
}
