//
//  GreetInfoGreetViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import UIKit
import KakaJSON
import NIMSDK

class GreetInfoGreetTaskAttachmentViewModel: GreetInfoGreetViewModel {
    override func encode() -> String {
        var result:Dictionary<String, Any> = Dictionary.init()
        result["type"] = "greeting_with_task"
        result["msg"] = self.model?.kj.JSONString()
        let jsonStr = self.model?.kj.JSONString() ?? ""
        let encodeStr = "{\"type\":\"greeting_with_task\",\"msg\":" + jsonStr + "}"
        return encodeStr
    }
}

class GreetInfoGreetGreetAttachmentViewModel: GreetInfoGreetViewModel {
    override func encode() -> String {
        var result:Dictionary<String, Any> = Dictionary.init()
        result["type"] = "greeting_with_greeting"
        result["msg"] = self.model?.kj.JSONString()
        let jsonStr = self.model?.kj.JSONString() ?? ""
        let encodeStr = "{\"type\":\"greeting_with_greeting\",\"msg\":" + jsonStr + "}"
        return encodeStr
    }
}

class GreetInfoGreetViewModel: NSObject {
    fileprivate var model:GreetInfoGreetModel?
    
    var greetingId:String?
    var taskId:String?
    var userId:String?
    var toUserId:String?
    var greetContent:String? //打招呼的内容
    var oriGreetContent:String? //原始打招呼的内容
    var firstContent:String? //同意打招呼的第一句话
    var oriCreatAt:String?   //原始的服务器时间(毫秒)
    var creatTimestamp:TimeInterval = 0.0 //转化为时间戳(毫秒)
    var creatDate:Date?    //转化为时间
    var updateTimestamp:TimeInterval = 0.0 //转化为时间戳(毫秒)
    var updateDate:Date?    //转化为时间
    var oriTaskTime:String?   //原始的服务器时间(毫秒)
    var taskTimestamp:TimeInterval = 0.0 //转化为时间戳(毫秒)
    var taskDate:Date?    //转化为时间
    var isFriended:Bool = false
    var taskInfo:TaskBrief?
    var resources:[ResourceViewModel]?
    init(jsonData: [String: Any]) {
        super.init()
        self.model = jsonData.kj.model(GreetInfoGreetModel.self)
        self.userId = self.model?.userId
        self.toUserId = self.model?.toUserId
        self.greetingId = self.model?.greetingId
        self.taskId = self.model?.taskId
        self.firstContent = self.model?.allowContent
        self.oriGreetContent = self.model?.content
        
        var content = self.model?.content ?? ""
        if content.isEmpty {
            content = self.model?.task?.descriptionField ?? ""
        }
        self.greetContent = content
        
        self.oriCreatAt = self.model?.createdAt
        self.creatTimestamp = TimeInterval(self.model?.createdAt ?? "0.0") ?? 0.0
        self.creatDate = Date.init(timeIntervalSince1970: (self.creatTimestamp >= maxTimeStamp ? (self.creatTimestamp / 1000) : self.creatTimestamp))
        self.updateTimestamp = TimeInterval(self.model?.updatedAt ?? "0.0") ?? 0.0
        self.updateDate = Date.init(timeIntervalSince1970: (self.updateTimestamp >= maxTimeStamp ? (self.updateTimestamp / 1000) : self.updateTimestamp))
        
        self.oriTaskTime = self.model?.task?.createdAt?.description
        self.taskTimestamp = TimeInterval(self.oriTaskTime ?? "0.0") ?? 0.0
        self.taskDate = Date.init(timeIntervalSince1970: (self.taskTimestamp >= maxTimeStamp ? (self.taskTimestamp / 1000) : self.taskTimestamp))
        
        self.isFriended = self.model?.status == 1
        self.taskInfo = self.model?.task
        self.resources = []
        
        for tempResource in self.model?.resourceList ?? [] {
            let tempViewModel = ResourceViewModel.init(tempResource)
            self.resources?.append(tempViewModel)
        }
    }
    
    /// 同意打招呼 变为好友
    /// - Parameter agreeMessage: 同意时发动的信息
    func agreeGreeting(_ agreeMessage:String, userId:Int64?) {
        self.model?.status = 1
        self.model?.allowContent = agreeMessage
        self.isFriended = self.model?.status == 1
        self.firstContent = agreeMessage
    }
    
    func conversionJsonData() -> Dictionary<String, Any> {
        return self.model?.kj.JSONObject() ?? ["":""]
    }
}

extension GreetInfoGreetViewModel: NIMCustomAttachment {
    func encode() -> String {
        let jsonStr = self.model?.kj.JSONString() ?? ""
        let encodeStr = "{\"type\":\"GREETING\",\"msg\":" + jsonStr + "}"
        return encodeStr
    }
}
