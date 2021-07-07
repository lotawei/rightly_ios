//
//  GreetListViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class GreetListViewController: BaseViewController {
    private var datasource:RxTableViewSectionedReloadDataSource<SectionModel<String,FriendViewModel>>!
    private var pagedata = BehaviorRelay.init(value: [SectionModel<String,FriendViewModel>]())
    private var messageDatas:[SectionModel<String,FriendViewModel>] = []
    private var pageNum:Int = 1
    private let greetporvider = MessageTaskGreetProvider.init()
    var isEmpty:Bool = false {
        didSet {
            self.tableView.setNeedsDisplay()
        }
    }
    var emptyview:UIView?
    lazy var tableView:UITableView = {
        let resultView = UITableView()
        resultView.separatorStyle = .none
        resultView.rowHeight = 156.0
        let footerH = isIphoneX ? safeBottomH : 10.0
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: footerH))
        resultView.tableFooterView = footerView
        resultView.register(.init(nibName: "GreetListTableViewCell", bundle: nil), forCellReuseIdentifier: "greetListId")
        
        resultView.mj_header = GlobalRefreshAutoGiftHeader.init(refreshingBlock: { [weak self] in
            debugPrint("下拉刷新")
            self?.pageNum = 1
            self?.requestData()
        })
        resultView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: { [weak self] in
            debugPrint("上拉刷新")
            self?.pageNum += 1
            self?.requestData()
        })
        
        resultView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else {return}
            if self.messageDatas.count <= 0 {
                return
            }
             
            if indexPath.row >= self.messageDatas[0].items.count {
                return
            }
            
            let viewModel:FriendViewModel = self.messageDatas[0].items[indexPath.row]
            guard let otherUserId = viewModel.userId else {
                return
            }
            let viewCtrl = GreetInfoViewController(otherUserId)
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }).disposed(by: self.rx.disposeBag)
        return resultView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.messageDatas.count <= 0 {
            self.tableView.mj_header?.beginRefreshing()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setupView() {
        self.title = "new_greeting_cell".localiz()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    fileprivate func bindData() {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, FriendViewModel>>.init(configureCell: { (source, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "greetListId", for: indexPath) as! GreetListTableViewCell
            cell.bindViewModel(item)
            return cell
        })
        self.pagedata.asDriver().drive(self.tableView.rx.items(dataSource: datasource)).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func requestData() {
        self.greetporvider.greetingWithMe(self.pageNum, pageSize: 10, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (requestResponse) in
                guard let `self` = self else {return}
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
                self.pagedata.accept(self.messageDatas)
                switch requestResponse {
                case .success(let response):
                    guard let datas = response else {
                        return
                    }
                    
                    if self.messageDatas.count <= 0 {
                        self.messageDatas.append(SectionModel(model: "", items: []))
                    }
                    
                    if self.pageNum <= 1 {
                        self.messageDatas[0].items.removeAll()
                    }
                    guard let  results =  datas?["results"] as? [[String:Any]] else {
                        debugPrint("dirty data")
                        return
                    }
                    
                    for tempDic:[String:Any] in results {
                        let tempViewModel = FriendViewModel(jsonData: tempDic)
                        self.messageDatas[0].items.append(tempViewModel)
                    }
                    
                    self.pagedata.accept(self.messageDatas)
                    if (self.messageDatas.first?.items.count ?? 0) == 0 {
                        self.isEmpty = true
                    }
                    else{
                        self.isEmpty = false
                    }
//                    debugPrint(results)
                case .failed(_):
                    self.pageNum -= 1
                    MBProgressHUD.showError("request failed".localiz())
                }
            }).disposed(by: self.rx.disposeBag)
    }
}
extension GreetListViewController:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return  self.isEmpty
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyview {
            return view
        }
        var  emptyv = EmptyView.loadNibView()
        emptyv?.lblcontent.text = "No_Greeting_Message".localiz()
        emptyv?.placeimage.image = UIImage.init(named: "No_Greeting_Message")
        emptyv?.frame = self.tableView.bounds
        self.emptyview = emptyv
        return emptyview
    }
}
