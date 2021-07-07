//
//  NetAPIManager.swift
//  
//
//  Created by apple on 2020/2/23.
//  Copyright © 2020 lotawei. All rights reserved.
//

import UIKit
import Moya
import RxSwift


public let DominTestUrl = "http://dev.api.rightly.cc/"
public let DominUrl = "https://api.rightly.lerjin.com/"

enum NetAPIManager {
    // 下载文件的
    case download(body: [String:Any]? = nil,path:String? = nil,methodType: Moya.Method? = nil,destination:DownloadDestination)
    // 要传body json字符串data 用这种 &role=9&ss=8 带参url
    case request(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil , urlparams:[String:Any]?)
    // form 表单提交
    case requestFormData(path:String? = nil,formdata: [MultipartFormData])
    // 文件上传类型的
    case upload([MultipartFormData],path:String? = nil, urlParameters: [String: Any]? = nil,methodType: Moya.Method? = nil)
}
// 此项目用不上
protocol RTAuthorizedTargetType: TargetType {
    //返回是否需要授权
    var needsAuth: Bool { get }
}
//extension NetAPIManager: RTAuthorizedTargetType
extension NetAPIManager:TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "\(isTestApp ? DominTestUrl :  DominUrl)")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .request(_,let path, _, _):
            return path ?? ""
        case .download(_,let path, _, _):
            return path ?? ""
        case .upload(_,let path, _, _):
            return path ?? ""
        case .requestFormData(let path, _):
            return path ?? ""
        }
    }
    /// The HTTP method used in the request.
    var method: Moya.Method {
        var method : Moya.Method
        switch self {
        case .request(_, _,let methodType,_):
            method = methodType ?? Moya.Method.get
        case .download(_, _,let methodType,_):
            method = methodType ?? Moya.Method.get
        case .upload(_, _,_,let methodType):
            method = methodType ?? Moya.Method.get
        case .requestFormData( _,_):
            return .post
        }
        return method
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
            
            
        case .request(let body,_,_,let urlparameters):
            
            if self.method == .get {
                return Task.requestParameters(parameters: body ?? [:], encoding: URLEncoding.default)
            } else {
                if urlparameters == nil {
                    return Task.requestParameters(parameters: body ?? [:], encoding: JSONEncoding.default)
                }else{
                    return Task.requestCompositeParameters(bodyParameters: body ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: urlparameters ?? [:])
                }
              
            }
        case .download(let body,_,_,let destination):
            return Task.downloadParameters(parameters: body ?? [:], encoding: JSONEncoding.default, destination: destination)
        case .upload(let multiparts,_,let urlParameters,_):
            if let urlParameters = urlParameters {
                return Task.uploadCompositeMultipart(multiparts, urlParameters: urlParameters)
            }
            return Task.uploadMultipart(multiparts)
        case .requestFormData(_, let formdata):
            return  .uploadMultipart(formdata)
        }
    }
    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType {
        return .none
    }
    
    /// The headers to be used in the request.
    var headers: [String: String]? {
        return nil
    }
}

