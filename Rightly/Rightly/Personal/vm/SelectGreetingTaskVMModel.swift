//
//  SelectGreetingTaskVMModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/1.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


class SelectGreetingTaskVMModel:RTViewModelType {
    let disposebag = DisposeBag()
    typealias Input = SelectGreetingInput
    
    typealias Output = SelectGreetingOutPut
    
    var input: SelectGreetingInput
    var output: SelectGreetingOutPut
    var isempty:Bool = false
    struct SelectGreetingInput {
        /// 请求用户task的命令
        let requestUserTaskCommand:BehaviorRelay<Int64?> = BehaviorRelay.init(value: nil)
        // 下拉刷新的action userid tasktype去请求
        let requestCommand:PublishSubject<(Int64?,TaskType?)>
        let requestfootCommand:PublishSubject<(Int64?,TaskType?)>
        
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 10)
    }
    
    struct SelectGreetingOutPut:OutputRefreshProtocol {
        var useritemsdata:BehaviorRelay<[UserInfoListSection]> = BehaviorRelay.init(value: [])
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: .idleNone)
        var   emptyDataShow:PublishSubject<Bool> = PublishSubject.init()
    }
    
    init() {
        let requestCommand = PublishSubject<(Int64?,TaskType?)>.init()
        let requestfootCommand = PublishSubject<(Int64?,TaskType?)>.init()
        self.input = SelectGreetingInput.init(requestCommand: requestCommand, requestfootCommand: requestfootCommand)
        self.output = SelectGreetingOutPut()
        self.input.requestCommand.asObservable().subscribe(onNext: { [weak self] itemusr in
            guard let `self` = self  else {return }
            self.input.pagenumber.accept(1)
            self.refreshAlldata(userid: itemusr.0,tasktype: itemusr.1)
        }).disposed(by: disposebag)
        
        self.input.requestfootCommand.asObservable().subscribe(onNext: {  [weak self] itemusr in
            guard let `self` = self  else {return }
            self.loadMore(userid: itemusr.0,tasktype:itemusr.1)
        }).disposed(by: disposebag)
    }
}


