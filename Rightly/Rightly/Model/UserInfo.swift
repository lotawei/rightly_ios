//
//  UserInfo.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/12.
//

import Foundation
import NIMSDK
import KakaJSON
import RxSwift
enum ThirdPartAuthType:Int {
    case   mock = 0, //模拟
           goole = 1,//谷歌
           facebook = 2,//facebook
           apple = 3//苹果账号
}

class UserAdditionalInfo:Convertible {
    required init() {
    }
    var birthday : Int64? = nil //生日的部分页面的在用
    var userId : Int64? = nil
    var nickname : String? = nil
    var gender : Gender? = nil
    var createdAt : Int64? = nil
    var updatedAt : Int64? = nil
    var giftNum : Int? = nil //礼物个数
    var code : String? = nil
    var bio : String?  = nil//个人简介
    var avatar : String? = nil //头像
    var backgroundUrl : String? = nil//背景图
    var supportNum : Int? = nil
    var likeNum : Int? = nil //被喜欢数
    var fansNum : Int? = nil //粉丝
    var followNum : Int? = nil  //关注数
    var imAccId : String? //网易accid
    var relationType : UserRelationType? = nil //和我的关系   0/1/2 无关系/已关注/互关
    var isFriend : Bool? = nil //是否是好友
    var isBlock : Bool? = nil// 是否拉黑
    var address : String? = nil   //详细地址
    var lng : Double? = nil //经度
    var lat : Double? = nil //纬度
    var age : Int? = nil //年龄
    var viewMeNum : Int? = nil
    var language:String? = nil//语言信息
    var isEditBgUrl:Bool? = nil //背景图片
    var isEdit:Bool? = nil //是否编辑过用户
    var isCreateTask:Bool? = nil //是否创建过任务
    var isOnline:Bool? = nil //是否在线
    var bgViewType:ViewType?  = nil //是否公开头像
    var isUnlock:Bool? = nil //是否解锁任务
    
    static  func modelWithDictionary(_ dic:[String:Any]) -> UserAdditionalInfo? {
        let  addinfo:UserAdditionalInfo? = dic.kj.model(UserAdditionalInfo.self)
        return addinfo
    }
    
}
extension  UserAdditionalInfo {
    
    /// 地理位置展示
    /// - Parameter infoUserBuilder: <#infoUserBuilder description#>
    func parseUserAddress(_ infoUserBuilder:@escaping(_ display:String) -> Void)  {
        guard let la = lat,let lg = lng,la > 0 ,lg > 0 else {
            var prefix = ""
            if let gen = self.gender?.desGender.localiz(), !gen.isEmpty  {
                if prefix.isEmpty {
                    prefix = "\(gen)"
                } else{
                    prefix = prefix + "," + "\(gen)"
                }
            }
            
            if let ag = self.age,ag > 0 {
                if prefix.isEmpty {
                    prefix = "\(ag)"
                }else{
                    prefix = prefix + "," + "\(ag)"
                }
            }
            infoUserBuilder(prefix)
            return
        }
        
        LocationManager.init().reverseCityGeocode(la, lg,revesecityBlock:  {[weak self](city) in
            guard let `self` = self  else {return }
            var prefix = ""
            if !city.isEmpty {
                prefix  = "\(city)"
            }
            
            if let gen = self.gender?.desGender.localiz(), !gen.isEmpty  {
                if prefix.isEmpty {
                    prefix = "\(gen)"
                } else{
                    prefix = prefix + "," + "\(gen)"
                }
            }
            
            if let ag = self.age,ag > 0 {
                if prefix.isEmpty {
                    prefix = "\(ag)"
                }else{
                    prefix = prefix + "," + "\(ag)"
                }
            }
            infoUserBuilder(prefix)
            
        })
    }
}
extension UserAdditionalInfo {
    
    /// 好友与当前用户的关系 是关注
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
extension  UserAdditionalInfo {
    
