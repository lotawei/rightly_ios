//
//  MessageVideoViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import UIKit
import NIMSDK
import RxSwift
import RxCocoa
import KTVHTTPCache

class MessageVideoViewModel: MessageViewModel {
    let disposeBag = DisposeBag()
    var duration:Int?   //单位:毫秒
    var videoSize:CGSize?
    var coverURL:URL?
    var videoURL:URL?
    
    var progress:BehaviorRelay<Float> = BehaviorRelay.init(value: 0.0)
    var isPlaying:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var downloadStatus:BehaviorRelay<NIMMessageAttachmentDownloadState> = BehaviorRelay.init(value: .needDownload)
    
    override init(_ message: NIMMessage) {
        super.init(message)
        
        let videoObj:NIMVideoObject = message.messageObject as! NIMVideoObject
        
        // 150.0 * 150.0
        if videoObj.coverSize.width / videoObj.coverSize.height > 1.0 {
            self.videoSize = CGSize(width: 150.0, height: (150.0 / videoObj.coverSize.width * videoObj.coverSize.height))
        } else {
            self.videoSize = CGSize(width: (150.0 / videoObj.coverSize.height * videoObj.coverSize.width), height: 150.0)
        }
        
        self.cellHeight = (self.videoSize?.height ?? 150.0) + 16.0
        
        if FileManager.default.fileExists(atPath: videoObj.coverPath ?? "") {
            self.coverURL = URL.init(fileURLWithPath: videoObj.coverPath ?? "")
        } else {
            self.coverURL = URL.init(string: videoObj.coverUrl ?? "")
        }
        
        if FileManager.default.fileExists(atPath: videoObj.path ?? "") {
            self.videoURL = URL.init(fileURLWithPath: videoObj.path ?? "")
        } else {
            self.videoURL = URL.init(string: videoObj.url ?? "")
        }
        
        self.duration = videoObj.duration
    }
    
    func resetMessageObj(_ message:NIMMessage) {
        let videoObj:NIMVideoObject = message.messageObject as! NIMVideoObject
        
        if FileManager.default.fileExists(atPath: videoObj.coverPath ?? "") {
            self.coverURL = URL.init(fileURLWithPath: videoObj.coverPath ?? "")
        } else {
            self.coverURL = URL.init(string: videoObj.coverUrl ?? "")
        }
        
        if FileManager.default.fileExists(atPath: videoObj.path ?? "") {
            self.videoURL = URL.init(fileURLWithPath: videoObj.path ?? "")
        } else {
            self.videoURL = URL.init(string: videoObj.url ?? "")
        }
        
        self.duration = videoObj.duration
    }
}
