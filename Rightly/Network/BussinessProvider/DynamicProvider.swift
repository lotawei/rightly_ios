//
//  DynamicProvider.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/28.
//

import Foundation
import RxSwift
import Moya
import RxCocoa

class DynamicProvider:NetworkRequest {
    
    /// 请求动态列表
    /// - Parameters:
    ///   - type: 列表类型
    ///   - parameter: 参数 userId/topicId/nil
    func requestDynamicList(_ type:DynamicListType, parameter:String, _ pageNum:Int, pageSize:Int = 3, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        switch type {
        case .topic:
            if parameter.isEmpty {
                return self.requestTopicDynamicList(pageNum, pageSize, disposebag)
            } else {
                return self.requestTopicDynamicList(topicId: parameter, pageNum, pageSize, disposebag)
            }
        case .likes:
            return self.requestLikesDynamicList(parameter, pageNum, pageSize, disposebag)
        case .myDynamics:
            return self.requestMyDynamicList(pageNum, pageSize: pageSize, disposebag)
        case .otherDynamics:
            return self.requestOtherDynamicList(parameter, pageNum, pageSize, disposebag)
        }
    }
    
    /// 某个主题下的动态
    /// - Parameters:
    ///   - topicId: 主题id，可以不传表示动态推荐
    private func requestTopicDynamicList(topicId:String? = nil, _ pageNum:Int, _ pageSize:Int, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        var body:[String:Any] = ["pageNum":pageNum, "pageSize":pageSize]
        if let tempId = topicId {
            body["topicId"] = tempId
        }
        
        return self.createRequestObserver(body: body, path: "greeting/topic/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 请求点赞的打招呼列表
    /// - Parameters:
    ///   - userId: 请求的用户id
    private func requestLikesDynamicList(_ userId:String, _ pageNum:Int, _ pageSize:Int, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["userId":userId, "pageNum":pageNum, "pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "greeting/like/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 请求我的打招呼列表
    private func requestMyDynamicList( _ pageNum:Int, pageSize:Int = 10, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["pageNum":pageNum, "pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "greeting/owner/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 请求他人打招呼列表
    /// - Parameters:
    ///   - userId: 他人用户id
    private func requestOtherDynamicList(_ userId:String, _ pageNum:Int, _ pageSize:Int, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["userId":userId, "pageNum":pageNum, "pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "greeting/someone/list", methodType: .get, disposebag: disposebag, nil)
    }
    
    /// 删除打招呼动态
    /// - Parameters:
    ///   - greetingId: 打招呼id
    func deleteDynamic(_ greetingId:String, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["greetingId":greetingId]
        return self.createRequestObserver(body: body, path: "greeting/delete", methodType: .delete, disposebag: disposebag, nil)
    }
    
    /// 置顶打招呼动态
    /// - Parameters:
    ///   - greetingId: 打招呼id
    ///   - topType: 1.置顶  0:取消置顶
    func topDynamic(_ greetingId:String, _ topType:Int, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["greetingId":greetingId, "topType":topType]
        return self.createRequestObserver(body: body, path: "greeting/top", methodType: .put, disposebag: disposebag, nil)
    }
    
    
    /// 请求招呼(动态详情)
    /// - Parameters:
    ///   - greetingId: 打招呼id
    func requestDynamicDetail(_ greetingId:String, _ disposebag:DisposeBag) -> Observable<ReqDicResult> {
        let body:[String:Any] = ["greetingId":greetingId]
        return self.reqDataDicObserver(body: body, path: "greeting/details", methodType: .get, disposeBag: disposebag, nil)
    }
}

