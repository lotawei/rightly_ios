//
//  DynamicDataModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import Foundation
import KakaJSON

class TopicsDataModel: Convertible {
    let topicId:String = "" //话题id
    let name:String? = nil
    let isMatch:Bool = false    //是否为比赛话题
    required init() {
    }
}

class DynamicDataModel: Convertible {
    var greetingId:String = ""
    var userId:String = ""
    var taskType:TaskType = .noLimit    // 任务类型 0/1/2/3/4 通配类型/普通文本/语音/图片/视频
    var content:String = "" // 发布内容时 用户填写介绍
    var likeNum:Int = 0
    var commentNum:Int = 0
    var createdAt:Int64 = 0
    var updatedAt:Int64 = 0
    var address:String = ""
    var lng:Float = 0.0
    var lat:Float = 0.0
    var isLike:Bool = false
    let resourceList:[GreetingResourceList] = []
    var user:UserAdditionalInfo? = nil
    var topics:[TopicsDataModel] = []
    var isMatchEnd:Bool? = false
    
    // greeting 独有数据
    var toUserId:String = ""
    var taskId:String = ""
    var status:Int = 0 // 打招呼状态 0.未通过  1.已通过 成为好友
    var viewType:ViewType = .Public
    var allowContent:String = "" //同意打招呼的第一句话
    var isRead:Bool = true  //是否已读
    let task:TaskBrief? = nil
    let isTop:Bool = false
    
    required init() {
    }
}
