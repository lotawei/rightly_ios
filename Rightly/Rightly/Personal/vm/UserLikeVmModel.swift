//
//  UserLikeVmModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//


import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum GreetingLikeItem {
    case greetingUserLike(_ detail:GreetingResult) //我打招呼的列表
}

struct GreetingLikeItemListSection {
    var items:[GreetingLikeItem]
    var header:String = ""
}
extension  GreetingLikeItemListSection:SectionModelType{
    typealias Item = GreetingLikeItem
    init(original: GreetingLikeItemListSection, items: [GreetingLikeItem]) {
        self = original
        self.items = items
    }
}

class UserLikeVmModel:RTViewModelType, UserFocusDelegate {
    let disposebag = DisposeBag.init()
    typealias Input = UserLikeInput
    typealias Output = UserLikeOutput
    var input:Input
    var output:Output
    var  isempty:Bool = false
    struct UserLikeInput {
        var likeByUserId:BehaviorRelay<Int64?> = BehaviorRelay.init(value: nil)
        let requestCommand:PublishSubject<Void> = PublishSubject.init()
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 10)
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
    }
    
    struct UserLikeOutput:OutputRefreshProtocol {
        var resultData:BehaviorSubject<[GreetingLikeItemListSection]>
        var dataSource:RxTableViewSectionedReloadDataSource<GreetingLikeItemListSection>?=nil
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: .idleNone)
        var emptyDataShow:PublishSubject<Bool> = PublishSubject.init()
    }
    
    init(_ reultSubject:BehaviorSubject<[GreetingLikeItemListSection]>) {
        self.input = UserLikeInput.init()
        self.output = UserLikeOutput.init( resultData: reultSubject, dataSource: nil)
        let dataSource = RxTableViewSectionedReloadDataSource<GreetingLikeItemListSection>.init(configureCell: { (datasource, collectionview, indexpath, item) -> UITableViewCell in
            switch  datasource[indexpath] {
            case .greetingUserLike(let greetingdetail):
                let cell:GreetingLikeCell = collectionview.dequeueReusableCell(for: indexpath, cellType: GreetingLikeCell.self)
                let vmdata = GreetingResultVModel.init(greetingdetail)
                cell.bindVmData(vmdata)
                cell.delegate = self
                return cell
            }
        })
        
        self.output.dataSource  = dataSource
    }
    func foucusUser(_ userid: Int64,_ isfocus:Bool) {
        
        UserProVider.focusUser(isfocus, userid: userid, self.disposebag) {[weak self] (isfocus) in
            guard let `self` = self  else {return }
            self.refreshAlldata(userid: nil)
        }
        
    }
    
    
    func requestUserLikeList(_ userid:Int64? = nil){
        self.refreshAlldata(userid: userid)
    }
    fileprivate  func refreshAlldata(userid:Int64?)  {
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        
        var mata = [GreetingLikeItemListSection]()
        guard let userid = userid else {
            UserProVider.init().greetingLikeList(userid:nil,  pagenumber, pagesize, self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                self.output.refreshStatus.accept(.endHeaderRefresh)
                if let results = res.modelArrType(GreetingResult.self){
                    let  items = results.map { (result) -> GreetingLikeItem in
                        return .greetingUserLike(result)
                    }
                    if items.count > 0  {
                        let greetingitem = GreetingLikeItemListSection.init(items:items)
                        mata.append(greetingitem)
                    }
                    self.output.resultData.onNext(mata)
                    self.output.emptyDataShow.onNext(items.count == 0)
                    self.output.refreshStatus.accept(.endHeaderRefresh)
                }
                //                switch res {
                //                case .success(let result):
                //                    guard let results = result else {
                //                        self.output.refreshStatus.accept(.endHeaderRefresh)
                //                        return
                //                    }
                //
                //                    let  items = results.map { (result) -> GreetingLikeItem in
                //                        return .greetingUserLike(result)
                //                    }
                //                    if items.count > 0  {
                //                        let greetingitem = GreetingLikeItemListSection.init(items:items)
                //                        mata.append(greetingitem)
                //                    }
                //                    self.output.resultData.onNext(mata)
                //                    self.output.emptyDataShow.onNext(items.count == 0)
                //                    self.output.refreshStatus.accept(.endHeaderRefresh)
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
        UserProVider.init().greetingLikeList(userid:userid,pagenumber,pagesize, self.disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let results = res.modelArrType(GreetingResult.self){
                               let  items = results.map { (result) -> GreetingLikeItem in
                                   return .greetingUserLike(result)
                               }
                               if items.count > 0  {
                                   let greetingitem = GreetingLikeItemListSection.init(items:items)
                                   mata.append(greetingitem)
                               }
               
                               self.output.resultData.onNext(mata)
                               self.output.emptyDataShow.onNext(items.count == 0)
                               self.output.refreshStatus.accept(.endHeaderRefresh)
            }
//            switch res {
//            case .success(let result):
//                guard let results = result else {
//                    self.output.refreshStatus.accept(.endHeaderRefresh)
//                    return
//                }
//
//                let  items = results.map { (result) -> GreetingLikeItem in
//                    return .greetingUserLike(result)
//                }
//                if items.count > 0  {
//                    let greetingitem = GreetingLikeItemListSection.init(items:items)
//                    mata.append(greetingitem)
//                }
//
//                self.output.resultData.onNext(mata)
//                self.output.emptyDataShow.onNext(items.count == 0)
//                self.output.refreshStatus.accept(.endHeaderRefresh)
//                break
//            case .failed(let err):
//                self.output.refreshStatus.accept(.endHeaderRefresh)
//                break
//            }
            
        }).disposed(by: self.disposebag)
        
        
        
    }
    
    func loadMore(userid:Int64?)  {
        var useritemdata =   try! self.output.resultData.value()
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        let  morenumber = pagenumber + 1
        guard let userid = userid else {
            UserProVider.init().greetingLikeList(userid: nil,morenumber,pagesize, self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let results = res.modelArrType(GreetingResult.self) {
                    let  items = results.map { (result) -> GreetingLikeItem in
                                            return .greetingUserLike(result)
                                        }
                                        if items.count > 0  {
                                            let greetingitem = GreetingLikeItemListSection.init(items:items)
                                            useritemdata.append(greetingitem)
                                            self.output.resultData.onNext(useritemdata)
                                            self.output.refreshStatus.accept(.endFooterRefresh)
                                            self.input.pagenumber.accept(morenumber)
                                        }
                                        else{
                                            self.output.resultData.onNext(useritemdata)
                                            self.output.refreshStatus.accept(.noMoreData)
                                        }
                }
//                switch res {
//                case .success(let result):
//                    guard let results = result else {
//                        self.output.refreshStatus.accept(.endFooterRefresh)
//                        return
//                    }
//                    let  items = results.map { (result) -> GreetingLikeItem in
//                        return .greetingUserLike(result)
//                    }
//                    if items.count > 0  {
//                        let greetingitem = GreetingLikeItemListSection.init(items:items)
//                        useritemdata.append(greetingitem)
//                        self.output.resultData.onNext(useritemdata)
//                        self.output.refreshStatus.accept(.endFooterRefresh)
//                        self.input.pagenumber.accept(morenumber)
//                    }
//                    else{
//                        self.output.resultData.onNext(useritemdata)
//                        self.output.refreshStatus.accept(.noMoreData)
//                    }
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
        UserProVider.init().greetingLikeList(userid:userid,morenumber,pagesize, self.disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.output.refreshStatus.accept(.endFooterRefresh)
            if let results = res.modelArrType(GreetingResult.self) {
                let  items = results.map { (result) -> GreetingLikeItem in
                                  return .greetingUserLike(result)
                              }
                              if items.count > 0  {
                                  let greetingitem = GreetingLikeItemListSection.init(items:items)
                                  useritemdata.append(greetingitem)
                                  self.output.resultData.onNext(useritemdata)
                                  self.output.refreshStatus.accept(.endFooterRefresh)
                                  self.input.pagenumber.accept(morenumber)
                              }
                              else{
                                  self.output.resultData.onNext(useritemdata)
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
//                let  items = results.map { (result) -> GreetingLikeItem in
//                    return .greetingUserLike(result)
//                }
//                if items.count > 0  {
//                    let greetingitem = GreetingLikeItemListSection.init(items:items)
//                    useritemdata.append(greetingitem)
//                    self.output.resultData.onNext(useritemdata)
//                    self.output.refreshStatus.accept(.endFooterRefresh)
//                    self.input.pagenumber.accept(morenumber)
//                }
//                else{
//                    self.output.resultData.onNext(useritemdata)
//                    self.output.refreshStatus.accept(.noMoreData)
//                }
//                break
//            case .failed(let err):
//                self.output.refreshStatus.accept(.endFooterRefresh)
//                break
//            }
            
        },onError: { (err) in
            self.output.refreshStatus.accept(.endFooterRefresh)
        }).disposed(by: self.disposebag)
    }
}
