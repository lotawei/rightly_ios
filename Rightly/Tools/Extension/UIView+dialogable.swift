//
//  DSDialogable.swift
//  DSKit
//
//  Created by lotawei on 2020/5/27.
//

import UIKit
import Foundation


fileprivate var coverPointer = "UnsafeRawPointer_myCover"
fileprivate var windowPointer = "UnsafeRawPointer_myWindow"
fileprivate var durationPointer = "UnsafeRawPointer_myDuration"
fileprivate var directionPointer = "UnsafeRawPointer_myDirection"
fileprivate var voidClosurePointer = "UnsafeRawPointer_voidClosure"

fileprivate typealias voidClosure = () -> Void
protocol DissmissProtocol {
    func viewDisappear()
}
//MARK:- 移动方向
public enum DialogableDirection {
    case up
    case down
    case center
    case centeroffy(_ offy:CGFloat? = 0)
}

//MARK:-
extension UIView {
    
    /// 容器window
    fileprivate var myWindow: UIView? {
        get { return objc_getAssociatedObject(self, &windowPointer) as? UIView }
        set { objc_setAssociatedObject(self, &windowPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 遮罩
    fileprivate var myCover: UIView? {
        get { return objc_getAssociatedObject(self, &coverPointer) as? UIView }
        set { objc_setAssociatedObject(self, &coverPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 显示动画时长
    fileprivate var myDuration: TimeInterval {
        get { return objc_getAssociatedObject(self, &durationPointer) as? TimeInterval ?? 0.5 }
        set { objc_setAssociatedObject(self, &durationPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 移动方向
    fileprivate var myDirection: DialogableDirection {
        get { return objc_getAssociatedObject(self, &directionPointer) as? DialogableDirection ?? .up }
        set { objc_setAssociatedObject(self, &directionPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 单击手势
    fileprivate var tapGestureClosure: voidClosure? {
        set { objc_setAssociatedObject(self, &voidClosurePointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &voidClosurePointer) as? voidClosure }
    }
    
    ///
    fileprivate func tapClosure(_ taped: @escaping () -> Void) {
        self.tapGestureClosure = taped
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        self.addGestureRecognizer(tap)
    }
    
    ///
    @objc fileprivate func tapGesture(_ recognizer: UIGestureRecognizer) {
        self.tapGestureClosure?()
    }
    
    /// 移动至window上显示
    /// - parameter: window : 父视图windos
    /// - parameter: duration : 动画时常
    /// - parameter: coverColor : 遮照颜色
    /// - parameter: direction : 移动方向
    /// - parameter: enableclose : 点击空白区域关闭
    /// - returns :
    public func showOnWindow(window: UIView? = UIApplication.shared.keyWindow,
                      direction: DialogableDirection = .up,
                      duration: TimeInterval = 0.3,
                      coverColor: UIColor? = UIColor.black.withAlphaComponent(0.7),
                      enableclose: Bool = true,
                      completion: (() -> Void)? = nil,dissmissBlock:(() -> Void)? = nil) {
        
        guard let window = window else {
            return
        }
        self.myWindow = window
        self.myDuration = duration
        self.myDirection = direction
                
        let gestureView = self.gestureView(bgColor: coverColor ?? .clear)
        gestureView.frame = window.bounds
        window.addSubview(gestureView)
        window.bringSubviewToFront(gestureView)
        
        gestureView.tapClosure { [weak self] in
            guard let strongSelf = self else { return }
            if enableclose {
                    strongSelf.dismissFromWindow(completion: dissmissBlock)
            }
        }
        
        
        if window.subviews.contains(self) {
            window.bringSubviewToFront(self)
        } else {
            window.addSubview(self)
        }
        
        switch direction {
        case .down:
            popDown(window: window, completion: completion)
        case .center:
            popCenter(window: window, completion: completion)
        case .centeroffy(let off):
            popCenter(window: window, off, completion: completion)
        default:
            popUp(window: window, completion: completion)
        }
    }
    
    
    
    /// 隐藏
    public func dismissFromWindow(completion: (() -> Void)? = nil) {
       
        guard let window = self.myWindow  else {
            return
        }
        
        switch self.myDirection {
        case .down:
            dismissDown(window: window, completion: completion)
        case .center:
            dismissCenter(window: window, completion: completion)
        default:
            dismissUp(window: window, completion: completion)
        }
    }
    
    /// 删除
    public func removeFromWindow(completion: (() -> Void)? = nil) {
        
        dismissFromWindow { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.gestureView().removeFromSuperview()
            strongSelf.removeFromSuperview()
            completion?()
        }
    }
    
    ///
    fileprivate func popUp(window: UIView, completion: (() -> Void)? = nil) {
        
        self.frame.origin.y = window.frame.height
        self.isHidden = false
        let gestureView = self.gestureView()
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 1
            self.frame.origin.y -= self.frame.height
        }) { (_) in
            completion?()
        }
    }
    
    ///
    fileprivate func dismissUp(window: UIView, completion: (() -> Void)? = nil) {
        
        let gestureView = self.gestureView()
        
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 0
            self.frame.origin.y = window.frame.height
        }) { (_) in
            self.isHidden = true
            completion?()
        }
    }
    
    ///
    fileprivate func popDown(window: UIView, completion: (() -> Void)? = nil) {
        
        self.frame.origin.y = -self.frame.height
        self.isHidden = false
        let gestureView = self.gestureView()
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 1
            self.frame.origin.y += self.frame.height
        }) { (_) in
            completion?()
        }
    }
    
    ///
    fileprivate func dismissDown(window: UIView, completion: (() -> Void)? = nil) {
        
        let gestureView = self.gestureView()
        
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 0
            self.frame.origin.y = -self.frame.height
        }) { (_) in
            self.isHidden = true
            completion?()
        }
    }
    
    ///
    fileprivate func popCenter(window: UIView,_ offy:CGFloat? = 0 , completion: (() -> Void)? = nil) {
        self.center = CGPoint.init(x: window.frame.size.width / 2.0, y: (window.frame.size.height
                                                                            / 2.0) )
        if let ofy = offy {
            self.center = CGPoint.init(x: window.frame.size.width / 2.0, y: (window.frame.size.height
                                                    / 2.0) + ofy)
        }
        self.isHidden = true
        let gestureView = self.gestureView()
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 1
            self.isHidden = false
        }) { (_) in
            completion?()
        }
    }
    
    ///
    fileprivate func dismissCenter(window: UIView, completion: (() -> Void)? = nil) {
        
        let gestureView = self.gestureView()
        
        UIView.animate(withDuration: self.myDuration, animations: {
            gestureView.alpha = 0
            self.isHidden = true
        }) { (_) in
            completion?()
        }
    }
    
    /// 背景
    fileprivate func gestureView(bgColor: UIColor = .clear) -> UIView {
        if let coverView = self.myCover {
            return coverView
        }

        let tagView = UIView()
        tagView.alpha = 0
        tagView.backgroundColor = bgColor
        self.myCover = tagView
        return tagView
    }
}

