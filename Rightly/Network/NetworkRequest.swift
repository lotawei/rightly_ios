//
//  NetworkRequest.swift
//  Rightly
//
//  Created by qichen jiang on 2021/2/26.
//

import RxSwift
import Moya
import RxCocoa
extension String:Convertible {
    
}
extension Int:Convertible {
    
}
extension Double:Convertible {
    
}

// 1.成功  -4.token失效(账号在另一个设备上登录)
public class ReqResult {
    var code:Int = -400
    var message:String = ""
    var data:Any? = nil
    
    init(requestData:Data) {
        var resultJSONData:[String : Any]?
        do {
            resultJSONData = try JSONSerialization.jsonObject(with: requestData, options: .mutableContainers) as? [String : Any]
        } catch {
            debugPrint("接口返回数据解析JSON错误")
            return
        }
        self.code = resultJSONData?["code"] as? Int ?? 0
        self.message = resultJSONData?["message"] as? String ?? ""
        self.data = resultJSONData?["data"]
    }
}
extension  ReqResult {
    
    func modeDataKJTypeSelf<T>(typeSelf:T.Type) -> T? where T:Convertible {
        guard let customData  = self.data else {
            debugPrint("--- error  data nil")
            return nil
        }
        if let dicData =  customData  as? [String:Any]{
            return dicData.kj.model(typeSelf)
        }
        return nil
    }
}
public class ReqDataResult {
    var code:Int = -400
    var message:String = ""
    
    init(_ resultData:ReqResult) {
        self.code = resultData.code
        self.message = resultData.message
    }
}

public class ReqDicResult: ReqDataResult {
    var dicData:[String : Any]? = nil
    override init(_ resultData: ReqResult) {
        super.init(resultData)
        self.dicData = resultData.data as? [String : Any]
    }
}

public class ReqArrResult: ReqDataResult {
    var arrData:[[String : Any]]? = nil
    override init(_ resultData: ReqResult) {
        super.init(resultData)
        self.arrData = resultData.data as? [[String : Any]]
    }
}
extension ReqArrResult {
    func modelArrType<T>(_ typeSelf:T.Type) -> [T]? where T:Convertible {
        guard let arrDics = self.arrData else {
            return nil
        }
        var  resultData:[T] = []
        for dic in arrDics {
            let model = dic.kj.model(typeSelf)
            resultData.append(model)
        }
        return  resultData
    }
}
public class ReqPageArrResult: ReqDataResult {
    var pageNum:Int = 0
    var totalPage:Int = 0
    var results:[[String : Any]]? = nil
    override init(_ resultData: ReqResult) {
        super.init(resultData)
        guard let dataDic = resultData.data as? [String : Any] else {
            return
        }
        self.pageNum = dataDic["pageNum"] as? Int ?? 0
        self.totalPage = dataDic["totalPage"] as? Int ?? 0
        self.results = dataDic["results"] as? [[String : Any]]
    }
}

public class ReqStrResult: ReqDataResult {
    var strData:String? = nil
    override init(_ resultData: ReqResult) {
        super.init(resultData)
        self.strData = resultData.data as? String
    }
}

class NetworkRequest {
    open func responseSuccess(_ observer:AnyObserver<ReqResult>, requestData:Data) {
        let result = ReqResult.init(requestData: requestData)
        if result.code != 1 {
            observer.onError(NSError.init(domain: result.message, code: result.code, userInfo: nil))
            return
        }
        
        if result.code == -4 {
            observer.onError(NSError.init(domain: "token失效 设备在别处登录", code: result.code, userInfo: nil))
            AppDelegate.jumpLogin()
            return
        }
        
        observer.onNext(result)
        observer.onCompleted()
    }
    
   
    
    open func responseFailure(_ observer:AnyObserver<ReqResult>, error:Error) {
        debugPrint("HTTP请求错误")
        observer.onError(NSError.init(domain: "\(error)", code: -404, userInfo: nil))
    }
    
