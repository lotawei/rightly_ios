//
//  UserInfoViewModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/16.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

/// 用户信息
enum UserItem {
    case greetingUser(_ task:GreetingResult) //我打招呼的列表
    case emptyShow(_ isower:Bool , data:Any? = nil) //空列表展示
    case unlockMore  //他人没有解锁的要加个
}

struct UserInfoListSection {
    var items:[UserItem]
    var header:String = ""
}

extension  UserInfoListSection:SectionModelType{
    typealias Item = UserItem
    init(original: UserInfoListSection, items: [UserItem]) {
        self = original
        self.items = items
    }
}

enum GreetingUserState:Int {
    case  isFriend = 0, // 是好
          isTaskUnLock = 1, //已做任务
          shouldDoTask = 2 ,//该去回复他做任务
          owerEditor = 3
}

enum HeaderRefreshState:Int {
    case normal = 0,
         refreshing = 1,
         complete = 2
}

class UserInfoViewModel:RTViewModelType {
    let disposebag = DisposeBag()
    typealias Input = UserInterfaceInput
    typealias Output = UserInterfaceOutput
    var isInsertUserItem:Bool = false
    var input: UserInterfaceInput
    var output: UserInterfaceOutput
    var userid:Int64?=nil
    var requestedGreetingList = false
    struct UserInterfaceInput {
        //        let requestUserTaskCommand:BehaviorRelay<Int64?> = BehaviorRelay.init(value: nil)
        let requestCommand:PublishSubject<Int64?>
        let requestfootCommand:PublishSubject<Int64?>
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 3)
        let outsideDisplayTask:BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
        //只局部刷新tag的
        let  refreshTags:PublishSubject<Int64?> = PublishSubject.init()
    }
    
    struct UserInterfaceOutput:OutputRefreshProtocol {
        var useritemsdata:BehaviorRelay<[UserInfoListSection]> = BehaviorRelay.init(value: [])
        var refreshStatus:BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: RTRefreshStatus.idleNone)
        var tags:BehaviorRelay<[ItemTag]> = BehaviorRelay<[ItemTag]>(value: [])
        var emptyShowView:BehaviorRelay<Bool>  = BehaviorRelay<Bool>.init(value: false) //是否是自己的 是否显示
        var detailUser:PublishSubject<UserAdditionalInfo> = PublishSubject.init()
        var greetingState:BehaviorRelay<GreetingUserState> = BehaviorRelay.init(value:GreetingUserState.owerEditor )
        var taskInfo:PublishSubject<TaskInfo?> = PublishSubject.init()
        var refreshHeader:BehaviorRelay<HeaderRefreshState> = BehaviorRelay<HeaderRefreshState>(value: .normal)
    }
    
    init() {
        let requestCommand = PublishSubject<Int64?>.init()
        let requestfootCommand = PublishSubject<Int64?>.init()
        self.input = UserInterfaceInput.init(requestCommand: requestCommand, requestfootCommand: requestfootCommand)
        self.output = UserInterfaceOutput()
        self.input.requestCommand.asObservable().subscribe(onNext: { [weak self] userid in
            guard let `self` = self  else {return }
            self.refreshInfo(userid: self.userid)
        }).disposed(by: disposebag)
        
        self.input.requestfootCommand.asObservable().subscribe(onNext: { [weak self]  userid in
            guard let `self` = self  else {return }
            self.loadMore(userid: userid)
        }).disposed(by: disposebag)
        
        /// 专门刷新的tags
        self.input.refreshTags.asObserver().subscribe(onNext: { [weak self] (userid) in
            guard let `self` = self  else {return }
            self.refreshUserTags(userid)
        }).disposed(by: self.disposebag)
        
    }
    
    fileprivate func resizeGreetingData(_ res:ReqArrResult, originalData:[UserInfoListSection],loadMore:Bool) -> [UserInfoListSection] {
        var  resizeDatas = originalData
        if let  greetings = res.modelArrType(GreetingResult.self)  {
            let items = greetings.map { (greeting) -> UserItem in
                return UserItem.greetingUser(greeting)
            }
            if items.count > 0 {
                let greetingitem = UserInfoListSection.init(items:items)
                resizeDatas.append(greetingitem)
                if self.showAddTipLock() {
                    let sectionunlocksection = UserInfoListSection.init(items: [.unlockMore])
                    resizeDatas.append(sectionunlocksection)
                }
            } else if !loadMore {
                let isower = UserManager.isOwnerMySelf(self.userid)
                let setionEmpty = UserInfoListSection.init(items: [.emptyShow(isower, data:nil)])
                resizeDatas.append(setionEmpty)
            }
        }
        //        switch res {
        //        case .success(let results):
        //            if let greetings = results {
        //                var items = greetings.map { (greeting) -> UserItem in
        //                    return UserItem.greetingUser(greeting)
        //                }
        //                if items.count > 0 {
        //                    let greetingitem = UserInfoListSection.init(items:items)
        //                    resizeDatas.append(greetingitem)
        //                    if self.showAddTipLock() {
        //                        let sectionunlocksection = UserInfoListSection.init(items: [.unlockMore])
        //                        resizeDatas.append(sectionunlocksection)
        //                    }
        //                } else if !loadMore {
        //                    let isower = UserManager.isOwnerMySelf(self.userid)
        //                    let setionEmpty = UserInfoListSection.init(items: [.emptyShow(isower, data:nil)])
        //                    resizeDatas.append(setionEmpty)
        //                }
        //            }
        //        case .failed(_):
        //            break
        //        }
        return resizeDatas
    }
    fileprivate func refreshUserTags(_ userid:Int64?){
        self.createTags(userid).subscribe(onNext: { [weak self] (tags) in
            guard let `self` = self  else {return }
            self.output.tags.accept(tags)
        }).disposed(by: self.disposebag)
    }
    
    func requestGreeting(_ userid:Int64?) {
        let pagesize = self.input.pagesize.value
        let pagenumber  = self.input.pagenumber.value
        let greetingThird = Observable<ReqArrResult>.create { (observer3) -> Disposable in
            if let userid = userid {
                MatchTaskGreetingProvider.init().greetingOthers(pagenumber, pageSize: pagesize,userId: userid, self.disposebag).subscribe(onNext: { (res) in
                    observer3.onNext(res)
                    observer3.onCompleted()
                }).disposed(by: self.disposebag)
            } else {
                MatchTaskGreetingProvider.init().greetingOwer(pagenumber, pageSize: pagesize, disposebag: self.disposebag).subscribe(onNext: { (res) in
                    observer3.onNext(res)
                    observer3.onCompleted()
                }).disposed(by: self.disposebag)
            }
            return Disposables.create()
        }
    }
    
    /// 根据用户状态更新招呼状态
    /// - Parameter auser:  获取的用户详情
    fileprivate func greetingStateUpdate(_ auser: UserAdditionalInfo) {
        if  !UserManager.isOwnerMySelf(userid){
            let  isfriend = auser.isFriend ?? false
            let  istaskUnlock = auser.isUnlock ?? false
            var greetingState  = GreetingUserState.shouldDoTask
            if isfriend {
                greetingState = .isFriend
            }
            else{
                if istaskUnlock {
                    greetingState = .isTaskUnLock
                }
            }
            self.output.greetingState.accept(greetingState)
        }
    }
    
    // 请求用户标签
    fileprivate func createTags(_ userid: Int64?) -> Observable<[ItemTag]> {
        return Observable<[ItemTag]>.create { (observer) -> Disposable in
            let userProvider = UserProVider.init()
            var requestOb:Observable<ReqResult>
            if let userid = userid {
                requestOb = userProvider.otherTagList(userid, self.disposebag)
            } else {
                requestOb = userProvider.myTagList(self.disposebag)
            }
            
            requestOb.subscribe(onNext: { (resultData) in
                var tags = [ItemTag]()
                if let datas = resultData.data as? [[String: Any]] {
                    for tempData in datas {
                        let tempModel = tempData.kj.model(ItemTag.self)
                        tags.append(tempModel)
                    }
                }
                observer.onNext(tags)
                observer.onCompleted()
            }, onError: { (error) in
                observer.onError(error)
            }).disposed(by: self.disposebag)
            return Disposables.create()
        }
    }
    
    // 请求用户任务
    fileprivate func createTakeInfo(_ userid: Int64?) -> Observable<TaskInfo> {
        return Observable<TaskInfo>.create { (observer) -> Disposable in
            let taskProvider = MatchTaskGreetingProvider.init()
            var requestOb:Observable<ReqResult>
            if let userId = userid {
                requestOb = taskProvider.requestOtherTask(userId, self.disposebag)
            } else {
                requestOb = taskProvider.requestMyTask(self.disposebag)
            }
            
            requestOb.subscribe(onNext: { (resultData) in
                guard let dataDic = resultData.data as? [String:Any] else {
                    observer.onError(NSError.init(domain: "转换错误", code: -1, userInfo: nil))
                    return
                }
                
                let taskInfo = dataDic.kj.model(TaskInfo.self)
                observer.onNext(taskInfo)
                observer.onCompleted()
            }, onError: { (error) in
                observer.onError(error)
            }).disposed(by: self.disposebag)
            return Disposables.create()
        }
    }
    
    // 请求用户信息
    fileprivate func createUserInfo(_ userid: Int64?) -> Observable<UserAdditionalInfo> {
        return Observable<UserAdditionalInfo>.create { (observer) -> Disposable in
            let userProvider = UserProVider.init()
            var requestOb:Observable<ReqResult>
            if let userId = userid {
                requestOb = userProvider.requestOtherUserInfo(userId, self.disposebag)
            } else {
                requestOb = userProvider.requestMyUserInfo(self.disposebag)
            }
            
            requestOb.subscribe(onNext: { (resultData) in
                guard let dataDic = resultData.data as? [String:Any] else {
                    observer.onError(NSError.init(domain: "转换错误", code: -1, userInfo: nil))
                    return
                }
                
                let tempUserInfo = dataDic.kj.model(UserAdditionalInfo.self)
                if UserManager.isOwnerMySelf(tempUserInfo.userId) {
                    let saveuser = UserManager.manager.currentUser
                    saveuser?.additionalInfo?.nickname = tempUserInfo.nickname
                    saveuser?.additionalInfo?.age = tempUserInfo.age
                    saveuser?.additionalInfo?.gender = tempUserInfo.gender
                    saveuser?.additionalInfo?.address = tempUserInfo.address
                    saveuser?.additionalInfo?.avatar = tempUserInfo.avatar
                    saveuser?.additionalInfo?.backgroundUrl = tempUserInfo.backgroundUrl
                    saveuser?.additionalInfo?.age = tempUserInfo.age
                    saveuser?.additionalInfo?.bgViewType = tempUserInfo.bgViewType
                    UserManager.manager.saveUserInfo(saveuser)
                }
                
                observer.onNext(tempUserInfo)
                observer.onCompleted()
            }, onError: { (error) in
                observer.onError(error)
            }).disposed(by: self.disposebag)
            return Disposables.create()
        }
    }
    
    func refreshInfo(userid:Int64? ) {
        if self.output.refreshHeader.value != .normal {
            return
        }
        
        self.output.refreshHeader.accept(.refreshing)
        self.userid = userid
        self.input.pagenumber.accept(1)
        
        let userInfoOb = self.createUserInfo(userid)
        let taskInfoOb = self.createTakeInfo(userid)
        let tagListOb = createTags(userid)
        
        ///压缩信号统一发送
        let observableConcat = Observable.zip(userInfoOb, taskInfoOb, tagListOb)
        observableConcat.subscribe(onNext: { [weak self] (userInfo, taskInfo, tags) in
            guard let `self` = self  else {return }
            /// userInfo
            self.output.detailUser.onNext(userInfo)
            
            ///taskInfo
            self.output.taskInfo.onNext(taskInfo)
            
            ///tags
            self.output.tags.accept(tags)
            
            self.output.refreshHeader.accept(.complete)
            self.output.emptyShowView.accept(false)
        }, onError: { [weak self] (error) in
            guard let `self` = self else {return}
            self.output.refreshHeader.accept(.complete)
        }).disposed(by: self.disposebag)
    }
    
    /// 是否显示lock的提示
    /// - Returns: <#description#>
    func showAddTipLock() -> Bool {
        if self.output.greetingState.value == .owerEditor {
            return false
        }
        else if self.output.greetingState.value == .shouldDoTask{
            return true
        }
        else{
            return false
        }
    }
}

