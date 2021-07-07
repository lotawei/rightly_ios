//
//  SignProvider.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/13.
//

import Foundation
import RxSwift
import Moya
import RxCocoa

class SignProvider: NetworkRequest {
    
    /// 用户手机号灯亮度
    /// - Parameters:
    ///   - areaCode: 手机区号 +86
    ///   - phone: 手机号
    ///   - vfCode: 验证码
    func userPhoneLogin(_ areaCode:String, _ phone:String,_ vfCode:String, _ disposebag:DisposeBag) -> Observable<ReqDicResult> {
        let body:[String:Any] = ["areaCode":areaCode, "phone":phone, "vfCode":vfCode]
        return self.reqDataDicObserver(body: body, path: "users/phone/login", methodType: .post, disposeBag: disposebag, nil)
    }
    
    
    /// 发送手机验证码
    /// - Parameters:
    ///   - areaCode: 手机区号 +86
    ///   - phone: 手机号
    ///   - type: 验证码类型,1：登录
    func sendSMSCode(_ areaCode:String, _ phone:String,_ type:Int, _ disposebag:DisposeBag) -> Observable<ReqDicResult> {
        let body:[String:Any] = ["areaCode":areaCode, "phone":phone, "type":type]
        return self.reqDataDicObserver(body: body, path: "sms/send/vf", methodType: .post, disposeBag: disposebag, nil)
    }
    
    /// 测试发送手机验证码（会返回验证码）
    /// - Parameters:
    ///   - areaCode: 手机区号 +86
    ///   - phone: 手机号
    ///   - type: 验证码类型,1：登录
    func sendTestSMSCode(_ areaCode:String, _ phone:String,_ type:Int, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["areaCode":areaCode, "phone":phone, "type":type], path: "sms/send/vf/ret", methodType: .post, disposebag: disposebag, nil)
    }
}

