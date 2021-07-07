//
//  Notivm.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
enum NotifycationType:Int,ConvertibleEnum {
    case   system = 1,
           focus = 2,
           like = 3,
           greetingwithme = 4,
           agreemygreeting = 5
}

enum NotifyItem {
    
    case notifyItem(_ result:UserNotifyModelResult) //我打招呼的列表
}

struct UserNotifyListSection {
    var items:[NotifyItem]
    var header:String = ""
}
extension  UserNotifyListSection:SectionModelType{
    typealias Item = NotifyItem
    init(original: UserNotifyListSection, items: [NotifyItem]) {
        self = original
        self.items = items
    }
}

class UserNotifyVModel:NSObject,RTViewModelType {
    let disposebag = DisposeBag()
    typealias Input = UserNotifyInterfaceInput
    
    typealias Output = UserNotifyInterfaceOutput
    
    var input: UserNotifyInterfaceInput
    var output: UserNotifyInterfaceOutput
    struct UserNotifyInterfaceInput {
        let typesselected:BehaviorRelay<[NotifycationType]> = BehaviorRelay.init(value: [])
        let requestCommand:PublishSubject<Int64?>
        let requestfootCommand:PublishSubject<Int64?>
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 10)
    }
    
    struct UserNotifyInterfaceOutput:OutputRefreshProtocol {
        var itemNotifyDatas:BehaviorRelay<[UserNotifyListSection]> = BehaviorRelay.init(value: [])
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: .idleNone)
        var dataSource:RxTableViewSectionedReloadDataSource<UserNotifyListSection>?=nil
        var emptyDataShow:BehaviorSubject<Bool> = BehaviorSubject<Bool>.init(value: false)
    }
    
    override init() {
        let requestCommand = PublishSubject<Int64?>.init()
        let requestfootCommand = PublishSubject<Int64?>.init()
        self.input = UserNotifyInterfaceInput.init(requestCommand: requestCommand, requestfootCommand: requestfootCommand)
        self.output = UserNotifyInterfaceOutput()
        super.init()
        let datasource = RxTableViewSectionedReloadDataSource<UserNotifyListSection>.init { (datasource, tableview, indexpath, item) -> UITableViewCell in
            switch datasource[indexpath] {
            case .notifyItem(let item):
                switch item.notificationType  {
                case .focus,.like:
                    let cell:NoticeMetionCell = tableview.dequeueReusableCell(for: indexpath, cellType: NoticeMetionCell.self)
                    cell.updateInfo(item)
                    cell.actionFocusBlock = {[weak self]
                        (userid , isfocus )in
                        guard let `self` = self  else {return }
                        self.focusUser(userid: userid,isfocus:isfocus)
                        
                    }
                    return cell
                    
                case .system:
                    let cell:SystemNoticeCell = tableview.dequeueReusableCell(for: indexpath, cellType: SystemNoticeCell.self)
                    cell.updateInfo(item)
                    return cell
                default:
                    return UITableViewCell.init()
                }
                
            }
            return UITableViewCell.init()
            
        }
        
        self.output.dataSource = datasource
        self.input.requestCommand.asObservable().subscribe(onNext: { [weak self] userid
            in
            
            guard let `self` = self  else {return }
            self.input.pagenumber.accept(1)
            self.refreshAlldata(userid: userid)
            
            
        }).disposed(by: disposebag)
        
        self.input.requestfootCommand.asObservable().subscribe(onNext: {  [weak self]  userid
            in
            guard let `self` = self  else {return }
            self.loadMore(userid: userid)
            
        }).disposed(by: disposebag)
        
        
        
        
    }
    
    func focusUser(userid:Int64,isfocus:Bool)  {
        //        UserProVider.init().userFocus(userid, self.disposebag)
        //            .subscribe(onNext: { [weak self] (res) in
        //                guard let `self` = self  else {return }
        //
        //                switch res {
        //                case .success(let info):
        //                    self.refreshAlldata(userid: nil) //刷自己的不带
        //                    break
        //                case .failed(let err):
        //                    UIViewController.getCurrentViewController()?.toastTip("Follow failed".localiz())
        //                }
        //
        //            }).disposed(by: self.disposebag)
        UserProVider.focusUser(isfocus, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
            guard let `self` = self  else {return }
            self.refreshAlldata(userid: nil) //刷自己的不带
        }
        
    }
}


extension  UserNotifyVModel {
    
