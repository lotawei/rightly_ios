//
//  AppDelegate.swift
//  Rightly
//
//  Created by qichen jiang on 2021/2/25.
//

import UIKit
import IQKeyboardManagerSwift
import NIMSDK
import KTVHTTPCache
import RxSwift
@_exported import MBProgressHUD
@_exported import KakaJSON
import AppTrackingTransparency
import AdSupport
import ZLPhotoBrowser
//#if DEBUG
//import FLEX
////    import MLeaksFinder
//#endif
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
    var window: UIWindow?
    var isForceLandscape:Bool = false
    var isForcePortrait:Bool = false
    var isForceAllDerictions:Bool = false //支持所有方向
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//                UserDefaults.standard.set(nil, forKey:guideConfigKeys) //测试 只要掉了这个就先重置用于反复测试  //引导中如有版本区别可能需要单独处理逻辑
//                UserDefaults.standard.synchronize()
//        UserManager.manager.cleanUser()
        LanguageManager.shared.defaultLanguage = .zhHans //默认设置语言设置
        ZLPhotoConfiguration.default().languageType = LanguageManager.shared.currentLanguage == Languages.en ? ZLLanguageType.english:ZLLanguageType.chineseSimplified
        _ = SystemManager.shared //获取下系统域名等信息更新
        #if DEBUG
//        FLEXManager.shared.showExplorer()
        #endif
        GlobalRouter.shared.registerAppUrl() //路由注册
        initApplicationModule(application: application, didFinishLaunchingWithOptions: launchOptions)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        AppDelegate.reloadRootVC()
//        AppDelegate.jumpEMptyVc()
        return true
    }
    
    func initApplicationModule(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        //各种三方信息初始化
        ThirdPartManager.shareInstance.register(withOption: launchOptions, type: .gaode, apiKey:ThirdPartRegisterKey.gaokeApiKey.rawValue)
        ThirdPartManager.shareInstance.register(withOption: launchOptions, type: .bugly, apiKey:ThirdPartRegisterKey.buglyKey.rawValue)
        ThirdPartManager.shareInstance.register(withOption: launchOptions, type: .nim, apiKey:ThirdPartRegisterKey.yunXinKey.rawValue)
        ThirdPartManager.shareInstance.register(withOption: launchOptions, type: .umeng, apiKey:ThirdPartRegisterKey.uMengKey.rawValue)
        ThirdPartManager.shareInstance.register(withOption: launchOptions, type: .jiguang, apiKey:ThirdPartRegisterKey.jiGuangKey.rawValue)
        if #available(iOS 11.0.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        /// 设置推送
        UNUserNotificationCenter.current().delegate = self
        let authOptions:UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            if !granted {
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        /// 设置键盘
        IQKeyboardManager.shared.enable = true  //控制整个功能是否启用
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true  //控制点击背景是否收起键盘
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true //控制键盘上的工具条文字颜色是否用户自定义
        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews   //有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
        IQKeyboardManager.shared.enableAutoToolbar = false  //控制是否显示键盘上的工具条
        IQKeyboardManager.shared.placeholderFont = .boldSystemFont(ofSize: 18)  //设置占位文字的字体
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 8  //输入框距离键盘的距离
//        //设置音/视频缓存框架
        try? KTVHTTPCache.proxyStart()
    }
}

extension AppDelegate {
    // FIXME: UIApplicationDelegate
    func application( _ app:UIApplication, open url:URL, options: [UIApplication.OpenURLOptionsKey :Any] = [:] ) -> Bool {
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        debugPrint("程序将要进入前台")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint("程序进入前台")
        UserManager.manager.keepUserActivity()  //保持活跃链接
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        debugPrint("程序将要进入后台，例如 来电话 推送")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("程序正式进入后台")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("杀掉程序调用")
    }
    
