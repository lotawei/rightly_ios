//
//  RTApiResult.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
//网络统一结果
public enum RTApiResult<T>{
    case success(result:T?)
    case failed(Error)
}
extension RTApiResult {
    
    public init(result:T?,error:Error?=nil){
        if let err = error {
            self = .failed(err)
            return
        }
        guard let res = result else {
            let error = NSError.init(domain: "apiresult", code: -44, userInfo: nil)
            self = .failed(error)
            return
        }
        self = .success(result: res)
    }
    
    
}
