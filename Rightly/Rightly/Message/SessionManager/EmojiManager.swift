//
//  EmojiManager.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/22.
//

import Foundation

class EmojiManager: NSObject {
    struct EmojiObj:Convertible {
        var text:String?  = nil
        var fileName:String?  = nil
    }
    
    public var emojiKeys:[String] = [String]()
    public var emojiDatas:[String:String] = [String:String]()
    
    private static let staticInstance = EmojiManager()
    static func shared() -> EmojiManager {
        return staticInstance
    }
    
    private override init() {
        super.init()
        
        let emojiJsonPath = Bundle.main.path(forResource: "emoji", ofType: "json") ?? ""
        let emojiJson = try? String.init(contentsOfFile: emojiJsonPath)
        
        let emojiList = emojiJson?.data(using: .utf8)?.kj.modelArray(EmojiObj.self)
        guard let emojiArray = emojiList else {
            return
        }
        
        let emojiBundlePath = Bundle.main.path(forResource: "emoji", ofType: "bundle")
        for tempEmojiObj in emojiArray {
            guard let emojiKey = tempEmojiObj.text, let emojiFileName = tempEmojiObj.fileName else {
                continue
            }
            
            var tempEmojiBundlePath = emojiBundlePath
            tempEmojiBundlePath?.append(contentsOf: "/" + emojiFileName)
            self.emojiDatas[emojiKey] = tempEmojiBundlePath
            self.emojiKeys.append(emojiKey)
        }
    }
}