    /// 返回结果是 Any 用户自己处理的请求
    open func createRequestObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposebag:DisposeBag, _ urlparams:[String:Any]? = nil) -> Observable<ReqResult> {
        return Observable<ReqResult>.create {
            observer -> Disposable in
            Provider.rx.request(.request(body:body, path:path, methodType:methodType, urlparams: urlparams)).filterSuccessfulStatusCodes().subscribe { (response) in
                self.responseSuccess(observer, requestData: response.data)
            } onError: { (err) in
                self.responseFailure(observer, error: err)
            }.disposed(by: disposebag)
            return Disposables.create()
        }
    }
    
    /// 返回结果是 [String:Any]的请求
    open func reqDataDicObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqDicResult> {
        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
            .asObservable().flatMap({ val -> Observable<ReqDicResult> in
                return Observable.just(ReqDicResult.init(val))
            })
    }
    
    /// 返回结果是 [[String:Any]]的请求
    open func reqDataArrayObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqArrResult> {
        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
            .asObservable().flatMap({ val -> Observable<ReqArrResult> in
                return Observable.just(ReqArrResult.init(val))
            })
    }
    
    
    /// 分页的网络请求处理
    open func reqPageArrayObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqPageArrResult> {
        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
            .asObservable().flatMap({ val -> Observable<ReqPageArrResult> in
                return Observable.just(ReqPageArrResult.init(val))
            })
    }
    
    /// 返回结果是 String的请求
    open func reqDataStrObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqStrResult> {
        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
            .asObservable().flatMap({ val -> Observable<ReqStrResult> in
                return Observable.just(ReqStrResult.init(val))
            })
    }
}
//
//extension NSObject {
//    open func responseSuccess(_ observer:AnyObserver<ReqResult>, requestData:Data) {
//        let result = ReqResult.init(requestData: requestData)
//        if result.code != 1 {
//            observer.onError(NSError.init(domain: result.message, code: result.code, userInfo: nil))
//            return
//        }
//
//        if result.code == -4 {
//            observer.onError(NSError.init(domain: "token失效 设备在别处登录", code: result.code, userInfo: nil))
//            AppDelegate.jumpLogin()
//            return
//        }
//
//        observer.onNext(result)
//        observer.onCompleted()
//    }
//
//    open func responseFailure(_ observer:AnyObserver<ReqResult>, error:Error) {
//        debugPrint("HTTP请求错误")
//        observer.onError(NSError.init(domain: "\(error)", code: -404, userInfo: nil))
//    }
//
//    open func createRequestObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposebag:DisposeBag, _ urlparams:[String:Any]? = nil) -> Observable<ReqResult> {
//        return Observable<ReqResult>.create {
//            observer -> Disposable in
//            Provider.rx.request(.request(body:body, path:path, methodType:methodType, urlparams: urlparams)).filterSuccessfulStatusCodes().subscribe { (response) in
//                self.responseSuccess(observer, requestData: response.data)
//            } onError: { (err) in
//                self.responseFailure(observer, error: err)
//            }.disposed(by: disposebag)
//            return Disposables.create()
//        }
//    }
//
//    open func reqDataDicObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqDicResult> {
//        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
//            .asObservable().flatMap({ val -> Observable<ReqDicResult> in
//                return Observable.just(ReqDicResult.init(val))
//            })
//    }
//
//    open func reqDataArrayObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqArrResult> {
//        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
//            .asObservable().flatMap({ val -> Observable<ReqArrResult> in
//                return Observable.just(ReqArrResult.init(val))
//            })
//    }
//
//    open func reqPageArrayObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqPageArrResult> {
//        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
//            .asObservable().flatMap({ val -> Observable<ReqPageArrResult> in
//                return Observable.just(ReqPageArrResult.init(val))
//            })
//    }
//
//    open func reqDataStrObserver(body: [String:Any]? = nil, path:String? = nil, methodType: Moya.Method? = nil, disposeBag:DisposeBag, _ urlParams:[String:Any]? = nil) -> Observable<ReqStrResult> {
//        return self.createRequestObserver(body: body, path: path, methodType: methodType, disposebag: disposeBag, urlParams)
//            .asObservable().flatMap({ val -> Observable<ReqStrResult> in
//                return Observable.just(ReqStrResult.init(val))
//            })
//    }
//}
