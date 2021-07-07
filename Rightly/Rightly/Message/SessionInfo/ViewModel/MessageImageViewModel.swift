//
//  MessageImageViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import UIKit
import NIMSDK
import RxSwift
import RxCocoa

class MessageImageViewModel: MessageViewModel {
    var fileLength:Int64?
    var imageSize:CGSize?
    var imageURL:URL?
    var thumbURL:URL?
    var progress:BehaviorRelay<Float> = BehaviorRelay.init(value: 0.0)
    
    override init(_ message: NIMMessage) {
        super.init(message)
        
        let imageObj:NIMImageObject = message.messageObject as! NIMImageObject
        
        // 150.0 * 150.0
        if imageObj.size.width > imageObj.size.height {
            self.imageSize = CGSize(width: 150.0, height: (150.0 / imageObj.size.width * imageObj.size.height))
        } else {
            self.imageSize = CGSize(width: (150.0 / imageObj.size.height * imageObj.size.width), height: 150.0)
        }
        
        self.cellHeight = (self.imageSize?.height ?? 150.0) + 16.0
        self.fileLength = imageObj.fileLength
        
        self.imageURL = URL.init(string: imageObj.url ?? "")
        self.thumbURL = URL.init(string: imageObj.thumbUrl ?? "")
        if (self.createType == .me) {
            if imageObj.path != nil {
                self.imageURL = URL.init(fileURLWithPath: imageObj.path ?? "")
            }
            
            if imageObj.thumbPath != nil {
                self.thumbURL = URL.init(fileURLWithPath: imageObj.thumbPath ?? "")
            }
        }
    }
}