    /// 通过计算的年龄 其实大部分用age
    var  caclurlatorage:Int? {
        if let  birth  = self.birthday{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "MM-dd-yyyy"
            if let date = dateFormatter.date(from: Date.formatTimeStamp(time: birth/1000, format: "MM-dd-yyyy")) {
                let age = Calendar.current.dateComponents([.year], from: date, to: Date()).year
                return age
            }
        }
        return 0
    }
    
    /// 生日的显示格式
    var birthdayDisplay:String{
        if let  birth  = self.birthday{
            let str = Date.formatTimeStamp(time: birth/1000, format: "MM-dd-yyyy")
            return str
        }
        return ""
    }
    /// 生日的显示格式
    var birthDayDate:Date?{
        if let  birth  = self.birthday{
            let date = Date.formatdateTimeStamp(time: birth/1000, format: "MM-dd-yyyy")
            return date
        }
        return nil
    }
}


class UserThirtyPartyInfo : Codable, Convertible {
    required init() {
        
    }
    var thirdpartInfo:[String:String]?
    
    
    enum CodingKeys: String, CodingKey {
        case thirdpartInfo = "thirdpartInfo"
    }
}

/// Im相关信息
class ImInfo : Convertible {
    var accId : String? = nil //accid
    var createdAt : Int64? = nil
    var token : String? = nil
    var updatedAt : Int64? = nil
    var userId : Int64? = nil
    required init(){
        
    }
}
fileprivate let localsaveUserKey = "localsaveUserKey"
fileprivate let  localsaveUserFirstKey = "localsaveUserFirstKey"
let  localsaveUserTaskCheck = "localsaveUserTaskCheck"
class UserInfo: Convertible {
    var accessToken : String?  = nil
    var additionalInfo : UserAdditionalInfo?  = nil
    var expiresIn : Int?  = nil
    var imInfo : ImInfo?  = nil
    var isFirst : Bool?  = nil
    var refreshToken : String?  = nil
    var scope : String?  = nil
    var thirtyPartyInfo : UserThirtyPartyInfo? = nil
    var tokenType : String? = nil
    var hasTask:Bool?  = nil
    required init(){
        
    }
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "accessToken":
            return "access_token"
        case "refreshToken":
            return "refresh_token"
        case "tokenType":
            return "token_type"
        default:
            return property.name
        }
    }
    func kj_JSONKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "accessToken":
            return "access_token"
        case "refreshToken":
            return "refresh_token"
        case "tokenType":
            return "token_type"
        default:
            return property.name
        }
    }
    
    
}

class UserManager: NSObject {
    static let manager:UserManager = UserManager()
    var keepTimer:Timer?
    
    
    var currentUser:UserInfo?
    override init() {
        super.init()
        self.currentUser = loadLocalUser()
    }
    /// 加载本地用户
    /// - Returns:
    fileprivate func loadLocalUser() -> UserInfo?{
        let  userDefault = UserDefaults.standard.object(forKey:localsaveUserKey)
        if let  userinfo = userDefault as? [String:Any]  {
            var  userInfo:UserInfo? = userinfo.kj.model(UserInfo.self)
            return userInfo
        }
        return nil
    }
    
    /// 是否与网易云信同步过了的
    /// - Parameter successBlock:
    public func loginNim(_ successBlock:((_ res:Bool)->Void)? = nil) {
        //确保 网易云信是注册了的 用于解决首次安装的问题 貌似无效  跟了流程首次安装拉取会话有问题
//        DispatchQueue.once {
//            (UIApplication.shared.delegate as? AppDelegate)?.initalIMOptional() //
//        }
        if NIMSDK.shared().loginManager.isLogined() {
            SessionManager.shared().loadAllSession()
            self.updateNIMUserInfo(3,successBlock: successBlock)
            return
        }
        
        SessionManager.shared().login { (error) in
            if error != nil {
                return
            }
            self.updateNIMUserInfo(3,successBlock: successBlock)
            
        }
    }
    
