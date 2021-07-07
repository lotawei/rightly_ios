////
////  DiscoverRecommendViewController.swift
////  Rightly
////
////  Created by lejing_lotawei on 2021/5/22.
////
//
import Foundation
import JXSegmentedView

///// 推荐
class DisCoverRecommendViewController: BaseViewController {
    var emptyView:UIView?
    var isEmpty:Bool = false
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    var mjrefreshfooter:GlobalRefreshFooter?
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight =    85
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        return tableview
        
    }()
    var viewModel: DisCoverVmModel  = DisCoverVmModel.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.bindViewModel(to: self.viewModel)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.requestCommand.onNext({}())
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
    }
}
extension DisCoverRecommendViewController:VMBinding {
    func bindViewModel(to model: DisCoverVmModel) {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.viewModel.output.emptyDataShow.subscribe(onNext: { [weak self] (empty) in
            guard let `self` = self  else {return }
            self.isEmpty = empty
            self.tableView.setNeedsLayout()
        }).disposed(by: self.rx.disposeBag)
    }
}
extension DisCoverRecommendViewController:JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}
extension DisCoverRecommendViewController:EmptyViewProtocol{
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
