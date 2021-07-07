//
//  File.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/2.
//
import Photos
import AssetsLibrary
import MediaPlayer
import CoreTelephony
import CoreLocation
import AVFoundation

//MARK:-
public enum PermissionType:String {
    /// 相机
    case camera
    /// 相册
    case photo
    /// 位置
    case location
    /// 网络
    case network
    /// 麦克风
    case microphone
    /// 媒体库
    case media
}

//MARK:-
open class SystemPermission: NSObject {
    /// 开启媒体资料库/Apple Music 服务
    @available(iOS 9.3, *)
    public static func checkMedia(alertEnable: Bool = true, completion: ((Bool)->Void)? = nil) {
        let authStatus = MPMediaLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion?(true)
                        break
                        
                    default:
                        completion?(false)
                        if alertEnable { alert(type: .media) }
                        break
                    }
                }
            }
            break
            
        case .authorized:
            completion?(true)
            break
            
        default:
            completion?(false)
            if alertEnable { alert(type: .media) }
            break
        }
    }

    
    /// 检测是否开启网络
    /// - parameter: alertEnable : 是否显示设置弹框
    /// - parameter: completion : 返回闭包，不使用时需要释放 cellularData.cellularDataRestrictionDidUpdateNotifier = nil
    /// - returns :
    /// 需与Reachability配合使用
    public static func checkNetwork(alertEnable: Bool = true, completion: ((_ hasNetwork: Bool, _ cellular: CTCellularData)->Void)? = nil) {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            switch state {
            case .restrictedStateUnknown, .restricted:
                completion?(false, cellularData)
                if alertEnable { alert(type: .network) }
                break

            default:
                completion?(true, cellularData)
                break
            }
        }
    }

    /// 检测是否开启定位
    public static func checkLocation(alertEnable: Bool = true, completion: ((Bool)->Void)? = nil) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            completion?(false)
            if alertEnable { alert(type: .location) }
            break
            
        default:
            completion?(true)
        }
    }

    /// 检测是否开启摄像头
    public static func checkCamera(alertEnable: Bool = true, completion: ((Bool)->Void)? = nil) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                completion?(granted)
                if granted == false && alertEnable == true { alert(type: .camera) }
            }
            break
            
        case .restricted, .denied:
            completion?(false)
            if alertEnable == true { alert(type: .camera) }
            break
            
        default:
            completion?(true)
        }
    }
    
    
    /// 检测是否开启相册
    public static func checkPhoto(alertEnable: Bool = true, completion: ((Bool)->Void)? = nil) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .restricted, .denied:
            completion?(false)
            if alertEnable == true { alert(type: .photo) }
            break
            
        default:
            completion?(true)
        }
    }

    
    /// 检测是否开启麦克风
    public static func checkMicrophone(alertEnable: Bool = true, completion: ((Bool)->Void)? = nil) {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        switch permissionStatus {
        case .undetermined:
            
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                completion?(granted)
                if granted == false && alertEnable == true { alert(type: .microphone) }
            }
            break
            
        case .denied:
            completion?(false)
            if alertEnable == true { alert(type: .microphone) }
            break
            
        default:
            completion?(true)
            break
        }
    }
    
    
    /// 跳转系统设置界面
    public static func alert(type: PermissionType? = nil) {
        DispatchQueue.main.async {
            let title = "访问受限"
            var message = "请点击“前往”，允许访问权限"
            
            // App名称
            var appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
            if !appName.isEmpty {
                appName = "\"\(appName)\""
            }
            if type == .camera { // 相机
                message = "请在iPhone的\"设置-隐私-相机\"选项中，允许\(appName)访问你的相机".localiz()
            } else if type == .photo { // 相册
                message = "请在iPhone的\"设置-隐私-照片\"选项中，允许\(appName)访问您的相册".localiz()
            } else if type == .location { // 位置
                message = "请在iPhone的\"设置-隐私-定位服务\"选项中，允许\(appName)访问您的位置，获得更多数据信息".localiz()
            } else if type == .network { // 网络
                message = "请在iPhone的\"设置-蜂窝移动网络\"选项中，允许\(appName)访问您的移动网络".localiz()
            } else if type == .microphone { // 麦克风
                message = "请在iPhone的\"设置-隐私-麦克风\"选项中，允许\(appName)访问您的麦克风".localiz()
            } else if type == .media { // 媒体库
                message = "请在iPhone的\"设置-隐私-媒体与Apple Music\"选项中，允许\(appName)访问您的媒体库".localiz()
            }
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
            let settingsAction = UIAlertAction(title:"前往", style: .default, handler: {
                (action) -> Void in
                if  UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],completionHandler: {(success) in})
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            UIViewController.getCurrentViewController()?.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func isrequestFirst(_ permissionType:PermissionType) -> Bool {
        let  defaultPermissionTypeKey = "FirstRequest\(permissionType.rawValue)"
        if let isfirst =  UserDefaults.standard.object(forKey: defaultPermissionTypeKey) as? Bool {
            return  isfirst
        }
        return true
    }
    func saveRequestNotFirstPermission(_ permissionType:PermissionType)  {
        let  defaultPermissionTypeKey = "FirstRequest\(permissionType.rawValue)"
        UserDefaults.standard.setValue(true, forKey: defaultPermissionTypeKey)
        UserDefaults.standard.synchronize()
    }
}

