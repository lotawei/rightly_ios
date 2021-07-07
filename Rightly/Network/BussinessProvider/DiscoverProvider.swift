//
//  DiscoverProvider.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/25.
//

import Foundation
import RxSwift
import RxCocoa

/// 发现界面相关
class DiscoverProvider:NetworkRequest {
    /// 获取发现 话题和推荐
    /// - Parameters:
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - type: <#type description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func disCoverPageData(_ pageNum:Int = 1 ,_ pageSize:Int = 10,type:DisCoverType ,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        if type == .topic {
            return  disCoverTopicPageData(pageNum,pageSize, disposebag)
        }else{
            return  disCoverRecommendPageData(pageNum,pageSize, disposebag)
        }
    }
    
    
    /// 获取话题列表
    /// - Parameters:
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func disCoverTopicPageData(_ pageNum:Int = 1 ,_ pageSize:Int = 10,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["pageNum":pageNum,"pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "greeting/topic_page", methodType: .get, disposebag: disposebag)
    }
    
    /// 获取推荐列表
    /// - Parameters:
    ///   - pageNum: <#pageNum description#>
    ///   - pageSize: <#pageSize description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func disCoverRecommendPageData(_ pageNum:Int = 1 ,_ pageSize:Int = 10,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body:[String:Any] = ["pageNum":pageNum,"pageSize":pageSize]
        return self.createRequestObserver(body: body, path: "greeting/select/topics", methodType: .get, disposebag: disposebag)
    }
    
    /// 获取话题详情
    /// - Parameters:
    ///   - topicId: <#topicId description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: description
    func topicDetailInfo(_ topicId:Int64 ,_ disposebag:DisposeBag) -> Observable<ReqResult> {
        let body = ["topicId":topicId]
        return self.createRequestObserver(body: body, path: "greeting/topic", methodType: .get, disposebag: disposebag)
    }
    
    /// 获取系统话题
    /// - Parameter disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func gainTopicselectData(_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        return self.reqDataArrayObserver( path: "greeting/select/topics", methodType: .get, disposeBag: disposebag)
    }
    
    /// 话题排行榜接口
    /// - Parameters:
    ///   - topicId: 话题ID
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func topicRankInfo(_ topicId:Int64,_ disposebag:DisposeBag , _ responseSeverDate:((_ date:Date)->Void)? = nil) -> Observable<ReqArrResult> {
        let body = ["topicId":topicId]
        return self.reqDataArrayObserver(body: body, path: "greeting/topic/rank", methodType: .get, disposeBag: disposebag)
    }
    
    /// 给动态投票
    /// - Parameters:
    ///   - greetingId:
    ///   - votetype: 1 支持 2 不支持
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func voteTopic(greetingId:Int64,votetype:VoteType,_ disposebag:DisposeBag) -> Observable<ReqStrResult> {
        let  body:[String:Any] = ["greetingId":greetingId,"voteType":votetype.rawValue]
        return self.reqDataStrObserver(body: body, path: "greeting/vote", methodType: .post, disposeBag: disposebag)
    }
    
    /// 获取匹配投票动态
    /// - Parameters:
    ///   - topicId: <#topicId description#>
    ///   - size: <#size description#>
    ///   - disposebag: <#disposebag description#>
    /// - Returns: <#description#>
    func gainVoteUserTopic(topicId:Int64,size:Int,_ disposebag:DisposeBag) -> Observable<ReqArrResult> {
        let body:[String:Any] = ["topicId":topicId,"size":size]
        return self.reqDataArrayObserver(body: body, path: "greeting/topic/match", methodType: .get, disposeBag: disposebag)
    }
}


extension  DiscoverProvider {
    func requestNormalTagRelationTopic(_ tagId:Int64,disposebag:DisposeBag,_ relationresult:@escaping((_ model:DiscoverTopicModel?)->Void)){
        let body:[String:Any] = ["tagId":tagId]
        self.createRequestObserver(body: body, path:"greeting/getTopicByTagId", methodType: .get, disposebag: disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            var  relationTopic:DiscoverTopicModel?=nil
            if let dicData = res.data as? [String:Any] {
                relationTopic = dicData.kj.model(DiscoverTopicModel.self)
            }
            relationresult(relationTopic)
        }).disposed(by: disposebag)
    }
}
