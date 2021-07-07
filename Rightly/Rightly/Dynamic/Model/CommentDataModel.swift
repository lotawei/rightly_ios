//
//  CommentDataModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import Foundation
import KakaJSON


/// @用户信息
class CommentAtUser: Convertible {
    let offset:String = ""
    let userId:String = ""
    
    required init() {
    }
}

/// 回复评论
class ReplyCommentModel: Convertible {
    let commentId:String = ""
    let userId:String = ""
    let type:Int = -1   // 评论的类型 1.动态
    let targetId:String = ""
    let content:String = ""
    let commentLevel:Int = -1
    let topCommentId:String = ""
    let replyCommentId:String = ""
    let replyUserId:String = ""
    var replyNum:Int = -1 // 回复数
    var likeNum:Int = -1 //like数
    var atUser:[CommentAtUser] = []
    let createdAt:TimeInterval = -1
    let updatedAt:TimeInterval = -1
    var isLike:Bool = false
    var user:UserAdditionalInfo? = nil  // 发表评论用户信息
    var replyUser:UserAdditionalInfo? = nil //回复的是谁
    
    required init() {
    }
}

/// 评论
class CommentDataModel : Convertible {
    let commentId:String = ""
    let userId:String = ""
    let type:Int = -1   // 评论的类型 1.动态
    let targetId:String = ""    // 评论属于那条动态的Id
    let content:String = ""
    let commentLevel:Int = -1
    var replyNum:Int = -1 // 回复数
    var likeNum:Int = -1 //like数
    var atUser:[CommentAtUser] = []
    let createdAt:TimeInterval = -1
    let updatedAt:TimeInterval = -1
    var isLike:Bool = false
    var user:UserAdditionalInfo? = nil  // 发表评论用户信息
    required init() {
    }
}
