//
//  NSTextAttachment+Extension.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import Foundation

fileprivate var EmojiKey = "EmojiKey"
extension NSTextAttachment {
    var emojiKey: String? {
        set {
            objc_setAssociatedObject(self, &EmojiKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &EmojiKey) as? String
        }
    }
}
