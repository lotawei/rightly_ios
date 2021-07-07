//
//  UserAccountViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//



import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MBProgressHUD
class UserAccountViewController:BaseViewController {
    var viewModel: AccountVmModel =  AccountVmModel.init()
    
    lazy var logout: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapActionButton), for: .touchUpInside)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitle("Log out", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }()
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: IconTextImageMoreCell.self)
        return tableview
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accout".localiz()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.top.equalToSuperview()
            
            
        }
        self.view.addSubview(self.logout)
        
        bindViewModel(to: self.viewModel)
        
    }
    
    
    @objc func tapActionButton(_ sender:Any){
        let  tipView = AlterViewTipView.loadNibView()
        tipView?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        tipView?.doneBlock = {
            UserManager.manager.cleanUser()
            AppDelegate.reloadRootVC()
        }
        tipView?.showOnWindow(direction:.center,enableclose: false)
        
    }
    
    
}
extension UserAccountViewController:VMBinding {
    func bindViewModel(to model: AccountVmModel) {
        self.viewModel.output.sampleDatas.asDriver(onErrorJustReturn: []).drive(self.tableView.rx.items(dataSource: self.viewModel.output.dataSource))
            .disposed(by: self.rx.disposeBag)
        try? self.tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexpath) in
            guard let `self` = self  else {return }
            if indexpath.row ==  0 {
                let  avatarvc = UserChooseAvatarViewController.loadFromNib()
                self.navigationController?.pushViewController(avatarvc, animated: true)
            }
            else if indexpath.row ==  1 {
                let  nickvc = UserNickNameEditorViewController.loadFromNib()
                self.navigationController?.pushViewController(nickvc, animated: true)
            }
            else if indexpath.row ==  2 {
                let gendervc = UserGenderSelectViewController.loadFromNib()
                self.navigationController?.pushViewController(gendervc, animated: true)
            }
            else if indexpath.row ==  3 {
                self.showDatePicker()
            }
            else if indexpath.row ==  4{
                //apple 授权
                
            }
            else if indexpath.row ==  5{
                //facebook 授权
                
            }
            else if indexpath.row ==  6{
                //google 授权
                
            }
            
            
            
        }).disposed(by: self.rx.disposeBag)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.updateAction.accept({}())
    }
}

extension  UserAccountViewController {
    func showDatePicker(){
        //        let datePicker = DatePickerDialog.init(textColor: UIColor.white, buttonColor: UIColor.white, font: UIFont.systemFont(ofSize: 18), showCancelButton: true)
        //        let currentDate = Date()
        //        let mindate = Date.init(timeIntervalSince1970: 0)
        //
        //        datePicker.show("",
        //                        doneButtonTitle: "OK",
        //                        cancelButtonTitle: "Cancel",
        //                        minimumDate: mindate,
        //                        maximumDate: currentDate,
        //                        datePickerMode: .date) { (date) in
        //            if let dt = date {
        //                let curinfo = UserManager.manager.currentUser
        //                curinfo?.additionalInfo?.birthday = Int(dt.timeIntervalSince1970) * 1000
        //                UserManager.manager.saveUserInfo(curinfo)
        //                self.viewModel.input.updateAction.accept({}())
        //            }
        //        }
        //        let  birthdayPic = BirthdayPickerView.loadNibView()
        //        birthdayPic?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 350)
        //        //不要设置最大最小时间限制 系统控件会少8小时 导致天数少
        //        let dateNow = Date.init(timeIntervalSinceNow:24*60*60)
        //        birthdayPic?.compeletedSelectedDate = {[] (date) in
        //            if date > Date.init(timeIntervalSince1970: 0) && date <  dateNow {
        //                self.updateBirth(date.timeIntervalSince1970 * 1000 )
        //            }else{
        //                self.toastTip("Birthday should limited by 1970 ~ Now".localiz())
        //            }
        //        }
        //        birthdayPic?.showOnWindow(direction: .up)
        //        let dateNow = Date.init(timeIntervalSinceNow:24*60*60)
        //        let pickerView = BRDatePickerView.init()
        //        pickerView.pickerMode = .YMD
        //        pickerView.minDate = Date.init(timeIntervalSince1970: 0)
        //        pickerView.maxDate = Date.init(timeIntervalSinceNow: 0)
        //        pickerView.isAutoSelect = false
        //        pickerView.keyView = self.view
        //        pickerView.resultBlock = {
        //            [weak self] (resultdate,selectValue) in
        //            guard let `self` = self ,let date = resultdate else {return }
        //            if date > Date.init(timeIntervalSince1970: 0) && date <  dateNow {
        //                self.updateBirth(date.timeIntervalSince1970 * 1000 )
        //            }else{
        //                self.toastTip("Birthday should limited by 1970 ~ Now".localiz())
        //            }
        //        }
        //        let style = BRPickerStyle.init()
        //        style.pickerColor = UIColor.white
        //        style.selectRowTextColor = themeBarColor
        //        style.doneTextColor  = UIColor.black
        //        style.cancelBtnTitle = ""
        //        style.doneBtnTitle = "OK".localiz()
        //        style.pickerTextColor =  UIColor.gray
        //        style.hiddenTitleLine = true
        //        style.language = LanguageManager.shared.currentLanguage.rawValue
        //        pickerView.pickerStyle = style
        //        pickerView.show()
        let dateNow = Date.init(timeIntervalSinceNow:24*60*60)
        self.view.showDatePicker(selectDate: self.viewModel.output.selectDate.value) { (date) in
//            if date > Date.init(timeIntervalSince1970: 0) && date <  dateNow {
                self.updateBirth((date.timeIntervalSince1970 ) * 1000 )
//            }else{
//                self.toastTip("Birthday should limited by 1970 ~ Now".localiz())
//            }
        }
    }
    
    func updateBirth(_ timeval:TimeInterval)  {
        MBProgressHUD.showStatusInfo("editing...".localiz())
        UserProVider.init().editUser( birthday: (timeval < 0) ? 0:timeval, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                self.viewModel.input.updateAction.accept({}())
            },onError: { (err) in
                self.viewModel.input.updateAction.accept({}())
            }).disposed(by: self.rx.disposeBag)
        
    }
}
