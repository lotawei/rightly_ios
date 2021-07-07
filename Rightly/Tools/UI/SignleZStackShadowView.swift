//
//  SignleZStackShadowView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/4.
//

import Foundation
import Foundation
import UIKit
import SnapKit
//http://dev.cdn.channelthree.net/greeting/1400365285197877249.mp4
//实现一个单图模拟底图的效果
class SignleZStackShadowView:UIView {
    fileprivate var deepTreeCount = 3
    fileprivate var pxPading:CGFloat = 12
    var bodyView:UIView?=nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }
    convenience   init(frame: CGRect,bodyV:UIView) {
        self.init(frame:frame)
        self.bodyView = bodyV
        self.setUpView()
    }
   fileprivate func setUpView()  {
        if let bodyV = self.bodyView {
            self.addSubview(bodyV)
            bodyV.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
            bodyV.layer.zPosition = 9 //z越大 越向屏幕外面
            for i  in 1...deepTreeCount {
                let v = self.creatShadowDeepV(v:bodyV,1-(CGFloat(i)*0.4))
                let  pxpading:CGFloat = CGFloat(12 * (i+1))
                self.addSubview(v)
                v.snp.makeConstraints { (maker) in
                    maker.left.equalToSuperview().offset(pxpading)
                    maker.right.equalToSuperview().offset(-pxPading)
                    maker.top.equalToSuperview()
                    maker.bottom.equalToSuperview().offset(pxpading)
                }
                v.layer.zPosition = -CGFloat(i)
            }
          
        }
    }
    fileprivate func creatShadowDeepV(v:UIView,_ alp:CGFloat) -> UIView {
        let bottomV1 = UIView.init(frame: .zero)
        bottomV1.alpha = alp
        bottomV1.clipsToBounds = true
        bottomV1.layer.cornerRadius = 10
        bottomV1.backgroundColor = v.backgroundColor
        return bottomV1
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
