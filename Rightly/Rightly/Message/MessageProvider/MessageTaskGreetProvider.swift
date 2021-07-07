//
//  MessageTaskGreetProvider.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/26.
//

import UIKit
import RxSwift
import Moya
import RxCocoa

struct ResultError: Error {
    let code:Int?
    let desc:String?
}

class MessageTaskGreetProvider: NetworkRequest {

    /// 和我打招呼的列表
    func greetingWithMe(_ pageNum:Int, pageSize:Int,_ disposebag:DisposeBag) -> Observable<RTApiResult<[String:Any]?>> {
        return Observable<RTApiResult<[String:Any]?>>.create {
            observer -> Disposable in
            Provider.rx.request(.request(body:["pageNum":pageNum,"pageSize":pageSize],path:"greeting/withMe",methodType: .get, urlparams: nil)).filterSuccessfulStatusCodes().subscribe { (response) in
                var requestJSON:[String : Any]?
                do {
                    requestJSON = try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) as? [String : Any]
                } catch {
                    let err = RTApiResult<[String:Any]?>.init(result: nil)
                    observer.onNext(err)
                    observer.onCompleted()
                    return
                }
                
                let requestDatas:[String : Any]? = requestJSON?["data"] as? [String : Any]
                let res = RTApiResult<[String:Any]?>.init(result: requestDatas)
                observer.onNext(res)
                observer.onCompleted()
            } onError: { (err) in
                let res = RTApiResult<[String:Any]?>.init(result: nil, error: err)
                observer.onNext(res)
                observer.onCompleted()
            }.disposed(by: disposebag)
            
            return Disposables.create()
        }
    }
    
    /// 和某个人打招呼的详情
    func greetingSomeoneDetails(_ userId:String,_ disposebag:DisposeBag) -> Observable<ReqDicResult> {
        return self.reqDataDicObserver(body: ["userId":userId], path: "greeting/someone/details", methodType: .get, disposeBag: disposebag)
    }
    
    /// 同意某个招呼
    /// 同意后变成好友关系
    func greetingAllow(_ greetingId:String, _ allowContent:String, _ disposebag:DisposeBag) -> Observable<ReqStrResult> {
        let body:[String:Any] = ["greetingId":greetingId, "allowContent":allowContent]
        return self.reqDataStrObserver(body: body, path: "greeting/allow", methodType: .post, disposeBag: disposebag, nil)
    }
    
    /// 同意的列表
    /// 包含双方的，用于同步好友列表
    func greetingAllowList(_ lastDate:String,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["lastDate":lastDate, "pageSize":20], path: "greeting/allow/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 未读招呼数
    /// 这儿指的是给我打招呼的有多少未读，不是消息数
    func greetingUnreadNum(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: nil, path: "greeting/unreadNum", methodType: .get, disposebag: disposebag, nil)
    }
}
