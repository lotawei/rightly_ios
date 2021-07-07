//
//  GreetingUsertemplateViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/1.
//

//
//  PersonalViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/2.
//

import UIKit
import RxSwift
import Reusable
import RxDataSources
import MJRefresh
import MBProgressHUD



class GreetingUsertemplateViewController: BaseViewController {
    var refreshBlock:(()->Void)?=nil
    static var  selectGreetingResult:BehaviorSubject<GreetingResult?> = BehaviorSubject.init(value: nil)
    var  userid:Int64? = nil
    var  taskType:TaskType?=nil {
        didSet {
            self.title = taskType?.typeTitle()
        }
    }
   
    var  usertaskId:Int64?=nil
    var  toUserid:Int64? = nil
    lazy var postButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(postAction(_:)), for: .touchUpInside)
        button.setTitle("Send".localiz(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor.init(hex: "27D3CF")
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.frame = CGRect.init(x: 0, y: 0, width: 68, height: 30)
        
        return button
    }()
    var viewModel: SelectGreetingTaskVMModel  = SelectGreetingTaskVMModel()
    private var dataSource: RxTableViewSectionedReloadDataSource<UserInfoListSection>!
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    var mjrefreshfooter:GlobalRefreshFooter?
    
    var deleteTipView:AlterViewTipView?=AlterViewTipView.loadNibView()
    var operationView:GreetingItemBottomView?=GreetingItemBottomView.loadNibView()
    var otherAlterView:OtherAlterTipView?=OtherAlterTipView.loadNibView()
    var viewtypeSelectView:PublishViewTypeSelectView?=PublishViewTypeSelectView.loadNibView()
    var emptyview:UIView?
    var  isempty:Bool = false {
        didSet {
            self.tableview.setNeedsLayout()
        }
    }
    fileprivate lazy var  tableview:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.backgroundColor = .clear
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.rowHeight = UITableView.automaticDimension
        
        tableview.register(cellType: SelectItemPlateViewTaskCell.self)
        tableview.estimatedRowHeight =    300
        
        tableview.estimatedSectionHeaderHeight = 0
        tableview.estimatedSectionFooterHeight = 0
        
        let footView = UIView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: safeBottomH))
        footView.backgroundColor = .clear
        tableview.tableFooterView = footView
        
        return tableview
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        GreetingUsertemplateViewController.selectGreetingResult.onNext(nil)
        setupViews()
        bindViewModel(to: self.viewModel)
    }
    func  setupViews(){
        let  postItem = UIBarButtonItem.init(customView: self.postButton)
        self.navigationItem.rightBarButtonItem = postItem
        
        self.view.addSubview(self.tableview)
        var bottom:CGFloat = 0
        if !(self.tabBarController?.tabBar.isHidden ?? false){
            bottom = -tabBarH-20
        }else{
            bottom = 0
        }
        self.tableview.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview().offset(bottom)
            maker.width.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        self.mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self  else {return }
            self.viewModel.input.requestCommand.onNext((self.userid,self.taskType))
            
        })
        self.tableview.mj_header = self.mjrefreshHeader
        self.mjrefreshfooter = GlobalRefreshFooter.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self  else {return }
            self.viewModel.input.requestfootCommand.onNext((self.userid,self.taskType))
            
        })
 
//        self.tableview.mj_footer = self.mjrefreshfooter
        enablePostButton(false)
        
        GreetingUsertemplateViewController.selectGreetingResult.asObservable().subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if  res != nil {
                self.enablePostButton(true)
            }
            else{
                self.enablePostButton(false)
            }
            
        }).disposed(by: self.rx.disposeBag)
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.requestCommand.onNext((self.userid,self.taskType))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func  enablePostButton(_ enable:Bool){
        if enable {
            UIView.animate(withDuration: 0.4) {
                self.postButton.alpha = 1
            }
          
            self.postButton.isEnabled = true
        }else{
            UIView.animate(withDuration: 0.4) {
                self.postButton.alpha = 0.5
            }
            self.postButton.isEnabled = false
        }
        
    }
    @objc func postAction(_ sender:Any) {
        guard var result = try? GreetingUsertemplateViewController.selectGreetingResult.value() else {
            self.toastTip("Select a template ".localiz())
            return
        }
        
        guard let touserId = self.toUserid else {
            self.toastTip("miss touserid ")
            return
        }
        
        let userporvider = UserProVider.init()
        
        result.taskId = self.usertaskId
        result.toUserId = self.toUserid
        userporvider.greetingForUser(type: .greeting, newtempResult:result, touserId: touserId, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self else {return}
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                                           self.toastTip("greeting success ".localiz())
                                           self.refreshBlock?()
                                           self.navigationController?.popViewController(animated: true)
                                       }
            },onError: { (err) in
                DispatchQueue.main.async {
                                       self.toastTip("greeting failed ".localiz())
                                   }
            }).disposed(by: self.rx.disposeBag)
    }
}
extension GreetingUsertemplateViewController :VMBinding {
    func bindViewModel(to model: SelectGreetingTaskVMModel) {
        
        self.tableview.setEmtpyViewDelegate(target: self)
        dataSource = RxTableViewSectionedReloadDataSource<UserInfoListSection>.init(configureCell: { (datasource, tableview, index, item) -> UITableViewCell in
            switch datasource[index] {
                case .greetingUser(let result):
                let cell:SelectItemPlateViewTaskCell = tableview.dequeueReusableCell(for: index, cellType: SelectItemPlateViewTaskCell.self)
                let vmmodel = GreetingResultVModel.init(result)
                cell.bindVmData(vmmodel)
                if let  selectres = try? GreetingUsertemplateViewController.selectGreetingResult.value() {
                    vmmodel.output.itemSelected.accept(selectres == result)
                }
                else{
                    vmmodel.output.itemSelected.accept(false)
                }
                cell.selectItemClick = {
                    [weak self] result in
                    guard let `self` = self  else {return }
                    GreetingUsertemplateViewController.selectGreetingResult.onNext(result)
                    self.tableview.reloadData()
                    
                }
                return cell
            default:
                return  UITableViewCell.init()
            }
            return UITableViewCell.init()
        })
        self.viewModel.output.useritemsdata.asDriver().drive(tableview.rx.items(dataSource: dataSource)).disposed(by: self.rx.disposeBag)
        self.viewModel.output.autoSetRefreshHeaderStatus(header: mjrefreshHeader, footer: self.mjrefreshfooter).disposed(by: self.rx.disposeBag)
        self.viewModel.output.emptyDataShow.subscribe(onNext: { [weak self] (show) in
            guard let `self` = self  else {return }
            self.isempty = show
        }).disposed(by: self.rx.disposeBag)
        
//        try? self.tableview.rx.modelSelected(UserItem.self)
//            .subscribe(onNext: { [weak self] item in
//                guard let `self` = self  else {return }
//                //            let  vc = UserPublishViewController.loadFromNib()
//                switch  item {
//                case .greetingOwer(let result):
//                    self.jumpGreetingDetail(result)
//                    break
//
//                }
//
//            }).disposed(by: self.rx.disposeBag)
//        self.viewModel.input.requestUserTaskCommand.accept(self.userid)
        
    }
}



extension GreetingUsertemplateViewController:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return  self.isempty
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyview {
            return view
        }
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.tableview.bounds
        emptyv?.placeimage.image = UIImage(named: "emptyview")
        self.emptyview = emptyv
        return emptyv
        
    }
}