    /// 存储用户
    /// - Parameter info:
    func saveUserInfo(_ info:UserInfo?){
        var  userinfo:[String:Any]? = info?.kj.JSONObject()
        if info != nil {
            UserDefaults.standard.setValue(false, forKey:localsaveUserFirstKey )
        }
        UserDefaults.standard.setValue(userinfo, forKey: localsaveUserKey)
        UserDefaults.standard.synchronize()
        self.currentUser = loadLocalUser()
        if info != nil {
            if let userId = self.currentUser?.additionalInfo?.userId {
                let userIdStr = String(userId)
                self.loginNim() //登录网易云信
                FriendsDBManager.shared().configRealm(userIdStr)
                JPUSHService.setAlias(userIdStr, completion: { code, alias, seq in
                    Provider.rx.request(.request(body:["platform":1, "token":userIdStr],path:"users/bindDevice",methodType: .post, urlparams: nil)).filterSuccessfulStatusCodes().subscribe { (response) in
                        debugPrint("绑定设备成功")
                    } onError: { (err) in
                    }.disposed(by: self.rx.disposeBag)
                }, seq: 1024)
           
            }
        } else {
            SessionManager.shared().logout()    //网易云信退出登录
        }
    }
    
    // MARK: 更新网易云信用户信息
    func updateNIMUserInfo(_ retryCount:Int,successBlock:((_ res:Bool)->Void)? = nil) {
        if retryCount < 0 {
            debugPrint("更新网易云信用户数据失败")
            successBlock?(true)
            return
        }
        
        if self.currentUser == nil {
            debugPrint("更新网易云信用户数据失败,用户未登录")
            return
        }
        
        let nickName:String = self.currentUser?.additionalInfo?.nickname ?? ""
        let avatar:String = self.currentUser?.additionalInfo?.avatar ?? ""
        let birth:String = self.currentUser?.additionalInfo?.birthdayDisplay ?? ""
        let userExt:String = self.currentUser?.additionalInfo?.kj.JSONString() ?? ""
        
        var gender:NIMUserGender = NIMUserGender.unknown
        if self.currentUser?.additionalInfo?.gender == Gender.male {
            gender = NIMUserGender.male
        } else if self.currentUser?.additionalInfo?.gender == Gender.male {
            gender = NIMUserGender.female
        }
        
        let updateInfo:[NSNumber : Any] = [NSNumber.init(value: NIMUserInfoUpdateTag.nick.rawValue) : nickName,
                                           NSNumber.init(value: NIMUserInfoUpdateTag.avatar.rawValue) : avatar,
                                           NSNumber.init(value: NIMUserInfoUpdateTag.ext.rawValue) : userExt]
        
        NIMSDK.shared().userManager.updateMyUserInfo(updateInfo) { (error) in
            if error != nil {
                self.updateNIMUserInfo(retryCount - 1,successBlock: successBlock)
                return
            }else{
                successBlock?(true)
            }
        }
    }
    
    public func cleanUser() {
        saveUserInfo(nil)
        SessionManager.shared().logout()
        JPUSHService.deleteAlias({ code, alias, seq in
        }, seq: 1024)
    }
    
    
    /// 是否是自己  不传就是自己
    /// - Parameter otherId:
    /// - Returns: 
    static func  isOwnerMySelf(_ otherId:Int64?) -> Bool {
        if otherId == nil {
            return true
        }
        return  (manager.currentUser?.additionalInfo?.userId  == otherId)
    }
    
    
    func checkUserInfoInput(_ userinfo:UserInfo ,_ checkresult:@escaping((_ dismissInput:Bool)->Void))  {
        if userinfo.additionalInfo?.userId == nil {
            AppDelegate.jumpLogin()
            return
        }
        
        if let localgender = userinfo.additionalInfo?.gender {
            checkresult(localgender == Gender.none)
            return
        }
        
        let provider = UserProVider.init()
        provider.detailUser(self.rx.disposeBag).subscribe(onNext: { (res) in
            if let dicData = res.data as? [String:Any] {
                let  user = dicData.kj.model(UserAdditionalInfo.self)
                let gender = user.gender
                checkresult((gender == nil || gender == Gender.none))
            }
        },onError: { (err) in
            AppDelegate.jumpLogin()
        }).disposed(by: self.rx.disposeBag)
    }
    
