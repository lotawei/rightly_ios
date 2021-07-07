import Foundation
import  RxSwift
import Moya
import RxCocoa
import NIMSDK


/// 用户相关网络请求
class UserProVider:NetworkRequest{
    
    /// 第三方登录
    /// - Parameters:
    ///   - type: 0/1/2/3 mock/谷歌/facebook/apple
    ///   - token: <#token description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func thirdPartLogin(_ type:Int,token:String,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body:["type":type,"token":token],path:"users/thirdParty/login",methodType: .post, disposebag: disposebag,nil)
    }
    /// 绑定
    func thirdPartBind(_ type:Int,token:String,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return  self.createRequestObserver(body: ["type":type,"token":token], path: "users/thirdParty/bind", methodType: .post, disposebag: disposebag)
    }
    
    /// 个人信息  详情 切勿
    func detailUser(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        let req = self.createRequestObserver(path: "users/me", methodType: .get, disposebag: disposebag)
        req.subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let dicData = res.data as? [String:Any] {
                var  userinforesult:UserAdditionalInfo  = dicData.kj.model(UserAdditionalInfo.self)
                let  saveuser = UserManager.manager.currentUser
                saveuser?.additionalInfo?.nickname = userinforesult.nickname
                saveuser?.additionalInfo?.age = userinforesult.age
                saveuser?.additionalInfo?.gender = userinforesult.gender
                saveuser?.additionalInfo?.address = userinforesult.address
                saveuser?.additionalInfo?.avatar = userinforesult.avatar
                saveuser?.additionalInfo?.backgroundUrl = userinforesult.backgroundUrl
                saveuser?.additionalInfo?.age = userinforesult.age
                saveuser?.additionalInfo?.bgViewType = userinforesult.bgViewType
                UserManager.manager.saveUserInfo(saveuser)
                //勿全部覆盖 有些数据不一致 只要原因是登录返回的用户和详情返回的数据不通的  如登录的那 三个任务是否设置 用户是否编辑过 是否上传过头像 的状态 在详情里是拿不到的
            }
        }).disposed(by: disposebag)
        
        return req
    }
    
    
    /// 用户编辑
    /// - Parameters:
    ///   - nickname: 用户昵称
    ///   - gender: 用户性别
    ///   - birthday: 用户生日
    ///   - bio: 用户简介
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func editUser( nickname:String? = nil,  gender:Int? = nil,  birthday:TimeInterval? = nil, bio:String? = nil ,avatar:String? = nil, address:String? = nil,lng:Double? = nil , lat:Double? = nil ,backgroundUrl:String? = nil,bgViewType:ViewType? = nil,_ disposebag:DisposeBag) -> Observable<ReqStrResult> {
        var  additionalInfo = [String:Any]()
        if let nickname = nickname {
            additionalInfo["nickname"] = nickname
        }
        if let gender = gender {
            additionalInfo["gender"] = gender
        }
        if let birthday = birthday {
            additionalInfo["birthday"] = birthday
        }
        if let bio = bio {
            additionalInfo["bio"] = bio
        }
        if let avatar = avatar {
            additionalInfo["avatar"] = avatar
        }
        if let address = address {
            additionalInfo["address"] = address
        }
        if let lng = lng {
            additionalInfo["lng"] = lng
        }
        if let lat = lat {
            additionalInfo["lat"] = lat
            
        }
        if let vtype  = bgViewType {
            additionalInfo["bgViewType"] = vtype.rawValue
        }else{
            additionalInfo["bgViewType"] = UserManager.manager.currentUser?.additionalInfo?.bgViewType?.rawValue ?? ViewType.Public.rawValue
        }
        if let backgroundUrl = backgroundUrl {
            additionalInfo["backgroundUrl"] = backgroundUrl
        }
        let req =  self.reqDataStrObserver(body: additionalInfo, path: "users/me/edit", methodType: .put, disposeBag: disposebag)
        req.subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            //请求详情的数据和登录的结果不一致 有些信息和登录返回的不完全一致
            if  var info = UserManager.manager.currentUser?.additionalInfo?.kj.JSONObject()  {
                let  saveuser = UserManager.manager.currentUser
                info["isEdit"] = true
                if info["backgroundUrl"] != nil {
                    info["isEditBgUrl"]  = true
                }
                saveuser?.additionalInfo = Rightly.UserAdditionalInfo.modelWithDictionary(info)
                UserManager.manager.saveUserInfo(saveuser)
            }
        }).disposed(by: disposebag)
        return req
        
    }
    /// 其它用户信息
    /// - Parameters:
    ///   - userId: userid
    ///   - disposebag: <#disposebag description#>
    /// - Returns: description
    func userAdditionalInfo(_ userId:String,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        if UserManager.isOwnerMySelf(Int64(userId)) {
            return self.requestMyUserInfo(disposebag)
        }
        return requestOtherUserInfo(Int64(userId) ?? 0,disposebag)
    }
    
    func requestMyUserInfo(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "users/me", methodType: .get, disposebag: disposebag, nil)
    }
    
    func requestOtherUserInfo(_ userId:Int64, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body:["userId":userId],path:"users/info", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 黑名单
    func blackListUser(_ userId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["userId":userId], path: "users/block", methodType:.post ,disposebag: disposebag)
    }
    /// 举报用户
    func reportTarget(_ targetType:Int, targetId:Int64, _ reportType:Int, content:String? = nil,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        var  body = [String:Any]()
        body["targetType"] = targetType
        body["reportType"] = reportType
        body["targetId"] = targetId
        body["content"] = content ?? ""
        return self.createRequestObserver(body: body, path: "users/report", methodType: .post, disposebag: disposebag)
    }
    
    
    /// 搜索用户
    /// - Parameters:
    ///   - nickname: 昵称
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func searchUser(_ nickname:String,pageNum:Int = 1, pageSize:Int = 10 ,_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        let  bodydic:[String:Any] = ["nickname":nickname,"pageNum":pageNum,"pageSize":pageSize]
        return self.reqDataArrayObserver(body: bodydic, path: "users/search", methodType: .get, disposeBag: disposebag, nil)
        
    }
    
    
    ///未读站内消息
    
    /// - Parameter disposebag:
    /// - Returns:
    func userUnreadNum(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver( path: "users/notification/unreadNum", methodType: .get, disposebag: disposebag)
    }
    
    
    /// 获取通知列表
    /// - Parameters:
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - type: 消息类型 1/2/3/4 评论/@/like/系统
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func userNotificationList(_ pageNum:Int = 1 ,_ pageSize:Int = 10,type:Int ,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        
        let body:[String:Any] = ["pageNum":pageNum,"pageSize":pageSize,"type":type]
        return self.createRequestObserver(body: body, path: "users/notification/list", methodType: .get, disposebag: disposebag)
    }
    
    
    
    
    /// 谁看了我
    /// - Parameters:
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func userSeeMeList(_ pageNum:Int,_ pageSize:Int,_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        return self.reqDataArrayObserver(path: "users/viewMe/list", methodType: .get, disposeBag: disposebag)
    }
    //系统相关 -----------------------------------------------------------------------------------------------
    
    /// 获取用户头像筛选列表
    /// - Parameter disposebag:
    /// - Returns:
    func systemChooseAvatarInfos(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "system/baseData/avatar", methodType: .get, disposebag: disposebag, nil)
    }
    /// 获取系统默认域名等
    /// - Parameter disposebag:
    /// - Returns:
    func systemProperty(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver( path: "system/property", methodType: .get, disposebag: disposebag, nil)
    }
    
}