    func refreshAlldata(userid:Int64?)  {
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        let  inputtypes = self.input.typesselected.value
        var mata = [UserNotifyListSection]()
        guard let userid = userid else {
            UserProVider.init().userNotifycationList(pageNum:pagenumber, pageSize: pagesize, types: inputtypes,  self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let results = res.modelArrType(UserNotifyModelResult.self) {
                    let  items = results.map { (result) -> NotifyItem in
                                           return .notifyItem(result)
                                       }
                                       if items.count > 0  {
                                           let greetingitem = UserNotifyListSection.init(items:items)
                                           mata.append(greetingitem)
                                       }
                                       self.output.itemNotifyDatas.accept(mata)
                                       self.output.emptyDataShow.onNext(items.count == 0)
                                       self.output.refreshStatus.accept(.endHeaderRefresh)
                }
//                switch res {
//                case .success(let result):
//                    guard let results = result else {
//                        self.output.refreshStatus.accept(.endHeaderRefresh)
//
//                        return
//                    }
//
//                    let  items = results.map { (result) -> NotifyItem in
//                        return .notifyItem(result)
//                    }
//                    if items.count > 0  {
//                        let greetingitem = UserNotifyListSection.init(items:items)
//                        mata.append(greetingitem)
//                    }
//                    self.output.itemNotifyDatas.accept(mata)
//                    self.output.emptyDataShow.onNext(items.count == 0)
//                    self.output.refreshStatus.accept(.endHeaderRefresh)
//                    break
//                case .failed(let err):
//                    self.output.refreshStatus.accept(.endHeaderRefresh)
//                    self.output.emptyDataShow.onNext(true)
//                    break
//                }
                
            },onError: { (err) in
                self.output.refreshStatus.accept(.endHeaderRefresh)
                self.output.emptyDataShow.onNext(true)
            }).disposed(by: self.disposebag)
            return
        }
        
        //别人的
        
        
    }
    
    func loadMore(userid:Int64?)  {
        var useritemdata =    self.output.itemNotifyDatas.value
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        let  inputtypes = self.input.typesselected.value
        let  morenumber = pagenumber + 1
        guard let userid = userid else {
            UserProVider.init().userNotifycationList(pageNum:morenumber, pageSize: pagesize, types: inputtypes,  self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let results = res.modelArrType(UserNotifyModelResult.self) {
                    let  items = results.map { (result) -> NotifyItem in
                                            return .notifyItem(result)
                                        }
                                        if items.count > 0  {
                                            let greetingitem = UserNotifyListSection.init(items:items)
                                            useritemdata.append(greetingitem)
                                            self.output.itemNotifyDatas.accept(useritemdata)
                                            self.output.refreshStatus.accept(.endFooterRefresh)
                                            self.input.pagenumber.accept(morenumber)
                                        }
                                        else{
                                            self.output.itemNotifyDatas.accept(useritemdata)
                                            self.output.refreshStatus.accept(.noMoreData)
                                        }
                }
//                switch res {
//                case .success(let result):
//                    guard let results = result else {
//                        self.output.refreshStatus.accept(.endFooterRefresh)
//                        return
//                    }
//
//                    let  items = results.map { (result) -> NotifyItem in
//                        return .notifyItem(result)
//                    }
//                    if items.count > 0  {
//                        let greetingitem = UserNotifyListSection.init(items:items)
//                        useritemdata.append(greetingitem)
//                        self.output.itemNotifyDatas.accept(useritemdata)
//                        self.output.refreshStatus.accept(.endFooterRefresh)
//                        self.input.pagenumber.accept(morenumber)
//                    }
//                    else{
//                        self.output.itemNotifyDatas.accept(useritemdata)
//                        self.output.refreshStatus.accept(.noMoreData)
//                    }
//
//
//                    break
//                case .failed(let err):
//                    self.output.refreshStatus.accept(.endFooterRefresh)
//                    break
//                }
                
            },onError: { (err) in
                self.output.refreshStatus.accept(.endFooterRefresh)
            }).disposed(by: self.disposebag)
            return
        }
        //        UserProVider.init().greetingOthers(morenumber, pageSize: pagesize, userId: userid, self.disposebag).subscribe(onNext: { [weak self] (res) in
        //            guard let `self` = self  else {return }
        //            switch res {
        //            case .success(let result):
        //                guard let results = result else {
        //                    self.output.refreshStatus.accept(.endFooterRefresh)
        //                    return
        //                }
        //
        //                let  items = results.map { (result) -> UserItem in
        //                    return .greetingUser(result)
        //                }
        //                if items.count > 0  {
        //                    let greetingitem = UserInfoListSection.init(items:items)
        //                    useritemdata.append(greetingitem)
        //                    self.output.useritemsdata.accept(useritemdata)
        //                    self.output.refreshStatus.accept(.endFooterRefresh)
        //                    self.input.pagesize.accept(morenumber)
        //                }
        //                else{
        //                    self.output.useritemsdata.accept(useritemdata)
        //                    self.output.refreshStatus.accept(.noMoreData)
        //                }
        //
        //
        //                break
        //            case .failed(let err):
        //
        //                self.output.refreshStatus.accept(.endFooterRefresh)
        //                break
        //            }
        //
        //        }).disposed(by: self.disposebag)
        
        
    }
    
    
    
    
    
}
