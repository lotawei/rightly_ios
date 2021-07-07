//
//	Task.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import KakaJSON

class HotResultData:Convertible {
    required init(){
        
    }
    var  results:[TaskBrief]? = nil
}

class RandomEncodeValue:Convertible {
    
    var  videotasks:[TaskBrief] = []
    var  voicetasks:[TaskBrief] = []
    var  phototasks:[TaskBrief] = []
    enum CodingKeys: String, CodingKey {
        case voicetasks = "2"
        case phototasks = "3"
        case videotasks = "4"
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "voicetasks":
            return "2"
        case "phototasks":
            return "3"
        case "videotasks":
            return "4"
        default:
            return property.name
        }
    }
    
    func kj_JSONKey(from property: Property) -> JSONPropertyKey {
        switch property.name {
        case "voicetasks":
            return "2"
        case "phototasks":
            return "3"
        case "videotasks":
            return "4"
        default:
            return property.name
        }
    }
    required init(){
        
    }
}
class TaskBrief :Convertible {
    var createdAt : Int64? = nil
	var descriptionField : String? = nil
    var isSystem : Bool? = nil
    var type : TaskType = .noLimit
    var taskId:Int64? = nil
    var hotNum:Int? = nil
    var upddatedAt:Int? = nil
    var lastMonthHotNum:Int? = nil
    var recommendNum:Int? = nil
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "descriptionField":
            return "description"
        default:
            return property.name
        }
    }
    
    func kj_JSONKey(from property: Property) -> JSONPropertyKey {
        switch property.name {
        case "descriptionField":
            return "description"
        default:
            return property.name
        }
    }
    
    required  init() {
        
    }
}
//热门样式的任务随机
let  sizehottaskHeight:CGFloat = 110
extension TaskBrief:RTWaterLayoutModelable {
    var size: CGSize {
        if let  str = self.descriptionField {
            let minw:CGFloat = scaleWidth(190)
            let maxw:CGFloat = scaleWidth(296)
            let width:CGFloat = str.width(font: UIFont.systemFont(ofSize: 14), lineBreakModel: .byWordWrapping, maxWidth: maxw, maxHeight: 50 )
            let  w = width > minw ? width:minw
            let  randw = self.randomWaterWidth(w, maxw)
            return CGSize.init(width: randw, height: sizehottaskHeight)
        }
       
        return  CGSize.init(width: scaleWidth(190), height: sizehottaskHeight)
    }
    
    func randomWaterWidth(_ min:CGFloat, _ max:CGFloat) -> CGFloat {
        let wi = CGFloat.random(lower: min, max)
        return wi
    }
    func getTaskDesc(_ alignment:NSTextAlignment? = .left,font:CGFloat = 14) -> NSAttributedString {
        let desc = self.descriptionField ?? ""
//        let desc = "空间空间啊手机看的就卡死控件大家看到啊空间数据库大健康四大皆空AK九十多斤卡数控刀具😂😂"//测试的
        let attach = NSTextAttachment.init()
        attach.image = UIImage(named: self.type.typeTitleIconName())
        attach.bounds = CGRect.init(x: 0, y:-2, width: font, height: font)
        let makeattachstr = NSAttributedString.init(attachment: attach)
        let paragraphstyle = NSMutableParagraphStyle.init()
        paragraphstyle.alignment = alignment ?? .left
        let resultStr = NSMutableAttributedString.init(attributedString: makeattachstr)
        let descAtt = NSAttributedString.init(string: desc, attributes:
                                                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font),
                                                 NSAttributedString.Key.foregroundColor : UIColor.black,
                                                 NSAttributedString.Key.paragraphStyle:paragraphstyle])
        resultStr.append(descAtt)
        return resultStr
    }
    
    func getTaskNoTaskImageDesc(_ alignment:NSTextAlignment? = .left,font:CGFloat = 14) -> NSAttributedString {
        let desc = self.descriptionField ?? ""
//        let desc = "空间空间啊手机看的就卡死控件大家看到啊空间数据库大健康四大皆空AK九十多斤卡数控刀具😂😂"//测试的
        let makeattachstr = NSAttributedString.init()
        let paragraphstyle = NSMutableParagraphStyle.init()
        paragraphstyle.alignment = alignment ?? .left
        let resultStr = NSMutableAttributedString.init(attributedString: makeattachstr)
        let descAtt = NSAttributedString.init(string: desc, attributes:
                                                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font),
                                                 NSAttributedString.Key.foregroundColor : UIColor.black,
                                                 NSAttributedString.Key.paragraphStyle:paragraphstyle])
        resultStr.append(descAtt)
        return resultStr
    }

}
