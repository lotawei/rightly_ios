//
//  String+Json.swift
//  DfsxAnalysis
//
//  Created by lotawei on 2020/12/4.
//

import Foundation
extension  String {
    
    //字典转json字符
    static public  func convertDictionaryToJSONString(_ dict:Any)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        guard let dt = data else {
            return ""
        }
        let jsonStr = NSString(data: dt, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    /// 转字典
    /// - Returns: <#description#>
    func convertJSONStringToDictionary() -> [String:Any]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                 print(error)
            }
        }
        return nil
    }
}

extension Data {
    
    /// data 转字典
    /// - Returns: <#description#>
    func convertJSONStringToDictionary() -> [String:Any]? {
            do {
                return try JSONSerialization.jsonObject(with: self, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                 print(error)
            }
        return nil
    }
}


extension String {
 
    // 是否包含表情
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case
            0x00A0...0x00AF,
            0x2030...0x204F,
            0x2120...0x213F,
            0x2190...0x21AF,
            0x2310...0x329F,
            0x1F000...0x1F9CF:
                return true
            default:
                continue
            }
        }
        return false
    }
 
    /**
     * 字母、数字、中文正则判断（不包括空格）
     *注意: 因为考虑到输入习惯,许多人习惯使用九宫格,这里在正常选择全键盘输入错误的时候,进行九宫格判断,九宫格对应的是下面➋➌➍➎➏➐➑➒的字符
     */
    static func isInputRuleNotBlank(str:String) -> Bool {
        let pattern = "^[a-zA-Z\\u4E00-\\u9FA5\\d]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch = pred.evaluate(with: str)
        if !isMatch {
            let other = "➋➌➍➎➏➐➑➒"
            let len = str.count
            for i in 0..<len {
                let tmpStr = str as NSString
                let tmpOther = other as NSString
                let c = tmpStr.character(at: i)
                
                if !((isalpha(Int32(c))) > 0 || (isalnum(Int32(c))) > 0 || ((Int(c) == "_".hashValue)) || (Int(c) == "-".hashValue) || ((c >= 0x4e00 && c <= 0x9fa6)) || (tmpOther.range(of: str).location != NSNotFound)) {
                    return false
                }
                return true
            }
        }
        return isMatch
    }
 
 
    // MARK: 过滤字符串中的特殊字符
    public func stringReplacingOccurrencesOfString() {
        
        let str: NSString = self as NSString
        
        let charactersInString = "[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "
        let doNotWant = CharacterSet.init(charactersIn: charactersInString)
        
        let componentsArrays = str.components(separatedBy: doNotWant)
        let hmutStr = componentsArrays.joined(separator: "")
        print("humStr is：\(hmutStr)")
    }
 
 
 
}
 


extension String {
    private static func getNormalStrSize(str: String? = nil, attriStr: NSMutableAttributedString? = nil, font: CGFloat, w: CGFloat, h: CGFloat) -> CGSize {
        if str != nil {
            let strSize = (str! as NSString).boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil).size
            return strSize
        }
        
        if attriStr != nil {
            let strSize = attriStr!.boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, context: nil).size
            return strSize
        }
        
        return CGSize.zero
       
    }
    /**获取文本字符串W*/
   static func getNormalStrW(str: String, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getNormalStrSize(str: str, font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }
    /**获取文本字符串H*/
   static func getNormalStrH(str: String, strFont: CGFloat, w: CGFloat) -> CGFloat {
        return getNormalStrSize(str: str, font: strFont, w: w, h: CGFloat.greatestFiniteMagnitude).height
    }
    /**获取富文本字符串H*/
    static func getAttributedStrH(attriStr: NSMutableAttributedString, strFont: CGFloat, w: CGFloat) -> CGFloat {
        return getNormalStrSize(attriStr: attriStr, font: strFont, w: w, h: CGFloat.greatestFiniteMagnitude).height
    }
    /**获取富文本字符串W*/
    static  func getAttributedStrW(attriStr: NSMutableAttributedString, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getNormalStrSize(attriStr: attriStr, font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }
}

extension  String {
    
    /// 将  [aa] 表情转换富文本
    /// - Parameter font:字体大小
    /// - Returns:
    func exportEmojiTransForm(_ font:UIFont = .systemFont(ofSize: 16)) -> NSAttributedString{
        let resultContent = NSMutableAttributedString.init(string: self, attributes: [NSAttributedString.Key.font : font])
        resultContent.conversionEmoji(font)
        return resultContent
    }
}
extension  NSAttributedString {
    
    /// 带表情的转换字符串
    /// - Returns:
    func exportTransFormAttibuttextView() -> String {
        let resultAttrText:NSMutableAttributedString = NSMutableAttributedString.init(attributedString: self)
        enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange.init(location: 0, length: self.length), options: .reverse) { (obj, range, point) in
            guard let tempAttachment = obj as? NSTextAttachment, let emojiKey = tempAttachment.emojiKey else {
                return
            }
            resultAttrText.replaceCharacters(in: range, with: emojiKey)
        }
        return resultAttrText.string
    }
}