    func keepUserActivity() {
        if self.keepTimer != nil {
            self.keepTimer?.invalidate()
            self.keepTimer = nil
        }
        
        self.keepTimer = Timer.scheduledTimer(withTimeInterval: 140, repeats: true, block: {[weak self] (timer) in
            guard let `self` = self else {return}
            if self.currentUser == nil {
                debugPrint("用户已退出登录 不再发送心跳包")
                return
            }
            
            Provider.rx.request(.request(path:"im/user/online",methodType: .post, urlparams: nil)).filterSuccessfulStatusCodes().subscribe { (response) in
                debugPrint("心跳包发送成功")
            } onError: { (err) in
                debugPrint("心跳包发送失败")
            }.disposed(by: self.rx.disposeBag)
        })
    }
}

extension  UserManager {
    
    /// 请求详情
    /// - Parameters:
    ///   - userid: usrid
    ///   - infoDetail:
    func  requestUserInfo(_ userid:Int64?, infoDetail:@escaping ((_ info:UserAdditionalInfo) -> Void)) {
        guard let userid = userid else {
            let userProvider = UserProVider.init()
            userProvider.detailUser(self.rx.disposeBag).subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (userdetail) in
                guard let `self` = self else {return }
                if let dicData = userdetail.data as? [String:Any] {
                    infoDetail(dicData.kj.model(UserAdditionalInfo.self))
                }
            },onError: { (err) in
                UIViewController.getCurrentViewController()?.toastTip("Network failed")
            })
            .disposed(by: self.rx.disposeBag)
            return
        }
        UserProVider.init().userAdditionalInfo("\(userid)",self.rx.disposeBag).subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (userdetail) in
            guard let `self` = self  else {return }
            if let dicData = userdetail.data as? [String:Any] {
                infoDetail(dicData.kj.model(UserAdditionalInfo.self))
            }
        },onError: { (err) in
            UIViewController.getCurrentViewController()?.toastTip("Network failed")
        }).disposed(by: self.rx.disposeBag)
    }
    
    
    /// 请求用户任务
    /// - Parameters:
    ///   - userid: userid
    ///   - taskBriefresult: 
    func requestUserTaskInfo(_ userid:Int64?, taskBriefresult:@escaping ((_ task:TaskInfo) -> Void)){
        if UserManager.isOwnerMySelf(userid) {
            MatchTaskGreetingProvider.init().gainUserTask(self.rx.disposeBag)
                .subscribe(onNext: { [weak self] (res) in
                    guard let `self` = self  else {return }
                    if  let  task = res.modeDataKJTypeSelf(typeSelf: TaskInfo.self) {
                        taskBriefresult(task)
                    }
                },onError: { (err) in
                    UIViewController.current()?.toastTip("Network failed".localiz())
                }).disposed(by: self.rx.disposeBag)
            return
        }
        if let uid  = userid{
            //查看别人的
            MatchTaskGreetingProvider.init().gainOtherTask(userid!,self.rx.disposeBag)
                .subscribe(onNext: { [weak self] (res) in
                    guard let `self` = self  else {return }
                    if  let  task = res.modeDataKJTypeSelf(typeSelf: TaskInfo.self) {
                        taskBriefresult(task)
                    }
                },onError: { (err) in
                    UIViewController.current()?.toastTip("Network failed".localiz())
                }).disposed(by: self.rx.disposeBag)
        }
    }
}
