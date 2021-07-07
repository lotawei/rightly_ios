//
//  UIView+DealWithAction.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/10.
//

import Foundation

extension  UIView {
    
    /// 视图层级的跳转用户主页
    /// - Parameter userid: 用户id
    func jumpUSer(userid:Int64)  {
        GlobalRouter.shared.jumpUserHomePage(userid: userid)
    }
    
    /// 跳转打招呼动态详情
    /// - Parameter greetingid: greetingid
    func jumpGreetingDetail(greetingid:Int64)  {
        GlobalRouter.shared.jumpDynamicDetail("\(greetingid)")
    }
}
