//
//  Hud+extension.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/9.
//

import Foundation
import MBProgressHUD
import NVActivityIndicatorView
extension  MBProgressHUD{
    fileprivate class func showText(text: String, icon: String) {
        let view = viewWithShow()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.label.textColor = .black
        let img = UIImage(named: "MBProgressHUD.bundle/\(icon)")
        
        hud.customView = UIImageView(image: img)
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true
        
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    class func viewWithShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windowArray = UIApplication.shared.windows
            
            for tempWin in windowArray {
                if tempWin.windowLevel == UIWindow.Level.normal {
                    window = tempWin;
                    break
                }
            }
            
        }
        return window!
    }
    
    class func showStatusInfo(_ info: String) {
        
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf:
                                            [MBProgressHUD.self]).color = .white
        let view = viewWithShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.textColor = UIColor.white
        hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor;
        
        hud.bezelView.backgroundColor =  UIColor.black.withAlphaComponent(0.8)
        hud.label.text = info
    }
    
    class func dismiss() {
        let view = viewWithShow()
        MBProgressHUD.hide(for: view, animated: true)
        
    }
    
    class func showSuccess(_ status: String) {
        showText(text: status, icon: "success.png")
    }
    
    class func showError(_ status: String) {
        self.dismiss()
        showText(text: status, icon: "error.png")
    }
    
    
    
}




