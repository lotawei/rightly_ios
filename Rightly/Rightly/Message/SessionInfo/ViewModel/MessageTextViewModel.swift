//
//  MessageTextViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import UIKit
import NIMSDK
import RxSwift
import RxCocoa


class MessageTextViewModel: MessageViewModel {
    var content:NSAttributedString? = nil

    override init(_ message: NIMMessage) {
        super.init(message)
        
        let resultContent = NSMutableAttributedString.init(string: message.text ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        resultContent.conversionEmoji(UIFont.systemFont(ofSize: 16))
//        let contentArray = message.text?.components(separatedBy: "[") ?? []
//        for tempStr in contentArray.reversed() {
//            let emojiArray = tempStr.components(separatedBy: "]")
//            guard let emojiStr = emojiArray.first else {
//                continue
//            }
//
//            let emojiKey = String.init("["+emojiStr+"]")
//            guard let emojiRange = resultContent.string.range(of: emojiKey), let emojiPath = EmojiManager.shared().emojiDatas[emojiKey] else {
//                continue
//            }
//
//            let emojiNSRange = NSRange.init(emojiRange, in: resultContent.string)
//            let attachment:NSTextAttachment = NSTextAttachment()
//            attachment.image = UIImage.init(contentsOfFile: emojiPath)
//            attachment.emojiKey = emojiKey
//            attachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
//            let attachmentStr = NSAttributedString(attachment: attachment)
//
//            resultContent.replaceCharacters(in: emojiNSRange, with: attachmentStr)
//        }
        
        self.content = resultContent
        
        let contentH:CGFloat = self.content?.height(maxWidth: screenWidth - 170.0) ?? 0
        self.cellHeight = (contentH + 36.0) > 56.0 ? (contentH + 36.0) : 56.0
    }
}