    ///获取设备唯一标识
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         currrentdeviceToken = deviceToken
         updateDeviceToken()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("=====")
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if RELEASE
            UIViewController.current()?.toastTip("\(error)") //注册失败
        #endif
    }
    
    //返回当前界面支持的旋转方向
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?)-> UIInterfaceOrientationMask {
        if isForceAllDerictions == true {
            return .allButUpsideDown
        } else if isForceLandscape == true {
            return .landscape
        } else if isForcePortrait == true {
            return .portrait
        }
        return .portrait
    }
}

extension AppDelegate {
    static let disposebag = DisposeBag.init()
    static func reloadRootVC() {
        let currUserInfo = UserManager.manager.currentUser
        if currUserInfo == nil {
            self.jumpLogin()
            return
        }
        guard let userId = currUserInfo?.additionalInfo?.userId else {
            self.jumpLogin()
            return
        }
        
        let userIdStr = String(userId)
        UserManager.manager.loginNim()
        FriendsDBManager.shared().configRealm(userIdStr)
        PushNoticeCenterManager.shared = PushNoticeCenterManager.init(userIdStr)
        if !(currUserInfo?.additionalInfo?.isEdit ?? false) {
            self.jumpInputUserInfo()
            return
        }
        if !(currUserInfo?.additionalInfo?.isCreateTask ?? false) {
            self.jumpCreateHotVc()
            return
        }
        if !(currUserInfo?.additionalInfo?.isEditBgUrl ?? false) {
            self.jumpPersonalInputBgVc()
            return
        }
        JPUSHService.setAlias(userIdStr, completion: { code, alias, seq in
            Provider.rx.request(.request(body:["platform":1, "token":userIdStr],path:"users/bindDevice",methodType: .post, urlparams: nil)).filterSuccessfulStatusCodes().subscribe { (response) in
                debugPrint("绑定设备成功")
            } onError: { (err) in
                
            }.disposed(by: disposebag)
        }, seq: 1024)
        self.jumpRootTabbar()
    }
    
    static func jumpRootTabbar(){
        let tabBarCtrl = RightlyTabBarViewController()
        keyWindow?.rootViewController = tabBarCtrl
        keyWindow?.makeKeyAndVisible()
    }
    
    static func jumpLogin() {
        let startViewCtrl = LoginLoadChannelManager.loadByChannelLoginVC()
        keyWindow?.rootViewController = RTNavgationViewController.init(rootViewController: startViewCtrl)
        keyWindow?.makeKeyAndVisible()
    }
    
    static func jumpPersonalInputBgVc(){
        let rootvc = PersonalInputBgViewController.loadFromNib()
        rootvc.firstCompleReload = true
        keyWindow?.rootViewController = RTNavgationViewController.init(rootViewController: rootvc)
        keyWindow?.makeKeyAndVisible()
    }
    static func jumpCreateHotVc(){
        let rootvc = GuideCreateHotTaskViewController()
        rootvc.isFirstLoad = true
        rootvc.fd_prefersNavigationBarHidden = true
        keyWindow?.rootViewController = RTNavgationViewController.init(rootViewController: rootvc)
        keyWindow?.makeKeyAndVisible()
    }
    
    static func jumpInputUserInfo(){
        let signinputV: SignInputInfoViewController = SignInputInfoViewController.loadFromNib()
        signinputV.shouldSet = true
        keyWindow?.rootViewController = RTNavgationViewController.init(rootViewController: signinputV)
        keyWindow?.makeKeyAndVisible()
    }
    
    static func  jumpEMptyVc(){
        let emptyVc: MatchLocationSelectViewController = MatchLocationSelectViewController.loadFromNib()
        keyWindow?.rootViewController = RTNavgationViewController.init(rootViewController: emptyVc)
        keyWindow?.makeKeyAndVisible()
    }
}


