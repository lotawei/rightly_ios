//
//  File.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//

import Foundation
struct UserNotifyModelResetApiData : Convertible {

    var extendData : ResultExtendData? = nil
    var pageNum : Int? = nil
    var pageSize : Int? = nil
    var results : [UserNotifyModelResult]? = nil
    var total : Int? = nil
    var totalPage : Int? = nil


    enum CodingKeys: String, CodingKey {
        case extendData
        case pageNum = "pageNum"
        case pageSize = "pageSize"
        case results = "results"
        case total = "total"
        case totalPage = "totalPage"
    }
}

struct UserNotifyModelResult : Convertible {

    var content : String? = nil
    var createdAt : Int64? = nil
    var extraData : UserNotifyModelExtraData?  = nil
    var notificationId : Int?
    var notificationType : NotifycationType = .greetingwithme
    var redirectUrl : String? = nil
    var triggerUser : UserAdditionalInfo? = nil
    var triggerUserId : Int64? = nil
    var userId : Int64? = nil
}
struct ResultExtendData : Convertible {

    var  lastReadTime:Int? = nil
    
}
struct UserNotifyModelExtraData : Convertible {

    var content : String? = nil
    var greetingId : Int64?  = nil
    var resources : [UploadResponseData]? = nil
    var taskType : TaskType? = nil
}
