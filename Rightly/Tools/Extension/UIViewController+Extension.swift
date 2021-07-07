//
//  UIViewController+Extension.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/10.
//

import Foundation


extension NSObject{
    func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getCurrentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }
}
extension  UIViewController {
    static func getCurrentViewController() -> UIViewController? {
        let  objc = NSObject.init()
        return  objc.getCurrentViewController()
    }
}


extension UIViewController {
    
    /// 关注弹窗
    /// - Parameter sureActionBlock:
    func alterUnfollowed(_ sureActionBlock:( ((_ sure:Bool)->Void)?))  {
        let alertController = UIAlertController(title: "",
                                                message:"UnFollow this Account?".localiz() ,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"system_Cancel".localiz(), style: .cancel, handler:{
            _ in
            sureActionBlock?(false)
        })
        let settingsAction = UIAlertAction(title:"Ok".localiz(), style: .default, handler: {
            (action) -> Void in
             sureActionBlock?(true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    /// 解锁成功提示
    func showAlterUnlockSuccess(userid:Int64)  {
        UserManager.manager.requestUserInfo(userid, infoDetail: {[weak self] (info) in
            guard let `self` = self  else {return }
            if (info.isUnlock ?? false)  {
                if let viewtype = info.bgViewType {
                    switch viewtype {
                    case .Private:
                        self.showAlterUnlockbgViewSuccess(info)
                    default:
                        self.showAlterUnlockNobgView( userid)
                    }
                    
                    MatchLimitCountManager.shared.unlockUser.accept(info.userId ?? 0)
                }
            }else{
                self.showAlterUnlockNobgView(userid)
            }
            
        })
        
    }
    func showAlterUnlockNobgView(_ userid:Int64)  {
        let  alterunlockView:UnlockUserAlterView? =  UnlockUserAlterView.loadNibView()
        alterunlockView?.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(295), height: scaleHeight(320))
        alterunlockView?.showOnWindow( direction: .center)
        alterunlockView?.doneBlock = {
            [weak self] in
            guard let `self` = self  else {return }
            GlobalRouter.shared.jumpUserHomePage(userid: userid)
        }
    }
    func showAlterUnlockbgViewSuccess(_ info:UserAdditionalInfo)  {
        let  alterunlockView:GuideUnlockUserAlterView? =  GuideUnlockUserAlterView.loadNibView()
        alterunlockView?.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(295), height: scaleHeight(440))
        alterunlockView?.updateInfo(info)
        alterunlockView?.showOnWindow( direction: .center)
        self.afterDelay(0.01) {
            alterunlockView?.tiplbl.centerVertically()
        }
    }
    
}

extension  UIViewController {
    private struct AssociatedKeys {
        static var showLeftBack = "showLeftBack"
    }
    private var showLeftBack: Bool? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.showLeftBack) as? Bool)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.showLeftBack, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate func exchangeViewWillAppear() {
        let orginalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(re_viewWillAppear(_:))
        let orginalMethod = class_getInstanceMethod(self.classForCoder, orginalSelector)
        let swizzledMethod = class_getInstanceMethod(self.classForCoder, swizzledSelector)
        
        let didAddMethod = class_addMethod(self.classForCoder, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self.classForCoder, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
        } else {
            method_exchangeImplementations(orginalMethod!, swizzledMethod!)
        }
    }
    func setshowLeftBack(target: Bool = false) {
        self.showLeftBack = target
        exchangeViewWillAppear()
        
    }
    @objc func re_viewWillAppear(_ animated:Bool){
        self.re_viewWillAppear(animated)
        if let leftback =  self.showLeftBack,!leftback{
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
        }
    }
    
}
extension UIViewController {
    
    /// 关闭开启im推送
    /// - Parameter sureActionBlock:
    func alterClosePush(_ sureActionBlock:( ((_ sure:Bool)->Void)?))  {
        let alertController = UIAlertController(title: "",
                                                message:"Close im push notification?".localiz() ,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"system_Cancel".localiz(), style: .cancel, handler:{
            _ in
            sureActionBlock?(false)
        })
        let settingsAction = UIAlertAction(title:"Ok".localiz(), style: .default, handler: {
            (action) -> Void in
             sureActionBlock?(true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
