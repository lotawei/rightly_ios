//
//  DiscoverTopicModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/25.
//

import Foundation
enum ToicType:Int,ConvertibleEnum{
    case anyType = 0 , //不限
         text = 1, //文本
         voice = 2, //语音
         photo = 3 , //图片
         video = 4 //视频
}
struct DisCoverResetApiDataModel: Convertible{
    var results:[DiscoverTopicModel]? = nil
}

/// 话题模型
struct DiscoverTopicModel:Convertible{
    var banner : String? = nil
    var greetings : [DisCoverGreeting]? = nil
    var hotNum : Int? = nil
    var isMatch : Bool? = nil
    var name : String? = nil
    var peopleNum : Int? = 0
    var simpleDescription : String? = ""
    var topicId : Int64 = 0
    var type:ToicType = .anyType
    var createdAt:Int64? = nil
    var updatedAt:Int64? = nil
    var lastMonthHotNum:Int64? = nil //最近热度
    var recommendNum:Int64? =  nil//推荐排序号
    var  isselected:Bool = false
    var isJoin:Bool? = nil
    var matchStartAt:Int64? = nil
    var matchEndAt:Int64? = nil
    var infodescription:String? = nil
    var isMatchEnd:Bool? = nil
    enum CodingKeys: String, CodingKey {
        case banner = "banner"
        case greetings
        case hotNum = "hotNum"
        case isMatch = "isMatch"
        case name = "name"
        case peopleNum = "peopleNum"
        case simpleDescription = "simpleDescription"
        case topicId = "topicId"
        case type = "type"
        case lastMonthHotNum
        case recommendNum
        case createdAt
        case updatedAt
        case isJoin
        case matchStartAt
        case matchEndAt
        case infodescription = "description"
        case isMatchEnd
    }
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "infodescription":
            return "description"
        default:
            return property.name
        }
    }
    func kj_JsonKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "infodescription":
            return "description"
        default:
            return property.name
        }
    }
}
extension ToicType {
    func mapTaskType() -> TaskType {
        switch self {
        case .voice:
            return .voice
        case .photo:
            return .photo
        case .video:
            return .video
        default:
            return .photo
        }
    }
}
struct DisCoverGreeting : Convertible {
    var greetingId : Int64? = nil
    var resourceList : [GreetingResourceList]? = nil
    var taskType : TaskType = .photo
    var userId : Int64? = nil
}
