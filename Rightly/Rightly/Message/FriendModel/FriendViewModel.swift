//
//  FriendViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/30.
//

import UIKit

enum FriendType:Int {
    case irrelevant = 0 //无关系
    case toMe = 1   //和我打过招呼
    case fromMe = 2 //我打过招呼
    case friended = 3  //已经是好友
}

enum UserGender:Int {
    case secret = 0
    case boy = 1
    case girl = 2
}

//struct UserTask {
//    var taskId:String?
//    var taskType:TaskType?
//    var taskDesc:String?
//    var isSystem:Bool?
//    var oriCreatedAt:String?   //原始的服务器时间(毫秒)
//    var createdTimestamp:TimeInterval = 0.0 //转化为时间戳(毫秒)
//    var createdDate:Date?    //转化为时间
//    init(_ model:TaskBrief) {
//        self.taskId = model.taskId?.description
//        self.taskType = model.type
//        self.taskDesc = model.descriptionField
//        self.isSystem = model.isSystem
//    }
//
//}

//struct GreetResource {
//    var duration:Double = 0
//    var previewURL:URL?
//    var resourceURL:URL?
//
//    init(_ model:GreetingResourceList) {
//        let
//        self.duration = ((model.duration ?? 0) > 200 ? )
//        self.previewURL = URL.init(string: model.previewUrl.dominFullPath())
//        self.resourceURL = URL.init(string: model.url.dominFullPath())
//    }
//}

//struct GreetUserInfo {
//    var userId:String?
//    var nickName:String?
//    var headURL:URL?
//    var accId:String?
//    var gender:UserGender?
//    init(_ model:UserAdditionalInfo) {
//        self.userId = model.userId
//        self.nickName = model.nickname
//        self.headURL = URL.init(string: model.avatar.dominFullPath())
//        self.accId = model.imAccId
//        self.gender = UserGender.init(rawValue: model.gender)
//    }
//}

class FriendViewModel: NSObject {
    private var model:FriendModel?
    
    var userId:String?
    var accId:String?
    var fromUserId:String?
    var toUserId:String?
    
    var greetingId:String?
    var taskId:String?
    var firstJson:String? //与好友建立关系时发送的第一条消息
    var greetContent:String? //打招呼的内容
    var oriUpdateAt:String?   //原始的服务器时间(毫秒)
    var updateTimestamp:TimeInterval = 0.0 //转化为时间戳(毫秒)
    var updateDate:Date?    //转化为时间
    var isFriended:Bool = false
    var userInfo:UserAdditionalInfo?
    var taskInfo:TaskBrief?
    var resources:[ResourceViewModel]?
    
    init(jsonData:[String:Any]) {
        super.init()
        self.model = jsonData.kj.model(FriendModel.self)
        self.userId = self.model?.user?.userId?.description
        self.accId = self.model?.user?.imAccId
        self.fromUserId = self.model?.userId
        self.toUserId = self.model?.toUserId
        self.greetingId = self.model?.greetingId
        self.taskId = self.model?.taskId
        self.firstJson = self.model?.allowContent
        self.greetContent = self.model?.content
        if  (self.greetContent?.isEmpty ?? true) {
            self.greetContent = self.model?.task?.descriptionField
        }
        self.oriUpdateAt = self.model?.updatedAt
        self.updateTimestamp = TimeInterval(self.model?.updatedAt ?? "0") ?? 0
        self.updateDate = Date.init(timeIntervalSince1970: (self.updateTimestamp >= maxTimeStamp ? (self.updateTimestamp / 1000) : self.updateTimestamp))
        self.isFriended = self.model?.status == 1
        self.userInfo = self.model?.user
        self.taskInfo = self.model?.task
        self.resources = []
        
        for tempResource in self.model?.resourceList ?? [] {
            self.resources?.append(ResourceViewModel(tempResource))
        }
    }
}
