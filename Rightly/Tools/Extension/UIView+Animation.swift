//
//  UIView+Animation.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/21.
//

import Foundation
import Foundation
import UIKit
import  QuartzCore
fileprivate let ButtonPadding:CGFloat = 100
//主要是在动画完成时可以进行一些操作
class AnimationDelegate: NSObject, CAAnimationDelegate {
    
    fileprivate let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func animationDidStop(_: CAAnimation, finished: Bool) {
        completion()
    }
}

extension UIView {
    
    func animateCircular(withDuration duration: TimeInterval, center: CGPoint, revert: Bool = false, animations: () -> Void, completion: ((Bool) -> Void)? = nil) {
        guard let  snapshot = snapshotView(afterScreenUpdates: false) else {
            return
        }
        snapshot.frame = bounds
        self.addSubview(snapshot)
        let center = convert(center, to: snapshot)
        let radius: CGFloat = {
            let x = max(center.x, frame.width - center.x)
            let y = max(center.y, frame.height - center.y)
            return sqrt(x * x + y * y)
        }()
        var animation : CircularRevealAnimator
        if !revert {
            animation = CircularRevealAnimator(layer: snapshot.layer, center: center, startRadius: 0, endRadius: radius, invert: true)
        } else {
            animation = CircularRevealAnimator(layer: snapshot.layer, center: center, startRadius: radius, endRadius: 0, invert: false)
        }
        animation.duration = duration
        animation.completion = {
            snapshot.removeFromSuperview()
            completion?(true)
        }
        animation.start()
        animations()
    }
}
private func SquareAroundCircle(_ center: CGPoint, radius: CGFloat) -> CGRect {
    assert(0 <= radius, "请修改你的半径，它不能为0")
    return CGRect(origin: center, size: CGSize.zero).insetBy(dx: -radius, dy: -radius)
}
class CircularRevealAnimator {
    
    var completion: (() -> Void)?
    
    fileprivate let layer: CALayer
    fileprivate let mask: CAShapeLayer
    fileprivate let animation: CABasicAnimation
    
    var duration: CFTimeInterval {
        get { return animation.duration }
        set(value) { animation.duration = value }
    }
    
    var timingFunction: CAMediaTimingFunction! {
        get { return animation.timingFunction }
        set(value) { animation.timingFunction = value }
    }
    
    init(layer: CALayer, center: CGPoint, startRadius: CGFloat, endRadius: CGFloat, invert: Bool = false) {
        let startCirclePath = CGPath(ellipseIn: SquareAroundCircle(center, radius: startRadius), transform: nil)
        let endCirclePath = CGPath(ellipseIn: SquareAroundCircle(center, radius: endRadius), transform: nil)
        
        var startPath = startCirclePath, endPath = endCirclePath
        if invert {
            var path = CGMutablePath()
            path.addRect(layer.bounds)
            path.addPath(startCirclePath)
            startPath = path
            path = CGMutablePath()
            path.addRect(layer.bounds)
            path.addPath(endCirclePath)
            endPath = path
        }
        
        self.layer = layer
        
        mask = CAShapeLayer()
        mask.path = endPath
        mask.fillRule = .evenOdd
        
        animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.delegate = AnimationDelegate {
            layer.mask = nil
            self.completion?()
            self.animation.delegate = nil
        }
    }
    
    func start() {
        layer.mask = mask
        mask.frame = layer.bounds
        mask.add(animation, forKey: "reveal")
    }
}
