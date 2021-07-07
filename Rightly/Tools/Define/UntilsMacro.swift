//
//  UntilsMacro.swift
//  Rightly
//
//  Created by qichen jiang on 2021/2/25.
//

import Foundation
import UIKit
let replacePlaceHolderCharacter = "%#T#%"
let releaseOutSideChannel:Bool = false
var     currrentdeviceToken:Data?=nil
let screenWidth:CGFloat = UIScreen.main.bounds.size.width
let screenHeight:CGFloat = UIScreen.main.bounds.size.height
let safeBottomH:CGFloat = isIphoneX ? 34.0 : 0
let statusBarH:CGFloat = isIphoneX ? 44.0 : 20.0
let navBarH:CGFloat = isIphoneX ? 88.0 : 64.0
let tabBarH:CGFloat = isIphoneX ? 83.0 : 49.0
var keyWindow = UIApplication.shared.keyWindow
//应用程序信息
let infoDictionary = Bundle.main.infoDictionary!
let appDisplayName: String = infoDictionary["CFBundleDisplayName"] as! String //程序名称
let appVersion: String = infoDictionary["CFBundleShortVersionString"] as! String   //主程序版本号
let buildVersion: String = infoDictionary["CFBundleVersion"] as! String    //版本号（内部标示）
let bundleIdentifier: String = infoDictionary["CFBundleIdentifier"] as! String    //唯一标识符
let visualAlpha: CGFloat = 0.95

//设备信息
let iosVersion = UIDevice.current.systemVersion //iOS版本
let identifierNumber = UIDevice.current.identifierForVendor //设备udid
let systemName = UIDevice.current.systemName //设备名称
let deviceModel = UIDevice.current.model //设备型号
let localizedModel = UIDevice.current.localizedModel //设备区域化型号如A1533
let maxTimeStamp:TimeInterval = TimeInterval(3376656000)    //2077-01-01 00:00:00


let isIphoneX: Bool = {
    print("执行了代码 不确认是否还会执行");
    var ipx:Bool = false
    if #available(iOS 11.0.0, *) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            let notchValue:Int = Int(UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height * 100)
            if 216 == notchValue || 46 == notchValue {
                ipx = true
            }
        }
    }
    return ipx
}()

let isTestApp: Bool = {
    var testApp = false
    if appDisplayName.lowercased().contains("test") {
        testApp = true
    }
    return testApp
}()

class Once {
    var already: Bool = false
    func run(block: () -> Void) {
        guard !already else { return }
        block()
        already = true
    }
}

let placeHeadImg: UIImage? = {
    return UIImage.init(named: "default_head_image")
}()

let placehodlerImg: UIImage = {
    let tempImg = UIImage.init(named: "placehodler")
    let tb = (tempImg?.size.height ?? 0) / 3.0
    let lr = (tempImg?.size.width ?? 0) / 3.0
    let resultImg = tempImg?.resizableImage(withCapInsets: UIEdgeInsets.init(top: tb, left: lr, bottom: tb, right: lr), resizingMode: .stretch) ?? UIImage.init()
    return resultImg
}()

func scaleHeight(_ h:CGFloat) -> CGFloat {
    return  (screenHeight/667)*h
}

func scaleWidth(_ w:CGFloat) -> CGFloat {
    return  (screenWidth/375)*w
}


//程序 主体色号
let themeBarColor = UIColor.init(hex: "27DAD7")
let themeBarDisableColor = UIColor.init(hex: "27DAD7").withAlphaComponent(0.6)


//全局通知界面强制刷新的操作
public let kNotifyRefresh = NSNotification.Name(rawValue: "kNotifyRefresh")


enum ThirdPartRegisterKey:String {
    case  gaokeApiKey = "a445d0a1cf5c73d24b2b22b14e5a1f49", //高德地图
          buglyKey = "2824971a9a", //buglyKey
          uMengKey = "603c66756ee47d382b69ea53", //友盟
          yunXinKey = "aa5cb730a095a8c93040d2964de75f7d",//云信
          jiGuangKey  = "543f2ca8047734ddb9d13c7c",//极光
          weiXinKey = "" //微信的
          
    
}
