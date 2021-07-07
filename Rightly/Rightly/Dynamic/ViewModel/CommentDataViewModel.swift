//
//  CommentDataViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import Foundation
import RxCocoa
import RxSwift

enum CommentLevelType: Int {
    case comment = 1  //1级评论
    case reply = 2    //2级评论
    case replyToReplay = 3    //3级评论
}

struct atUserStruct {
    let userId:String
    let offset:String
}

class CommentAtUserViewModel {
    private let model:CommentAtUser
    let startIndex:Int
    let endIndex:Int
    let userId:String
    
    init(_ model:CommentAtUser) {
        self.model = model
        
        self.userId = self.model.userId
        
        let offsetArray = self.model.offset.components(separatedBy: "-")
        if offsetArray.count == 2 {
            self.startIndex = Int(offsetArray.first ?? "0") ?? 0
            self.endIndex = Int(offsetArray.last ?? "0") ?? 0
        } else {
            self.startIndex = 0
            self.endIndex = 0
        }
    }
    
    func conversionToStruct() -> Dictionary<String, String> {
        return ["userId":self.userId, "offset":"\(self.startIndex)-\(self.endIndex)"]
    }
}

// 2,3级评论
class ReplyCommentViewModel {
    private let model:ReplyCommentModel
    
    let commentId:String
    var levelType:CommentLevelType = .reply
    let content:String
    var atUsers:[CommentAtUserViewModel] = []
    let userId:String
    let userName:String
    let userHeadURL:URL?
    let replyUserId:String
    let replyUserName:String
    let replyHeadURL:URL?
    
    var cellHeight:CGFloat = 0
    
    var timeDesc:String {
        get {
            return String.updateTimeToCurrennTime(timeStamp: self.model.createdAt)
        }
    }
    
    init(_ jsonData:[String:Any]) {
        self.model = jsonData.kj.model(ReplyCommentModel.self)
        
        self.commentId = self.model.commentId
        self.levelType = CommentLevelType.init(rawValue: self.model.commentLevel) ?? .reply
        self.content = self.model.content
        
        let defUserId = self.model.userId
        self.userId = self.model.user?.userId?.description ?? defUserId
        self.userName = self.model.user?.nickname ?? ""
        self.userHeadURL = URL(string: self.model.user?.avatar?.dominFullPath() ?? "")
        
        let defReplyUserId = "0"
        self.replyUserId = self.model.replyUser?.userId?.description ?? defReplyUserId
        self.replyUserName = self.model.replyUser?.nickname ?? ""
        self.replyHeadURL = URL(string: self.model.replyUser?.avatar?.dominFullPath() ?? "")
        
        for tempAtUser in self.model.atUser {
            let atUserViewModel = CommentAtUserViewModel.init(tempAtUser)
            self.atUsers.append(atUserViewModel)
        }
        
        let contentH = self.content.height(font: .systemFont(ofSize: 16), lineBreakModel: .byWordWrapping, maxWidth: (screenWidth - 128))
        self.cellHeight = contentH + 52
    }
}

//1级评论
class CommentDataViewModel {
    private let disposeBag = DisposeBag()
    private let model:CommentDataModel
    
    let commentId:String
    var levelType:CommentLevelType = .comment
    let content:String
    var atUsers:[CommentAtUserViewModel] = []
    let userId:String
    let userName:String
    let userHeadURL:URL?

    var pageNum = 1;
    
    var replyNum: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var replyDatas: BehaviorRelay<[ReplyCommentViewModel]> = BehaviorRelay<[ReplyCommentViewModel]>(value: [])
    var loading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var replyIsOver: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)    /// 是否已经没有更多回复了
    
    var cellHeight:CGFloat = 0
    
    var timeDesc:String {
        get {
            return String.updateTimeToCurrennTime(timeStamp: self.model.createdAt)
        }
    }
    
    init(_ jsonData:[String:Any]) {
        self.model = jsonData.kj.model(CommentDataModel.self)
        
        self.commentId = self.model.commentId
        self.levelType = .comment
        self.content = self.model.content
        self.replyNum.accept(self.model.replyNum)
        
        let defUserId = self.model.userId
        self.userId = self.model.user?.userId?.description ?? defUserId
        self.userName = self.model.user?.nickname ?? ""
        self.userHeadURL = URL(string: self.model.user?.avatar?.dominFullPath() ?? "")
        
        for tempAtUser in self.model.atUser {
            let atUserViewModel = CommentAtUserViewModel.init(tempAtUser)
            self.atUsers.append(atUserViewModel)
        }
        
        let contentH = self.content.height(font: .systemFont(ofSize: 16), lineBreakModel: .byWordWrapping, maxWidth: (screenWidth - 80))
        self.cellHeight = contentH + 56
    }
    
    //提交 2/3 级回复
    func postComment(_ content:String, replyCommentId:String, level:Int, block: @escaping (Bool) -> Void) {
        let postContent = content
        
        CommentProvider.init().postComment(self.model.targetId, level, postContent, replyCommentId:replyCommentId, self.disposeBag)
            .subscribe(onNext:{ [weak self] (requestData) in
                guard let `self` = self else {return}
                
                if let jsonData = requestData.data as? [String : Any] {
                    let replyViewModel = ReplyCommentViewModel.init(jsonData)
                    var resultDatas = self.replyDatas.value
                    
                    if !resultDatas.contains(where: { (tempViewModel) in
                        return tempViewModel.commentId == replyViewModel.commentId
                    }) {
                        if self.replyIsOver.value {
                            resultDatas.append(replyViewModel)
                        } else {
                            resultDatas.insert(replyViewModel, at: 0)
                        }
                        
                        self.replyDatas.accept(resultDatas)
                        self.replyNum.accept(max(self.replyNum.value, 0) + 1)
                    }
                }
                
                block(true)
            }, onError: { (error) in
                block(false)
            }).disposed(by: self.disposeBag)
    }
    
    
    /// 请求 2/3 级回复列表
    func requestReply(block: @escaping (Bool) -> Void) {
        self.loading.accept(true)
        CommentProvider.init().requestReplyList(self.commentId, self.pageNum, disposebag: self.disposeBag)
            .subscribe(onNext:{ [weak self] (requestData) in
                guard let `self` = self else {return}
                self.pageNum += 1
                self.loading.accept(false)
                guard let resultData = requestData.data as? [String : Any] else {
                    block(false)
                    return
                }
                
                if let results = resultData["results"] as? [[String:Any]] {
                    var tempReplyDatas = self.replyDatas.value
                    for jsonData in results {
                        let replyViewModel = ReplyCommentViewModel.init(jsonData)
                        
                        if !tempReplyDatas.contains(where: { (tempViewModel) in
                            return tempViewModel.commentId == replyViewModel.commentId
                        }) {
                            tempReplyDatas.append(replyViewModel)
                        }
                    }
                    
                    self.replyDatas.accept(tempReplyDatas)
                }
                
                if let nowPageNum = resultData["pageNum"] as? Int, let totalPage = resultData["totalPage"] as? Int {
                    if nowPageNum >= totalPage {
                        self.replyIsOver.accept(true)
                    } else {
                        self.replyIsOver.accept(false)
                    }
                }
                
                block(true)
            }, onError: { (error) in
                block(false)
            }).disposed(by: self.disposeBag)
    }
}

