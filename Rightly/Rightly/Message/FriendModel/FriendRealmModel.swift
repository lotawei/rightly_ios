//
//  FriendRealmModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/30.
//

import UIKit
import RealmSwift
import Realm

class FriendTaskDBModel: Object {
    @objc dynamic var taskId:Int64 = 0
    @objc dynamic var type:Int = 0  //任务类型，1/2/3/4 普通文本/语音/图片/视频
    @objc dynamic var desc:String = ""
    
    @objc dynamic var owner: FriendDBModel?
}

class FriendResourceDBModel: Object {
    @objc dynamic var duration:Double = 0 //秒
    @objc dynamic var previewUrl:String = ""
    @objc dynamic var url:String = ""
    
    let owners = LinkingObjects(fromType: FriendDBModel.self, property: "resourceList")
}

class FriendUserDBModel: Object {
    @objc dynamic var userId:Int64 = 0
    @objc dynamic var nickname:String = ""
    @objc dynamic var gender:Int = 0  // 1男 2女
    @objc dynamic var imAccId:String = ""
    
    @objc dynamic var owner: FriendDBModel?
}

class FriendDBModel: Object {
    @objc dynamic var keyUserId:String = ""
    @objc dynamic var greetingId:Int64 = 0
    @objc dynamic var userId:Int64 = 0
    @objc dynamic var toUserId:Int64 = 0
    @objc dynamic var taskId:Int64 = 0
    @objc dynamic var content:String = ""
    @objc dynamic var allowContent:String = "" //同意的内容
    @objc dynamic var status:Int = 0 // 0/1/2/3 0 没有关系/和我打招呼/我打的招呼/已经是好友
    @objc dynamic var updatedAt:Int64 = 0 //成为好友的时间,用于过滤的时间
    @objc dynamic var task:FriendTaskDBModel?
    @objc dynamic var user:FriendUserDBModel?
    let resourceList = List<FriendResourceDBModel>()
    
    override class func primaryKey() -> String? {
        return "keyUserId"
    }

    //防止 Realm 存储数据模型的某个属性
    override static func ignoredProperties() -> [String] {
//        return ["taskId"]
        return []
    }

    //为数据模型中需要添加索引的属性建立索引，Realm 支持为字符串、整型、布尔值以及 Date 属性建立索引。
    override static func indexedProperties() -> [String] {
//        return ["userId"]
        return []
    }
}
