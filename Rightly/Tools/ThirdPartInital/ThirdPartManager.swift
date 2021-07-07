//
//  ThirdPartManager.swift
//  podinstall
//
//  Created by lejing_lotawei on 2021/6/29.
//

import Foundation
import Bugly
import NIMSDK
class  ThirdPartManager:NSObject {
    static let shareInstance = ThirdPartManager()
    
    /// 注册第三方信息
    /// - Parameters:
    ///   - type:
    ///   - apiKey:
    ///   - secretKey:
    ///   - universalLink:
    func register(withOption:[UIApplication.LaunchOptionsKey: Any]?,type:ThirdPartEntry, apiKey:String,secretKey:String = "", universalLink:String = "",chanNel:String = ""){
        switch type {
        case .gaode:
            AMapServices.shared().enableHTTPS = true
            AMapServices.shared().apiKey = apiKey
            break
        case .baidu:
        
            break
        case .bugly:
            Bugly.start(withAppId:apiKey)
            
        case .jiguang:
            //极光推送
            let entity = JPUSHRegisterEntity.init()
            entity.types = Int(JPAuthorizationOptions.alert.rawValue|JPAuthorizationOptions.badge.rawValue|JPAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
            #if DEBUG
            JPUSHService.setup(withOption: withOption, appKey:apiKey, channel: "App Store", apsForProduction: false)
            #else
            JPUSHService.setup(withOption: withOption, appKey: apiKey, channel: "App Store", apsForProduction: true)
            #endif
            JPUSHService.setTags([appVersion], completion: { code, tags, seq in
            }, seq: 1025)
            
        case .umeng:
            UMConfigure.initWithAppkey(apiKey, channel: "App Store")
            break
        case .nim:
            //网易云信
            let option = NIMSDKOption.init(appKey: apiKey)
            #if DEBUG
            option.apnsCername = "APNS_Dev" //APNs证书名
            option.pkCername = "VOIP_Dev"  //pushKit证书名
            #else
            option.apnsCername = "APNS_Dis" //APNs证书名
            option.pkCername = "VOIP_Dev"  //pushKit证书名
            #endif
            NIMSDK.shared().register(with: option)
            NIMSDKConfig.shared().asyncLoadRecentSessionEnabled = true
            NIMSDKConfig.shared().animatedImageThumbnailEnabled = true
            NIMCustomObject.registerCustomDecoder(NIMAttachmentDecode.init())
        default:
            break
        }
    }
}



extension  ThirdPartManager:JPUSHRegisterDelegate {
    ///前台得到的推送
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        debugPrint("极光前台收到推送")
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
        AppDelegate.dealWithRemoteHandlePushInfo(userInfo,false)
//        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))    //放开表示前端也出现弹窗提示
    }
    
    ///用户点击推送
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        debugPrint("点击极光推送")
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        AppDelegate.dealWithRemoteHandlePushInfo(userInfo,true)
        completionHandler()
       
    }
    
    /// 获取用户IDFA权限
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
    }
}
