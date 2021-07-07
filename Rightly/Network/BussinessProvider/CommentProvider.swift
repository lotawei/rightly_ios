//
//  CommentProvider.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import Foundation
import RxSwift
import Moya
import RxCocoa

class CommentProvider: NetworkRequest {
    
    /// 提交评论
    /// - Parameters:
    ///   - targetId: 指定动态id
    ///   - commentLevel: 评论等级 1.一级评论 2.一级评论的回复 3.回复的回复
    ///   - content: 评论内容
    ///   - replyCommentId: 二级三级需要填回复的评论id
    ///   - atUserList: @user 列表
    func postComment(_ targetId:String, _ commentLevel:Int, _ content:String, replyCommentId:String? = nil, atUserList:[Dictionary<String, String>]? = nil, _ disposebag:DisposeBag) -> Observable<ReqResult> {
        var body:[String:Any] = ["type":1, "targetId":targetId, "commentLevel":commentLevel, "content":content]
        if let replyId = replyCommentId {
            body["replyCommentId"] = replyId
        }
        
        if let atUser = atUserList {
            body["atUserList"] = atUser
        }
        
        return self.createRequestObserver(body: body, path: "comment", methodType: .post, disposebag: disposebag, nil)
    }
    
    /// 获取评论列表
    /// - Parameters:
    ///   - targetId: 获取指定动态id的评论
    ///   - createdAt: 上次获取评论最后的时间戳，用于过滤数据，防止分页异常
    func requestCommentList(_ targetId:String, _ pageNum:Int, _ pageSize:Int = 10, disposebag:DisposeBag) -> Observable<ReqPageArrResult> {
        let body:[String:Any] = ["type":1, "targetId":targetId, "pageNum":pageNum, "pageSize":pageSize]
        return self.reqPageArrayObserver(body: body, path: "comment/list", methodType: .get, disposeBag: disposebag, nil)
    }
    
    /// 获取回复列表
    /// - Parameters:
    ///   - commentId: 评论的Id
    ///   - createdAt: 上次获取评论最后的时间戳，用于过滤数据，防止分页异常
    func requestReplyList(_ commentId:String, _ pageNum:Int, _ pageSize:Int = 10, disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["commentId":commentId, "pageNum":pageNum, "pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "comment/reply/list", methodType: .get, disposebag: disposebag, nil)
    }
    
}