class OrientationToolManager : NSObject {
    // 强制旋转横屏
    static func forceOrientationLandscape() {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isForceLandscape = true
        appdelegate.isForcePortrait = false
        _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor: UIViewController.getCurrentViewController()?.view.window)
        let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    // 强制旋转竖屏
    static func forceOrientationPortrait() {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isForceLandscape = false
        appdelegate.isForcePortrait = true
        _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor:UIViewController.getCurrentViewController()?.view.window)
        let oriention = UIInterfaceOrientation.portrait // 设置屏幕为竖屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    // 允许所有
    static func forceOrientationAll() {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isForceLandscape = false
        appdelegate.isForcePortrait = false
        appdelegate.isForceAllDerictions = true
        _ = appdelegate.application(UIApplication.shared, supportedInterfaceOrientationsFor:UIViewController.getCurrentViewController()?.view.window)
        let oriention = UIInterfaceOrientationMask.all
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

extension  AppDelegate {
    /// 处理推送结果
    /// - Parameters:
    ///   - info: 具体信息
    ///   - withjump:  是否跳转  如果不是则仅仅显示个数 是就直接到该有的界面
    static func  dealWithRemoteHandlePushInfo(_ info:[AnyHashable : Any],_ withjump:Bool = false){
        if (info["nim"] as? String) != nil {
            selectTabbarMessage(withjump)
            if let  userid = info["userId"] as? String, let sessionId = info["sessionid"] as? String ,let sessiontype = info["sessiontype"] as? String{
                if withjump {
                    jumpChatMessage(userid, sessionId, NIMSessionType.init(rawValue: Int(sessiontype) ?? 0) ?? .P2P)
                }
            }
            return
        }
        noticeCenter(withjump) //处理系统消息
    }
    
    /// 系统消息收到
    /// - Parameter withjump:是否跳转  不是的话只显示红点
    static func noticeCenter(_ withjump:Bool)  {
        guard let tabbarvc =  UIViewController.getCurrentViewController()?.tabBarController as? RightlyTabBarViewController else { return }
//        tabbarvc.itemsbtn.last?.showViewBadgOn()
        let oldCount =  UserRedDotRecordManager.shared.systemPageUnreadCount.value
        UserRedDotRecordManager.shared.systemPageUnreadCount.accept(oldCount + 1)
        if withjump {
            UIViewController.getCurrentViewController()?.navigationController?.pushViewController(PersonalCenterViewController.init(), animated: true)
        }
    }
    
    /// 否则往  消息跳转
    /// - Parameter withjump:是否跳转  不是的话只显示红点
    static func selectTabbarMessage(_ withjump:Bool) {
        guard let tabbarvc =  UIViewController.getCurrentViewController()?.tabBarController as? RightlyTabBarViewController else {return }
        if tabbarvc.itemsbtn.count > 3 {
            tabbarvc.itemsbtn[3].showViewBadgOn()
            if withjump {
                tabbarvc.selectedIndex = 3
            }
        }
       
    }
    
    static func jumpChatMessage(_ userid:String, _ sessionid:String ,_ sessionytype:NIMSessionType = .P2P){
        let session:NIMSession = NIMSession.init(sessionid, type: sessionytype)
        let nextViewCtrl = SessionInfoViewController.init(session: session, userId: userid)
        UIViewController.getCurrentViewController()?.navigationController?.pushViewController(nextViewCtrl, animated: true)
    }
    /// 移除小红点
    static func removeRedBagBar(index:Int) {
        guard let tabbarvc =  UIViewController.getCurrentViewController()?.tabBarController as? RightlyTabBarViewController else { return }
        if tabbarvc.itemsbtn.count > index {
            tabbarvc.itemsbtn[index].hideViewBadg()
        }
    }
}


extension  AppDelegate {
    func updateDeviceToken(){
        guard let deviceData = currrentdeviceToken else {
            return
        }
        JPUSHService.registerDeviceToken(deviceData)
        NIMSDK.shared().updateApnsToken(deviceData)
        
    }
    static func enableIMRegisterNotify(_ enable:Bool,userid:String)  {
         
    }
}
