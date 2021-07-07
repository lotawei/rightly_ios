//
//  MatchTaskProvider.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/8.
//

import Foundation
import  RxSwift
import Moya
import RxCocoa

/// 任务匹配招呼相关接口
class MatchTaskGreetingProvider:NetworkRequest {
    func requestMyTask(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "greeting/task/owner", methodType: .get, disposebag: disposebag, nil)
    }
    
    func requestOtherTask(_ userId:Int64, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body:["userId":userId],path:"greeting/task/someone", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 获取自己的任务
    /// - Parameter disposebag:
    /// - Returns:
    func gainUserTask(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "greeting/task/owner", methodType: .post, disposebag: disposebag)
    }
    /// 查看别人的任务
    /// - Parameters:
    ///   - userId: 用户id
    ///   - disposebag:
    /// - Returns:
    func gainOtherTask(_ userId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["userId":userId], path: "greeting/task/someone", methodType: .get, disposebag: disposebag)
    }
    /// 添加任务
    /// - Parameters:
    ///   - type: 任务类型
    ///   - desc: 任务描述
    ///   - disposebag:
    /// - Returns: <#description#>
    func addTask(_ taskId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        let req = self.createRequestObserver(body: ["taskId":taskId], path: "greeting/task/add", methodType: .post, disposebag: disposebag)
        req.subscribe(onNext: { [weak self] (res) in
            if let user = UserManager.manager.currentUser {
                              user.hasTask = true
                              UserManager.manager.saveUserInfo(user)
                              UserDefaults.standard.setValue(true, forKey: localsaveUserTaskCheck)
                              UserDefaults.standard.synchronize()
            }
        }).disposed(by:disposebag)
        return req

    }
    /// 点赞取消点赞
    /// - Parameters: 招呼id
    /// - Returns:
    func greetingLike(_ greetingId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["greetingId":greetingId], path: "greeting/like", methodType: .post, disposebag: disposebag)
    }
    /// 同意某个招呼
    /// - Parameters:
    ///   - greetingId: 招呼id
    ///   - disposebag:
    /// - Returns: <#description#>
    func allowGreeting(_ greetingId:String,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["greetingId":greetingId], path: "greeting/allow", methodType: .post, disposebag: disposebag)
    }
    /// 获取热门的任务
    /// - Parameter disposebag:
    /// - Returns:
    func getRecommendTask(_ size:Int,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["size":size], path: "greeting/task/recommend/list", methodType: .get, disposebag: disposebag)
    }
    
    /// 自己打招呼的列表
    /// - Parameters:
    func greetingOwer(_ pageNum:Int? = 10,pageSize:Int? = 1,  taskType:Int? = nil, disposebag:DisposeBag) -> Observable<ReqArrResult> {
                var body = [String:Any]()
                if let pageNum = pageNum {
                    body["pageNum"]  = pageNum
                }
                if let pageSize = pageSize {
                    body["pageSize"]  = pageSize
                }
                if let taskType = taskType {
                    body["taskType"]  = taskType
                }
        return  self.reqDataArrayObserver(body: body, path: "greeting/owner/list", methodType: .get, disposeBag: disposebag)
    }
    /// 和我打招呼的列表
    func greetingWithMe(_ pageNum:Int,pageSize:Int,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return  self.createRequestObserver(body:["pageNum":pageNum,"pageSize":pageSize], path: "greeting/withMe", methodType: .get, disposebag: disposebag)
    }
    
    /// 别人打招呼的列表
    func greetingOthers(_ pageNum:Int? = 10,pageSize:Int? = 1,  taskType:Int? = nil,userId:Int64,_ disposebag:DisposeBag) ->  Observable<ReqArrResult> {
                    var body = [String:Any]()
                    if let pageNum = pageNum {
                        body["pageNum"]  = pageNum
                    }
                    if let pageSize = pageSize {
                        body["pageSize"]  = pageSize
                    }
                    if let taskType = taskType {
                        body["taskType"]  = taskType
                    }
                    body["userId"] = userId
        return self.reqDataArrayObserver(body: body, path: "greeting/someone/list", methodType: .get, disposeBag: disposebag)
    }
    
    /// 获取匹配招呼
    func gainmatchGreeting(_ size:Int? = 4,gender:String? = nil,taskType:String? = nil,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        var  bodyDic:[String:Any] = [:]
                  if let size = size {
                      bodyDic["size"] = size
                  }
                  if let gender = gender ,!gender.isEmpty {
                      bodyDic["gender"] = gender
                  }
                  if let taskType = taskType,!taskType.isEmpty {
                      bodyDic["taskType"] = taskType
                  }
        return self.createRequestObserver(body: bodyDic, path: "greeting/matching", methodType: .get, disposebag: disposebag)
    }
    
    /// 打招呼详情
    func greetingDetail(greetingId:Int64 ,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["greetingId":greetingId], path: "greeting/details", methodType: .get, disposebag: disposebag)
    }
    /// 扣除匹配次数
    /// - Parameters:
    func matchReduceCount(matchingUerId:Int64,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["matchUserId":matchingUerId], path: "greeting/reduce/matching/num", methodType: .post, disposebag: disposebag)
    }
    
    /// 获取匹配次数
    /// - Parameters:
    ///   - type: 任务类型
    ///   - desc: 任务描述
    ///   - disposebag:
    /// - Returns:
    func matchLimitCount(_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(path: "greeting/matching/num", methodType: .get, disposebag: disposebag)
    }
    
    /// 上传经纬度
    /// - Parameter disposebag:
    /// - Returns: <#description#>
    func matchUpdateLocation(lat:Double,lng:Double,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["lat":lat,"lng":lng], path: "greeting/location", methodType: .post, disposebag: disposebag)
    }
    
    /// 随机任务
    /// - Parameters:
    ///   - size: <#size description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func taskRandom(_ size:Int,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        return self.createRequestObserver(body: ["size":size], path: "greeting/task/random", methodType: .get, disposebag: disposebag)
    }
}

