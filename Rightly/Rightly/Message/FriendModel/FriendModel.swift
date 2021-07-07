//
//  FriendModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/30.
//

import UIKit
import KakaJSON

class FriendModel: NSObject, Convertible {
    var keyUserId:String = ""
    var greetingId:String = ""
    var userId:String = ""
    var toUserId:String = ""
    var taskId:String = ""
    var content:String = ""
    var allowContent:String = "" //同意的内容
    var status:Int = 0 // 0.未通过  1.已通过成为好友
    var updatedAt:String = "" //成为好友的时间,用于过滤的时间
    var task:TaskBrief?
    var user:UserAdditionalInfo?
    var resourceList:[GreetingResourceList]?
    
    required override init() {
        super.init()
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "keyUserId":
            return "user.imAccId"
        default:
            return property.name
        }
    }
}





