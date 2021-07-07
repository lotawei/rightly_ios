//
//  NIMAttachmentDecode.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/7.
//

import Foundation
import NIMSDK

class NIMAttachmentObj: NSObject, NIMCustomAttachment {
    var type:String?
    var jsonData:Any?
    func encode() -> String {
        if jsonData is Array<Any> {
            let jsonObj = jsonData as? Array<Any>
            let jsonStr = "{\"type\":\(String(describing: type)), \"msg\":\(String(describing: jsonObj?.description))}"
            return jsonStr
        } else {
            let jsonObj = jsonData as? Dictionary<String, Any>
            let jsonStr = "{\"type\":\(String(describing: type)), \"msg\":\(String(describing: jsonObj?.description))}"
            return jsonStr
        }
    }
}
class NIMAttachmentDecode: NSObject, NIMCustomAttachmentCoding {
    func decodeAttachment(_ content: String?) -> NIMCustomAttachment? {
        guard let jsonData = content?.data(using: .utf8) else {
            debugPrint("解析Attachment错误")
            return nil
        }
        
        var resultJSONData:[String : Any]?
        do {
            resultJSONData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String : Any]
        } catch {
            debugPrint("Attachment数据解析JSON错误")
            return nil
        }
        
        let attType:String = resultJSONData?["type"] as? String ?? ""
        
        let resultObj = NIMAttachmentObj.init()
        resultObj.type = attType.lowercased()
        resultObj.jsonData = resultJSONData?["msg"]
        
        return resultObj
    }
}