extension  SelectGreetingTaskVMModel {
    func refreshAlldata(userid:Int64?,tasktype:TaskType?)  {
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        var mata = [UserInfoListSection]()
        guard let userid = userid else {
            MatchTaskGreetingProvider.init().greetingOwer(pagenumber, pageSize: pagesize, taskType: tasktype?.rawValue, disposebag: self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let results = res.modelArrType(GreetingResult.self)
                {
                    let  items = results.map { (result) -> UserItem in
                        return .greetingUser(result)
                    }
                    if items.count > 0  {
                        let greetingitem = UserInfoListSection.init(items:items)
                        mata.append(greetingitem)
                    }
                    
                    
                    self.output.useritemsdata.accept(mata)
                    self.output.refreshStatus.accept(.endHeaderRefresh)
                    self.output.emptyDataShow.onNext(items.count == 0)
                }
                //                switch res {
                //                case .success(let result):
                //                    guard let results = result else {
                //                        self.output.refreshStatus.accept(.endHeaderRefresh)
                //                        return
                //                    }
                //
                //                    let  items = results.map { (result) -> UserItem in
                //                        return .greetingUser(result)
                //                    }
                //                    if items.count > 0  {
                //                        let greetingitem = UserInfoListSection.init(items:items)
                //                        mata.append(greetingitem)
                //                    }
                //
                //
                //                    self.output.useritemsdata.accept(mata)
                //                    self.output.refreshStatus.accept(.endHeaderRefresh)
                //                    self.output.emptyDataShow.onNext(items.count == 0)
                //                    break
                //                case .failed(let err):
                //                    self.output.refreshStatus.accept(.endHeaderRefresh)
                //                    break
                //                }
                
            },onError: { (err) in
                self.output.refreshStatus.accept(.endHeaderRefresh)
            }).disposed(by: self.disposebag)
            return
        }
        MatchTaskGreetingProvider.init().greetingOthers(pagenumber, pageSize: pagesize,taskType: tasktype?.rawValue,userId: userid, self.disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.output.refreshStatus.accept(.endHeaderRefresh)
            if let results = res.modelArrType(GreetingResult.self)
            {
                let  items = results.map { (result) -> UserItem in
                    return .greetingUser(result)
                }
                if items.count > 0  {
                    let greetingitem = UserInfoListSection.init(items:items)
                    mata.append(greetingitem)
                }
                
                self.isempty = items.count == 0
                self.output.useritemsdata.accept(mata)
                self.output.refreshStatus.accept(.endHeaderRefresh)
            }
            //            switch res {
            //            case .success(let result):
            //                guard let results = result else {
            //                    self.output.refreshStatus.accept(.endHeaderRefresh)
            //                    return
            //                }
            //
            //                let  items = results.map { (result) -> UserItem in
            //                    return .greetingUser(result)
            //                }
            //                if items.count > 0  {
            //                    let greetingitem = UserInfoListSection.init(items:items)
            //                    mata.append(greetingitem)
            //                }
            //
            //                self.isempty = items.count == 0
            //                self.output.useritemsdata.accept(mata)
            //                self.output.refreshStatus.accept(.endHeaderRefresh)
            //                break
            //            case .failed(let err):
            //                self.output.refreshStatus.accept(.endHeaderRefresh)
            //                break
            //            }
            
        },onError: { (err) in
            self.output.refreshStatus.accept(.endHeaderRefresh)
        }).disposed(by: self.disposebag)
        
        
        
    }
    
    func loadMore(userid:Int64?,tasktype:TaskType?)  {
        var useritemdata =    self.output.useritemsdata.value
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        let  morenumber = pagenumber + 1
        guard let userid = userid else {
            MatchTaskGreetingProvider.init().greetingOwer(morenumber, pageSize: pagesize,taskType: tasktype?.rawValue, disposebag: self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let  results = res.modelArrType(GreetingResult.self) {
                    let  items = results.map { (result) -> UserItem in
                        return .greetingUser(result)
                    }
                    if items.count > 0  {
                        let greetingitem = UserInfoListSection.init(items:items)
                        useritemdata.append(greetingitem)
                        self.output.useritemsdata.accept(useritemdata)
                        self.output.refreshStatus.accept(.endFooterRefresh)
                        self.input.pagesize.accept(morenumber)
                    }
                    else{
                        self.output.useritemsdata.accept(useritemdata)
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
                //                    let  items = results.map { (result) -> UserItem in
                //                        return .greetingUser(result)
                //                    }
                //                    if items.count > 0  {
                //                        let greetingitem = UserInfoListSection.init(items:items)
                //                        useritemdata.append(greetingitem)
                //                        self.output.useritemsdata.accept(useritemdata)
                //                        self.output.refreshStatus.accept(.endFooterRefresh)
                //                        self.input.pagesize.accept(morenumber)
                //                    }
                //                    else{
                //                        self.output.useritemsdata.accept(useritemdata)
                //                        self.output.refreshStatus.accept(.noMoreData)
                //                    }
                //
                //
                //                    break
                //                case .failed(let err):
                //
                //                    self.output.refreshStatus.accept(.endFooterRefresh)
                //                    break
                //                }
                
            },onError: { (err) in
                self.output.refreshStatus.accept(.endFooterRefresh)
            }).disposed(by: self.disposebag)
            return
        }
        MatchTaskGreetingProvider.init().greetingOthers(morenumber, pageSize: pagesize, taskType: tasktype?.rawValue,userId: userid, self.disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let results = res.modelArrType(GreetingResult.self){
                let  items = results.map { (result) -> UserItem in
                    return .greetingUser(result)
                }
                if items.count > 0  {
                    let greetingitem = UserInfoListSection.init(items:items)
                    useritemdata.append(greetingitem)
                    self.output.useritemsdata.accept(useritemdata)
                    self.output.refreshStatus.accept(.endFooterRefresh)
                    self.input.pagesize.accept(morenumber)
                }
                else{
                    self.output.useritemsdata.accept(useritemdata)
                    self.output.refreshStatus.accept(.noMoreData)
                }
            }
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
            
        },onError: { (err) in
            self.output.refreshStatus.accept(.endFooterRefresh)
        }).disposed(by: self.disposebag)
        
        
    }
    
    
    
    
    
}
