//
//  UserFollowIngVMModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import KakaJSON
enum FollowType:Int {
    case following = 0, //关注的其它
         fans = 1, //自己的粉丝
         vistor = 2 // 浏览者
    
}
enum UserRelationType:Int, ConvertibleEnum {
    case relationnone = 0, //未关注
         focused = 1,//已关注
         doublefocused = 2 //互关
}

struct UserFollowDataInfo : Convertible {
    
    var pageNum : Int?  = nil
    var pageSize : Int? = nil
    var results : [UserFollowResult]? = nil
    var total : Int? = nil
    var totalPage : Int? = nil
}
struct UserFollowResult : Convertible {
    var createdAt : Int64?  = nil
    var isFriend : Bool? =  nil
    var user : UserFollowInfo? = nil
    var userId : Int64?  = nil
}
struct UserFollowInfo : Convertible {
    
    var code : String? = nil
    var focusAt : Int?  = nil
    var gender : Gender?  = nil
    var greeting : FollowGreeting?  = nil
    var nickname : String?  = nil
    var avatar:String?  = nil
    var relationType : UserRelationType?  = nil
    var userId : Int64?  = nil
}

extension UserFollowInfo {
    /// 好友与当前用户的关系
    var  isfocused:Bool {
        if let relaty = self.relationType {
            switch relaty {
            case .relationnone:
                return false
            default:
                return true
            }
        }
        return false
    }
}

struct FollowGreeting : Convertible {
    var content : String? = nil
    var createdAt : Int64? = nil
    var resourceList : [GreetingResourceList]? = nil
    var taskType : TaskType = .text
    var userId : Int64? = nil
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
        case createdAt = "createdAt"
        case resourceList = "resourceList"
        case taskType = "taskType"
        case userId = "userId"
    }
}
enum FollowItem {
    case followItem(_ followerItem:UserFollowResult)
}

struct FollowItemListSection {
    var items:[FollowItem]
    var header:String = ""
}

extension FollowItemListSection:SectionModelType{
    typealias Item = FollowItem
    init(original: FollowItemListSection, items: [FollowItem]) {
        self = original
        self.items = items
    }
}

class UserFollowingVMModel:RTViewModelType {
    let disposebag = DisposeBag()
    typealias Input = UserFollowingInput
    
    typealias Output = UserFollowingOutput
    var isempty:Bool = false
    var input:Input
    var output:Output
    struct UserFollowingInput {
        var followingType:BehaviorRelay<FollowType>
        let requestCommand:PublishSubject<Int64?> = PublishSubject.init()
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 10)
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
        
    }
    struct UserFollowingOutput:OutputRefreshProtocol{
        var displayTypeTitle:BehaviorRelay<String>  =  BehaviorRelay.init(value: "follow_btn")
        var dataSource:RxTableViewSectionedReloadDataSource<FollowItemListSection>
        var sampleDatas:BehaviorSubject<[FollowItemListSection]>
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: .idleNone)
    }
    
    init(_ smapleData:BehaviorSubject<[FollowItemListSection]>) {
        let followingType:BehaviorRelay<FollowType> = BehaviorRelay.init(value: .following)
        self.input = UserFollowingInput.init(followingType: followingType)
        let datasource = RxTableViewSectionedReloadDataSource<FollowItemListSection>.init { (datasource, tableview, indexpath, item) -> UITableViewCell in
            switch  datasource[indexpath] {
            case .followItem(let item):
                let cell:UserFollowCell = tableview.dequeueReusableCell(for: indexpath, cellType: UserFollowCell.self)
                cell.resultdata.accept(item)
                
                return cell
            }
            
            return UITableViewCell.init()
        }
        
        self.output = UserFollowingOutput.init(dataSource: datasource, sampleDatas: smapleData)
        
        followingType.subscribe(onNext: { [weak self](type) in
            guard let `self` = self  else {return }
            var t = ""
            switch type {
            case .following :
                t = "Following".localiz()
            case .fans:
                t = "Follower".localiz()
            case .vistor:
                t = "Visitor".localiz()
            }
            self.output.displayTypeTitle.accept(t)
        }).disposed(by: self.disposebag)
        
        self.input.requestCommand.asObservable().subscribe(onNext: {  [weak self]  userid in
            guard let `self` = self  else {return }
            self.refreshData(userid)
        }).disposed(by: disposebag)
    }
    
    func  refreshData(_ userid:Int64? = nil){
        self.input.pagesize.accept(10)
        self.input.pagenumber.accept(1)
        let page = self.input.pagenumber.value
        let pagesize = self.input.pagesize.value
        let followtype = self.input.followingType.value
        UserProVider.init().userFollowers(userid:userid,pageNum: page, pageSize: pagesize, sortBy: nil, desc: nil, followtype: followtype, disposebag: self.disposebag).subscribe(onNext: {[weak self] (results) in
            guard let `self` = self  else {return }
            self.output.refreshStatus.accept(.endHeaderRefresh)
            if let  res = results.modeDataKJTypeSelf(typeSelf:UserFollowDataInfo.self),let data = res.results{
                var  sections = [FollowItemListSection]()
                var  filterusers = data.filter { (result) -> Bool in
                    return result.user != nil
                }
                let items = filterusers.map({ (follow) -> FollowItem in
                    return  FollowItem.followItem(follow)
                })
                
                if items.count > 0 {
                    let  setion1 = FollowItemListSection.init(items:items)
                    sections.append(setion1)
                    self.isempty = false
                    self.output.sampleDatas.onNext(sections)
                    
                } else {
                    self.isempty = true
                    self.output.sampleDatas.onNext([])
                }
            }
            //            switch results {
            //            case .success(let res):
            //                self.output.refreshStatus.accept(.endHeaderRefresh)
            //                guard let data  = res else {
            //                    return
            //                }
            //                var  sections = [FollowItemListSection]()
            //                var  filterusers = data.filter { (result) -> Bool in
            //                    return result.user != nil
            //                }
            ////                var filterusers = data
            //                let items = filterusers.map({ (follow) -> FollowItem in
            //                    return  FollowItem.followItem(follow)
            //                })
            //
            //                if items.count > 0 {
            //                    let  setion1 = FollowItemListSection.init(items:items)
            //                    sections.append(setion1)
            //                    self.isempty = false
            //                    self.output.sampleDatas.onNext(sections)
            //
            //                } else {
            //                    self.isempty = true
            //                    self.output.sampleDatas.onNext([])
            //                }
            //            case .failed(_):
            //                self.output.sampleDatas.onNext([])
            //                self.output.refreshStatus.accept(.endHeaderRefresh)
            //            }
        }).disposed(by: self.disposebag)
    }
}