extension UserProVider {
    
    /// 和别人打招呼 其实就是做了任务
    /// - Parameters:
    ///   - releaseData:
    ///   - disposebag:
    /// - Returns:
    func greetingAdd(releaseData:UserReleaseVmModel.InputData,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        var  dicres = [String:Any]()
        
        if  let releaseaddress  = releaseData.address {
            dicres["address"] = releaseaddress
        }
        if  let taskId  = releaseData.taskId {
            dicres["taskId"] = taskId
        }
        if  let toUserId  = releaseData.toUserId {
            dicres["toUserId"] = toUserId
        }
        if  let type  = releaseData.type {
            dicres["type"] = type.rawValue
        }
        if  let taskType  = releaseData.taskType {
            dicres["taskType"] = taskType
        }
        if  let tagIds = releaseData.tagids ,tagIds.count > 0{
            dicres["tagIds"] = tagIds
        }
        if  let viewType  = releaseData.viewType {
            dicres["viewType"] = viewType.rawValue
        }
        if  let topicIds = releaseData.topicIds, topicIds.count > 0 {
            dicres["topicIds"] = topicIds
        }
        if  let resourceList  = releaseData.resourcelists {
            var   dics = [[String:Any]]()
            
            for list in resourceList {
                if let  dicva = list.kj.JSONObject()  as? [String:Any]{
                    dics.append(dicva)
                }
            }
            dicres["resourceList"] = dics
            
        }
        if  let lng  = releaseData.lng {
            dicres["lng"] = lng
        }
        if  let lat  = releaseData.lat {
            dicres["lat"] = lat
        }
        if  let content  = releaseData.content {
            dicres["content"] = content
        }
        return self.createRequestObserver(body: dicres, path: "greeting/add", methodType: .post, disposebag: disposebag)
    }
    
