//
//  UserFollowingViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/17.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import MJRefresh
import RxDataSources
class UserFollowViewController:BaseViewController {
    var userid:Int64? = nil {
        didSet {
            self.viewModel.input.requestCommand.onNext(userid)
        }
    }
    var emptyview:UIView?
    var viewModel: UserFollowingVMModel =  UserFollowingVMModel.init(BehaviorSubject.init(value: []))
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: UserFollowCell.self)
        return tableview
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.left.bottom.right.top.equalToSuperview()
        }
        
        self.mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            [weak self] in
            self?.viewModel.input.requestCommand.onNext(self?.userid)
        })
        self.tableView.mj_header = self.mjrefreshHeader
        bindViewModel(to: self.viewModel)
    }
    
    @objc func tapActionButton(_ sender:Any){
        UserManager.manager.cleanUser()
        AppDelegate.reloadRootVC()
    }
}
extension UserFollowViewController:VMBinding {
    func bindViewModel(to model: UserFollowingVMModel) {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.viewModel.output.sampleDatas.asDriver(onErrorJustReturn: []).drive(self.tableView.rx.items(dataSource: self.viewModel.output.dataSource))
            .disposed(by: self.rx.disposeBag)
        self.viewModel.output.displayTypeTitle.asDriver().drive(self.rx.title).disposed(by: self.rx.disposeBag)
        self.viewModel.output.autoSetRefreshHeaderStatus(header: mjrefreshHeader, footer: nil).disposed(by: self.rx.disposeBag)
        try? self.tableView.rx.modelSelected(FollowItem.self)
          .subscribe(onNext: { [weak self] item in
            guard let `self` = self  else {return }
            let personalVc = PersonalViewController.loadFromNib()
            switch  item {
            case .followItem(let item):
                
                personalVc.userid = item.user?.userId ?? item.userId
                if UserManager.isOwnerMySelf(personalVc.userid) {
                    return 
                }
                self.navigationController?.pushViewController(personalVc, animated: true)
            }
          }).disposed(by: self.rx.disposeBag)
    }
}

extension UserFollowViewController:EmptyViewProtocol {
    var showEmtpy: Bool {
        get {
            return  self.viewModel.isempty
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyview {
            return view
        }
        
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.tableView.bounds
        emptyv?.placeimage.image = UIImage(named: "emptyview")
        self.emptyview = emptyv
        return emptyv
    }
}

