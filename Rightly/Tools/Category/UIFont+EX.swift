//
//  UIFont+EX.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/15.
//

import Foundation
enum FontCustomType:String {
    case  FZSJ_CHUSKJDAL = "FZSJ-CHUSKJDAL" //引导页自定义的字体
}
fileprivate  var  cahcheCustomName:[String:Any] = [:]
extension UIFont {
    
    /// 扩展字体自定义的
    /// - Parameters:
    ///   - size: <#size description#>
    ///   - custom: <#custom description#>
    /// - Returns: <#description#>
    static func  getSystemGuideFontFimalyName(size:CGFloat,custom:FontCustomType) -> UIFont  {
        if cahcheCustomName.isEmpty {
            let  familynames = UIFont.familyNames
            for name in familynames {
                let fontnames = UIFont.fontNames(forFamilyName: name)
                for fname in fontnames {
//                    debugPrint(fname)
                    if fname == custom.rawValue {
                        cahcheCustomName["\(custom)"] = fname
                    }
                }
            }
        }
        let customname  = cahcheCustomName["\(custom)"] as? String
        if let  fontname = customname  {
            return    UIFont.init(name: fontname, size: size) ?? UIFont.systemFont(ofSize: size)
        }
        return UIFont.systemFont(ofSize: size)
    }
}
