//
//  UIViewController+Hud.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/30.
//

import Foundation
import Foundation
import UIKit
class HudView: UIView {
    var text: NSString = ""
    var imageName: String = ""
    var boxSize: CGSize = CGSize(width: 96, height: 96)
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
//        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxSize.width) / 2),
            y: round((bounds.size.height - boxSize.height) / 2),
            width: boxSize.width,
            height: boxSize.height)
        
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        
        if let image = UIImage(named: imageName) {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxSize.height / 8
            )
            image.draw(at: imagePoint)
        }
        
        let attribs = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                        NSAttributedString.Key.foregroundColor: UIColor.white]
        let textSize = text.size(withAttributes: attribs)
        if imageName != "" {
            let textPoint = CGPoint(
                x: center.x - round(textSize.width / 2),
                y: center.y - round(textSize.height / 2) + boxSize.height / 4)
            text.draw(at: textPoint, withAttributes: attribs)
        }else{
            let textPoint = CGPoint(
                x: center.x - round(textSize.width / 2),
                y: center.y - round(textSize.height / 2))
            text.draw(at: textPoint, withAttributes: attribs)
        }
        
    }
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                                self.alpha = 1
                                self.transform = CGAffineTransform.identity
                           },
                           completion: nil)
        }
    }
    
    func hide() {
        self.removeFromSuperview()
    }
    
}

extension  NSObject {
    func windowToastTip(_ text: String) {
        if let windowKey = keyWindow {
            let hudView = HudView.hud(inView: windowKey, animated: true)
            hudView.text = text as NSString
            hudView.imageName = ""
            hudView.boxSize = CGSize(width: screenWidth - 32, height: 60)
            let delayInSeconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                hudView.hide()
            })
        }
       
    }
}
extension  UIViewController{
    func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
    }
    
    func toastTip(_ text: String) {
        let hudView = HudView.hud(inView: self.view, animated: true)
        hudView.text = text as NSString
        hudView.imageName = ""
        hudView.boxSize = CGSize(width: screenWidth - 32, height: 60)
        let delayInSeconds = 1.0
        afterDelay(delayInSeconds) {
            hudView.hide()
        }
    }
    
  
    
}
extension UIViewController {
    class func current(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return current(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return current(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return current(base: presented)
        }
        return base
    }
}


extension UIViewController {
        func gotoSetting(){
          let settingUrl = NSURL(string: UIApplication.openSettingsURLString)!
           if UIApplication.shared.canOpenURL(settingUrl as URL)
           {
               //UIApplication.shared.openURL(settingUrl as URL)
               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(settingUrl as URL, options: [:], completionHandler: { (sucess) in
                       if sucess {
                           print("ok")
                       }
                   })
               } else {
                   // Fallback on earlier versions
               }
           }
       }
       
}
