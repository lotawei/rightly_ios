//
//  UIView+Red.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/7.
//

import Foundation

import Foundation
import UIKit
import SnapKit
private let lxfFlag: Int = 777
private let numberFlag: Int = 333
public extension UIView {
    // MARK:- 显示小红点
    func showViewBadgOn() {
        // 移除之前的小红点
        self.removeViewBadgeOn()
        // 创建小红点
        let bageView = UIView()
        bageView.tag = lxfFlag
        bageView.layer.cornerRadius = 3.5
        bageView.backgroundColor = UIColor.red
        bageView.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        bageView.cornerRadius = 4.0
        bageView.borderWidth = 1.0
        bageView.borderColor = .white
        
        self.addSubview(bageView)
        bageView.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(0)
            maker.height.width.equalTo(8)
        }
    }
    
    // MARK:- 隐藏小红点
    func hideViewBadg() {
        // 移除小红点
        self.removeViewBadgeOn()
    }
    
    // MARK:- 移除小红点
    fileprivate func removeViewBadgeOn() {
        // 按照tag值进行移除
        _ = subviews.map {
            if $0.tag == lxfFlag {
                $0.removeFromSuperview()
            }
        }
    }
    
    //MARK:- 显示数字小红点
    func showNumberViewBadfOn( number: Int, badgeColor: UIColor? = nil) {
        // 移除之前的小红点
        self.removeNumberViewBadgeOn()
        
        // 创建小红点
        let bageView = UILabel()
        bageView.alpha = 1
        bageView.tag = numberFlag
        bageView.layer.cornerRadius = 5
        bageView.layer.masksToBounds = true
        bageView.backgroundColor = badgeColor ?? UIColor.red
        if number > 99 {
            bageView.text = "··"
        } else {
            bageView.text = "\(number)"
        }
        bageView.font = UIFont.systemFont(ofSize: 11)
        bageView.textColor = UIColor.white
        bageView.textAlignment = .center
        self.addSubview(bageView)
        bageView.snp.makeConstraints { (maker) in
            maker.right.top.equalToSuperview()
            maker.height.width.equalTo(15)
        }
    }
    
    // MARK:- 隐藏数字小红点
    func hideNumberViewBadg() {
        // 移除数字小红点
        self.removeNumberViewBadgeOn()
    }
    
    // MARK:- 移除数字小红点
    fileprivate func removeNumberViewBadgeOn() {
        // 按照tag值进行移除
        _ = subviews.map {
            if $0.tag == numberFlag {
                $0.removeFromSuperview()
            }
        }
    }
    
    // MARK:- 创建当前视图的截图
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
        
    }
}



extension UIView {
    static func createLineView() -> UIView {
        let lineView = UIView.init()
        lineView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 1)
        lineView.backgroundColor = UIColor.init(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0,alpha: 1)
        return lineView
    }
}
