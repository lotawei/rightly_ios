//
//  String_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/14.
//

import Foundation

extension String {
    
    /// 获取字符串高度
    /// - Parameters:
    ///   - font: 字体
    ///   - lineBreakModel: 换行规则
    ///   - maxWidth: 最大宽度
    /// - Returns: 高度
    func height(font:UIFont, lineBreakModel:NSLineBreakMode, maxWidth:CGFloat) -> CGFloat {
        if self.isEmpty {
            return 0.0
        }
        
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineBreakMode = lineBreakModel
        let attributes = [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        let rect = NSString.init(string: self).boundingRect(with: CGSize.init(width: maxWidth, height: screenHeight), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.height + 0.5
    }
    
    func width(font:UIFont, lineBreakModel:NSLineBreakMode, maxWidth:CGFloat, maxHeight:CGFloat) -> CGFloat {
        if self.isEmpty {
            return 0.0
        }
        
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineBreakMode = lineBreakModel
        let attributes = [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        let rect = NSString.init(string: self).boundingRect(with: CGSize.init(width: maxWidth, height: maxHeight), options: .usesFontLeading, attributes: attributes, context: nil)
        return rect.width + 0.5
    }
}


extension  String {
    
    /// 获取完整的路径url
    /// - Returns:
    func  dominFullPath() -> String {
        if (self.count > 4 && self.lowercased().prefix(4) == "http") {
            return self
        }
        
        return "\(SystemManager.shared.storage?.storageBaseUrl ?? DominUrl)/\(self)"
    }
}

//时长转时分秒
extension String {
   static func transToHourMinSec(time: Float) -> String
    {
        let allTime: Int = Int(time)
        var hours = 0
        var minutes = 0
        var seconds = 0
        var hoursText = ""
        var minutesText = ""
        var secondsText = ""
        
        hours = allTime / 3600
        hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        
        minutes = allTime % 3600 / 60
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        seconds = allTime % 3600 % 60
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        return "\(hoursText):\(minutesText):\(secondsText)"
    }
    
}

extension NSAttributedString {
    func height(maxWidth:CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: maxWidth, height: 3333), options: .usesLineFragmentOrigin, context: nil)
        return rect.size.height + 0.5;
    }
    
    func width(maxWidth:CGFloat, maxHeight:CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: maxWidth, height: maxHeight), options: .usesLineFragmentOrigin, context: nil)
        return rect.width + 0.5
    }
}

extension String {
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
     static  func updateTimeToCurrennTime(timeStamp: Double) -> String {
            //获取当前的时间戳
            let currentTime = Date().timeIntervalSince1970
            
            //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
            let timeSta:TimeInterval = TimeInterval( timeStamp > maxTimeStamp ? timeStamp / 1000 : timeStamp)
            //时间差
            let reduceTime : TimeInterval = currentTime - timeSta
            //时间差小于60秒
            if reduceTime < 60 {
                return "just now".localiz()
            }
            //时间差大于一分钟小于60分钟内
            let mins = Int(reduceTime / 60)
            if mins < 60 {
                return "\(mins)" + " minutes ago".localiz()
            }
            let hours = Int(reduceTime / 3600)
            if hours < 24 {
                return "\(hours)" + " hours ago".localiz()
            }
            let days = Int(reduceTime / 3600 / 24)
            if days < 30 {
                return "\(days)" + " days ago".localiz()
            }
            //不满足上述条件---或者是未来日期-----直接返回日期
            let date = NSDate(timeIntervalSince1970: timeSta)
            let dfmatter = DateFormatter()
            //yyyy-MM-dd HH:mm:ss
            dfmatter.dateFormat="yyyy/MM/dd/ HH:mm"
            return dfmatter.string(from: date as Date)
        }
        static func  dateTransformtimeStamp(_ datestr:String) -> TimeInterval{
            let dateformat = DateFormatter.init()
            dateformat.dateFormat = "yyyy-MM-dd"
            let date = dateformat.date(from: datestr)
            return ((date?.timeIntervalSince1970 ?? 0) * 1000)
        }
}

extension NSMutableAttributedString {
    func conversionEmoji(_ font:UIFont) {
        let imageWH = font.lineHeight
        for emojiKey:String in EmojiManager.shared().emojiDatas.keys {
            guard let emojiPath = EmojiManager.shared().emojiDatas[emojiKey] else {
                continue
            }
            
            while let emojiRange = self.string.range(of: emojiKey) {
                let emojiNSRange = NSRange.init(emojiRange, in: self.string)
                let attachment:NSTextAttachment = NSTextAttachment()
                attachment.image = UIImage.init(contentsOfFile: emojiPath)
                attachment.emojiKey = emojiKey
                attachment.bounds = CGRect(x: 0, y: -3, width: imageWH, height: imageWH)
                let attachmentStr = NSAttributedString(attachment: attachment)
                self.replaceCharacters(in: emojiNSRange, with: attachmentStr)
            }
        }
        
        
//        let contentArray = self.string.components(separatedBy: "[")
//        for tempStr in contentArray.reversed() {
//            let emojiArray = tempStr.components(separatedBy: "]")
//            guard let emojiStr = emojiArray.first else {
//                continue
//            }
//
//            let emojiKey = String.init("["+emojiStr+"]")
//            guard let emojiRange = self.string.range(of: emojiKey), let emojiPath = EmojiManager.shared().emojiDatas[emojiKey] else {
//                continue
//            }
//
//            let emojiNSRange = NSRange.init(emojiRange, in: self.string)
//            let attachment:NSTextAttachment = NSTextAttachment()
//            attachment.image = UIImage.init(contentsOfFile: emojiPath)
//            attachment.emojiKey = emojiKey
//            attachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
//            let attachmentStr = NSAttributedString(attachment: attachment)
//
//            self.replaceCharacters(in: emojiNSRange, with: attachmentStr)
//        }
    }
}