    /// 和别人打招呼 其实就是做了任务  "type": 1,//打招呼入口，1/2/3 打招呼/额度不够是可以做任务获取额度/点亮标签
    /// - Parameters:
    ///   - releaseData:
    ///   - disposebag:
    /// - Returns:
    func greetingForUser(type:ReleaseType,newtempResult:GreetingResult,touserId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        var dicres = [String:Any]()
        if let releaseaddress = newtempResult.address {
            dicres["address"] = releaseaddress
        }
        if let taskId = newtempResult.taskId {
            dicres["taskId"] = taskId
        }
        
        dicres["toUserId"] = touserId
        dicres["type"] = type.rawValue
        if  let tasktype  = newtempResult.task?.type {
            dicres["taskType"] = tasktype.rawValue
        }
        if  let viewType  = newtempResult.viewType {
            dicres["viewType"] = viewType.rawValue
        }
        
        dicres["language"] = LanguageManager.shared.currentLanguage.rawValue
        
        if  let resourceList  = newtempResult.resourceList {
            var   dics = [[String:Any]]()
            
            for list in resourceList {
                if let  dicva = list.kj.JSONObject()  as? [String:Any]{
                    dics.append(dicva)
                }
            }
            dicres["resourceList"] = dics
            
        }
        if  let lng  = newtempResult.lng {
            dicres["lng"] = lng
        }
        if  let lat  = newtempResult.lat {
            dicres["lat"] = lat
        }
        if  let content  = newtempResult.content {
            dicres["content"] = content
        }
        return self.createRequestObserver(body: dicres, path: "greeting/add", methodType: .post, disposebag: disposebag)
    }
    
    ///
    /// - Parameters:
    ///   - followtype:
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func userFollowers(userid:Int64? = nil,pageNum:Int? = 1, pageSize:Int? = 10,  sortBy:String? = nil, desc:Bool? = false,followtype:FollowType, disposebag:DisposeBag) -> Observable<ReqResult> {
        var  body = [String:Any]()
        if let pageNum = pageNum {
            body["pageNum"]  = pageNum
        }
        if let pageSize = pageSize {
            body["pageSize"]  = pageSize
        }
        if let sortBy = sortBy {
            body["sortBy"]  = sortBy
        }
        if let desc = desc {
            body["desc"]  = desc
        }
        var path:String = ""
        switch followtype {
        case .following:
            if userid == nil {
                path = "users/follow"
            }else{
                path = "users/\(userid!)/follow"
            }
            
        case .fans:
            if userid == nil {
                path = "users/fans"
            }else{
                path = "users/\(userid!)/fans"
            }
        case .vistor:
            if userid == nil {
                path = "users/viewMe/list"
            }else{
                path = "users/\(userid!)/fans"
            }
            
            
        }
        return self.createRequestObserver(body: body, path: path, methodType: .get, disposebag: disposebag)
    }
    
    
    /// 关注别人 就是成为朋友
    /// - Parameters:
    ///   - userid:
    ///   - disposebag:
    /// - Returns:
    func userFocus(_ userid:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["userId":userid], path: "users/focus", methodType: .post, disposebag: disposebag)
    }
    
    
    /// 用户编辑
    /// - Parameters:
    ///   - nickname: 用户昵称
    ///   - gender: 用户性别
    ///   - birthday: 用户生日
    ///   - bio: 用户简介
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func userEditGreeting(greetingId:Int64,content:String? = nil,viewType:Int? = nil,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        var  body = [String:Any]()
        body["greetingId"] = greetingId
        if let content = content {
            body["content"] = content
        }
        if let viewType = viewType {
            body["viewType"] = viewType
        }
        return self.createRequestObserver(body: body, path: "greeting/edit", methodType: .put, disposebag: disposebag)
    }
    
    ///
    /// - Parameters:
    ///   - followtype:
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func greetingLikeList( userid:Int64? = nil,_ pageNum:Int? = 1,_ pageSize:Int? = 10, _ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        var  body = [String:Any]()
        if let pageNum = pageNum {
            body["pageNum"]  = pageNum
        }
        if let pageSize = pageSize {
            body["pageSize"]  = pageSize
        }
        if let userid = userid {
            body["userId"]  = userid
        }else{
            if let owerid =    UserManager.manager.currentUser?.additionalInfo?.userId {
                body["userId"]  = owerid
            }
        }
        var path:String = ""
        //暂时没用like只有自己的
        path = "greeting/like/list"
        return  self.reqDataArrayObserver(body: body, path: path, methodType: .get, disposeBag: disposebag)
    }
    
    func userNotifycationList( pageNum:Int? = 1,pageSize:Int? = 10,types:[NotifycationType],_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        let  typesselected = types.reduce("") { (id, value) -> String in
            if  value == types.first {
                return "\(value.rawValue)"
            }
            return "\(id),\(value.rawValue)"
        }
        var  body = [String:Any]()
        if let number = pageNum {
            body["pageNum"] = number
        }
        if let pageSize = pageSize {
            body["pageSize"] = pageSize
        }
        body["type"] = typesselected
        return self.reqDataArrayObserver(body: body, path: "users/notification/list", methodType: .get, disposeBag: disposebag)
    }
}




