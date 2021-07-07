//
//  HDPublicHeaderPlugin.swift
//  
//
//  Created by apple on 2020/3/15.
//  Copyright © 2020 lotawei. All rights reserved.
//

import Moya


struct RTPublicHeaderPlugin: PluginType {
    let tokenClosure: () -> String?
    /// Called to modify a request before sending.
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutableRequest = request
        if let token = self.tokenClosure()  {
            //将token添加到请求头中
            if request.url?.absoluteString.shouldBeAddToken() ?? false {
                if let userid = UserManager.manager.currentUser?.additionalInfo?.userId {
                    mutableRequest.addValue("\(userid)", forHTTPHeaderField: "x-user-id")
                }
                if let nickName = UserManager.manager.currentUser?.additionalInfo?.nickname {
                    mutableRequest.addValue("\(nickName)", forHTTPHeaderField: "x-user-nickname")
                }
                if let appVersion = UIDevice.current.getAppVersion() {
                    mutableRequest.addValue("\(appVersion)", forHTTPHeaderField: "x-app-version")
                }
                if  let deviceId =  UIDevice.current.getDeviceUUID(){
                    mutableRequest.addValue(deviceId, forHTTPHeaderField: "x-device-id")
                }
     
                mutableRequest.addValue("ios", forHTTPHeaderField: "x-platform")
                mutableRequest.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
                mutableRequest.addValue("\(LanguageManager.shared.currentLanguage.transXlanguages())", forHTTPHeaderField:"x-language" )
            }
        }
        RTPrint(message:"[网络请求地址:\(mutableRequest.url!)"+"\n"+"\(mutableRequest.httpMethod ?? "")\n"+"发送参数"+"\(String(data: mutableRequest.httpBody ?? Data.init(), encoding: String.Encoding.utf8) ?? "")"+"头部:\(String(describing: mutableRequest.allHTTPHeaderFields))]\n")
        return mutableRequest
    }
}

extension String {
    func shouldBeAddToken() -> Bool{
        if self.contains("thirdParty/login")  || self.contains("system/"){
            return false
        }else{
            return true
        }
    }
    
}