extension  UserInfoViewModel {
    func loadMore(userid:Int64?)  {
        let pagesize = self.input.pagesize.value
        let pagenumber  = self.input.pagenumber.value
        if self.output.useritemsdata.value.count == 0 {return} //防止没有数据的时候有蠢货先拖加载更多
        //只要不是好友
        if  self.showAddTipLock() {
            self.output.refreshStatus.accept(.endFooterRefresh)
            return
        }
        let morenumber = pagenumber + 1
        if let userid = userid {
            MatchTaskGreetingProvider.init().greetingOthers(morenumber, pageSize: pagesize, userId: userid, self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                self.makeGreetingRes(res, pageNum: morenumber, loadMore: true)
            }).disposed(by: self.disposebag)
        } else {
            MatchTaskGreetingProvider.init().greetingOwer(morenumber, pageSize: pagesize, disposebag: self.disposebag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                self.makeGreetingRes(res, pageNum: morenumber, loadMore: true)
            }).disposed(by: self.disposebag)
        }
    }
    
    func makeGreetingRes(_ result:ReqArrResult, pageNum:Int, loadMore:Bool) {
        var refreshStatus:RTRefreshStatus = .endFooterRefresh
        //        switch result {
        //        case .success(let results):
        //            if let greetings = results {
        //                if greetings.count > 0 {
        //                    self.input.pagenumber.accept(pageNum)
        //                }
        //
        //                if greetings.count < self.input.pagesize.value {
        //                    refreshStatus = .noMoreData
        //                }
        //            }
        //        case .failed(_):
        //            break
        //        }
        let resultCount  = result.arrData?.count ?? 0
        if  resultCount > 0 {
            self.input.pagenumber.accept(pageNum)
        }
        if  resultCount < self.input.pagesize.value {
            refreshStatus = .noMoreData
        }
        
        
        if pageNum == 1 {
            self.output.useritemsdata.accept([UserInfoListSection]())
        }
        
        let userItemDatas = self.resizeGreetingData(result, originalData: self.output.useritemsdata.value,loadMore: loadMore)
        self.output.useritemsdata.accept(userItemDatas)
        self.output.refreshStatus.accept(refreshStatus)
    }
}


