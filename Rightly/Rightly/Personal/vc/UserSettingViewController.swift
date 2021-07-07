//
//  UserSettingViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/17.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MBProgressHUD
class UserSettingViewController:BaseViewController {
    var viewModel: UserSettingViewModel =  UserSettingViewModel.init()
    var tipView:LanuageSwitchView? = LanuageSwitchView.loadNibView()
    lazy var logout: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapActionButton), for: .touchUpInside)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitle("Log Out".localiz(), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }()
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.backgroundColor = .white
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: UserSettingCell.self)
        tableview.register(cellType: UserSwitchSettingCell.self)
        return tableview
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.title = "Setting".localiz()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(120)
            
        }
        self.view.addSubview(self.logout)
        self.logout.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(24)
            maker.height.equalTo(30)
            maker.top.equalTo(self.tableView.snp.bottom).offset(10)
        }
        
        bindViewModel(to: self.viewModel)
        
    }
    
    
    @objc func tapActionButton(_ sender:Any){
        let  tipView = AlterViewTipView.loadNibView()
        tipView?.displayerInfo(.logoutTip)
        tipView?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        tipView?.doneBlock = { [weak self] in
            
            UserManager.manager.cleanUser()
            self?.afterDelay(0.5, closure: {
                AppDelegate.reloadRootVC()
            })
       
        }
        tipView?.showOnWindow(direction:.center,enableclose: false)
     
    }
    
   
    
}
extension UserSettingViewController:VMBinding {
    func bindViewModel(to model: UserSettingViewModel) {
        self.viewModel.output.sampleDatas.asDriver(onErrorJustReturn: []).drive(self.tableView.rx.items(dataSource: self.viewModel.output.dataSource))
            .disposed(by: self.rx.disposeBag)
        try? self.tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexpath) in
            guard let `self` = self  else {return }
//            if indexpath.row ==  0 {
//                let accountvc = UserAccountViewController.loadFromNib()
//                self.navigationController?.pushViewController(accountvc, animated: true)
//            }
//           else if indexpath.row ==  1 {
////                let  noticeVc = PersonalCenterViewController.init()
////                noticeVc.hidesBottomBarWhenPushed = true
////                self.navigationController?.pushViewController(noticeVc, animated: false)
//            }
//           else if indexpath.row ==  2 {
//                GlobalRouter.shared.jumpByUrl(url: "http://www.baiddu.com")
//            }
            if indexpath.row ==  0 {
                 
            }
           else if indexpath.row ==  1 {
                GlobalRouter.shared.jumpByUrl(url: "http://www.baiddu.com")
            }
//           //about
//           else if indexpath.row ==  2{
//                GlobalRouter.shared.jumpByUrl(url: "http://cc.channelthree.tv/about.html")
//            }
            
        }).disposed(by: self.rx.disposeBag)
            
    }
    
    func lanuageSwitch()  {
       
        tipView?.frame = CGRect.init(origin: .zero, size: CGSize.init(width: screenWidth, height: 120))
        tipView?.showOnWindow( direction: .up)
        tipView?.changeLanguage = {
            index in
            if index == 0  {
                LanguageManager.shared.setLanguage(language: .en)
            }else{
                LanguageManager.shared.setLanguage(language: .zhHans)
            }
            MBProgressHUD.showStatusInfo("loading".localiz())
            self.afterDelay(0.5) {
                MBProgressHUD.dismiss()
                AppDelegate.reloadRootVC()
            }
           
        }
        
    }
        
}