//扩展关注用户的全局功能
extension  UserProVider {
    static func focusUser(_ isfocus:Bool,userid:Int64 ,_ disposebag:DisposeBag, _ focusfinishResult:@escaping  ((_ isfocus:Bool)->Void)) {
        if UserManager.isOwnerMySelf(userid) {
            //是自己则不能关注自己
            UIViewController.getCurrentViewController()?.toastTip("I can't pay attention to myself".localiz())
            return
        }
        //已经是focus的则想取消关注
        if isfocus  {
            UIViewController.getCurrentViewController()?.alterUnfollowed({ sure in
                if  sure {
                    dealFocusUser(isfocus, userid: userid, disposebag, focusfinishResult)
                }
                else{
                    focusfinishResult(isfocus)
                }
            })
        }else{
            dealFocusUser(isfocus, userid: userid, disposebag, focusfinishResult)
        }
    }
    
    /// 是否关注
    /// - Parameters:
    ///   - isfocus: 需要传当前的关注状态
    ///   - userid:  用户id
    ///   - disposebag: <#disposebag description#>
    ///   - focusfinishResult: 返回关注的最新状态 与当前相反 成功的话
    static  func dealFocusUser(_ isfocus:Bool, userid:Int64,_ disposebag:DisposeBag, _ focusfinishResult:@escaping  ((_ isfocus:Bool)->Void))  {
        UserProVider.init().userFocus(userid, disposebag)
            .subscribe(onNext: { (res) in
                if isfocus {
                    UIViewController.getCurrentViewController()?.toastTip("Unfollow Success".localiz())
                }else{
                    UIViewController.getCurrentViewController()?.toastTip("Follow Success".localiz())
                }
                focusfinishResult(!isfocus)
            },onError: { (err) in
                UIViewController.getCurrentViewController()?.toastTip("Opreation failed".localiz())
            }).disposed(by: disposebag)
        
    }
    
}

//标签功能
extension  UserProVider {
    /// 获取我的标签
    func myTagList(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "tag/owner/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 获取其他用户的标签
    func otherTagList(_ userId:Int64, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body:["userId":userId], path: "tag/someone/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 获取分类标签
    /// - Parameters:
    ///   - userid: 用户id
    ///   - disposebag: <#disposebag description#>
    /// - Returns:
    func userCategoryList(_ disposebag:DisposeBag) -> Observable<ReqArrResult>{
        return self.reqDataArrayObserver(path: "tag/category/list", methodType: .get, disposeBag: disposebag)
    }
    
    /// 根据分类获取标签
    /// - Parameters:
    ///   - categoryId: 分类id
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func categorTagList(_ categoryId:Int64,_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        return self.reqDataArrayObserver(body:["categoryId":categoryId],path: "tag/list", methodType: .get, disposeBag: disposebag)
    }
    /// 公开标签
    /// - Parameters:
    ///   - disposebag:
    /// - Returns:
    func editViewTagType(_ publicList:[Int64],privateList:[Int64],_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["privateList":privateList,"publicList":publicList], path: "tag/editViewType", methodType: .post, disposebag: disposebag)
    }
    
    /// 编辑标签
    /// - Parameters:
    ///   - disposebag:
    /// - Returns:
    func editTag(_ addList:[Int64],removeList:[Int64],_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["addList":addList,"removeList":removeList], path: "tag/edit", methodType: .post, disposebag: disposebag)
    }
}
