//
//  GlobalRouter.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/7.
//

import Foundation
import URLNavigator
fileprivate  let  urlPrefix:String = "rightly://"
class GlobalRouter:NSObject {
    static let  shared:GlobalRouter = GlobalRouter()
    var navigator:NavigatorType = Navigator()
    func registerAppUrl()  {
        
        NavigationMap.initialize(navigator: self.navigator)
        
    }
    /// 用户主页
    /// - Parameter userid: <#userid description#>
    func jumpUserHomePage(userid:Int64) {
        navigator.rt_open("UserHomePage?userId=\(userid)")
    }
    /// web
    /// - Parameter userid:
    func jumpByUrl(url:String) {
        navigator.rt_open("webView?url=\(url)")
    }
    /// web
    /// - Parameter
    func jumpByUrl(html:String,title:String) {
        navigator.rt_open("webView?html=\(html)&title=\(title)")
    }
    //做某人的任务
    func dotaskUser(_ userid:Int64)  {
        navigator.rt_open("greetinfo?userId=\(userid)")
    }
    
    //跳转到动态详情
    func jumpDynamicDetail(_ greetingId:String)  {
        navigator.rt_open("dynamic?greetingId=" + greetingId)
    }
}

extension  NavigatorType {
    func rt_open(_ routerIdentify:String)  {
        self.open("\(urlPrefix)"+routerIdentify)
    }
    func  rt_handle(_ routerIdentify:String,factory:@escaping URLOpenHandlerFactory){
        self.handle("\(urlPrefix)" + routerIdentify, factory)
    }
}

enum NavigationMap {
    static func initialize(navigator: NavigatorType) {
      navigator.rt_handle("UserHomePage") { (url, values, context) -> Bool in
          // No navigator match, do analytics or fallback function here
          if let  userid = Int64(url.queryParameters["userId"] ?? "0"),userid > 0 {
              let vc = PersonalViewController.loadFromNib()
              vc.userid = userid
              UIViewController.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: false)
          }
          return true
        }
        navigator.rt_handle("webView") { (url, values, context) -> Bool in
            if let  url =  url.queryParameters["url"],!url.isEmpty{
                  jumpWeb(url)
            }
            
            if let  html =  url.queryParameters["html"],!html.isEmpty, let title = url.queryParameters["title"]{
                 jumpLocalHtmlWeb(html, title: title)
            }
            return true
        }
        navigator.rt_handle("greetinfo") { (url, values, context) -> Bool in
            // No navigator match, do analytics or fallback function here
            if let  userid = Int64(url.queryParameters["userId"] ?? "0"),userid > 0{
                let greetInfo = GreetInfoViewController.init(userid.description)
                UIViewController.getCurrentViewController()?.navigationController?.pushViewController(greetInfo, animated: false)
            }
            return true
        }

        navigator.rt_handle("dynamic") { (url, values, context) -> Bool in
            if let greetingid = url.queryParameters["greetingId"] {
                let dynamicVC = DynamicDetailsViewController.init(greetingid)
                UIViewController.getCurrentViewController()?.navigationController?.pushViewController(dynamicVC, animated: false)
            }
            return true
        }
    }
    
    
    static func jumpWeb(_ url:String){
        let vc = WebController.init()
        vc.title = "WebTitle"
        vc.load(url)
        UIViewController.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func jumpLocalHtmlWeb(_ html:String,title:String){
        let vc = WebController.init()
        vc.title = title
        vc.webView.loadHTMLString(html, baseURL: nil)
        UIViewController.getCurrentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
