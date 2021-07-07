//
//  GreetInfoGreetModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/31.
//

import UIKit
import KakaJSON

class GreetInfoGreetModel: NSObject, Convertible {
    var keyUserId:String = ""
    var greetingId:String = ""
    var userId:String = ""
    var toUserId:String = ""
    var taskId:String = ""
    var content:String = ""
    var status:Int = 0 // 0.未通过  1.已通过成为好友
    var viewType:Int = 2 // 1/2 只能自己看/公开
    var isLike:Bool = false
    var isRead:Bool = false
    var createdAt:String = ""
    var updatedAt:String = ""
    var allowContent:String = "" //打招呼的第一句话
    var task:TaskBrief?
    var resourceList:[GreetingResourceList]?
    
    required override init() {
        super.init()
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "keyUserId":
            return "user.userId"
        default:
            return property.name
        }
    }
    
    
}
