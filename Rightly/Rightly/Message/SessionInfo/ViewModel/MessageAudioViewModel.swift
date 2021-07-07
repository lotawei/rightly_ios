//
//  MessageAudioViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/16.
//

import Foundation
import NIMSDK
import RxSwift
import RxCocoa

class MessageAudioViewModel: MessageViewModel {
    let disposeBag = DisposeBag()
    var duration:Int?   //单位:毫秒
    var durationStr:String?
    var audioWidth:CGFloat?
    var audioPath:String? = ""
    var progress:BehaviorRelay<Float> = BehaviorRelay.init(value: 0.0)
    
    var isPlaying:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    
    var downloadStatus:BehaviorRelay<NIMMessageAttachmentDownloadState> = BehaviorRelay.init(value: .needDownload)
    
    override init(_ message: NIMMessage) {
        super.init(message)
        
        let audioObj:NIMAudioObject = message.messageObject as! NIMAudioObject
        
        message.rx.observe(NIMMessageAttachmentDownloadState.self, "attachmentDownloadState")
            .subscribe(onNext : { [weak self] status in
                guard let newStatus = status else {
                    return
                }
                
                self?.downloadStatus.accept(newStatus)
                
                switch newStatus {
                case .downloaded:
                    self?.receiveStatus.accept(.received)
                case .needDownload:
                    self?.receiveStatus.accept(.notYet)
                case .downloading:
                    self?.receiveStatus.accept(.receiving)
                default:
                    self?.receiveStatus.accept(.failure)
                }
                debugPrint("status = " + status.debugDescription)
            }).disposed(by: self.disposeBag)
        
        if message.attachmentDownloadState == .downloaded, FileManager.default.fileExists(atPath: audioObj.path ?? "") {
            self.audioPath = audioObj.path
        } else {
            self.audioPath = audioObj.url
            try? NIMSDK.shared().chatManager.fetchMessageAttachment(message)
        }
        
        self.cellHeight = 56.0
        self.duration = audioObj.duration
        self.durationStr = lround(Double(self.duration ?? 0) / 1000.0).description + "''"
        let maxAudioWidth:CGFloat = screenWidth - 233.0
        let currAudioWidth = (CGFloat(self.duration ?? 0) / CGFloat((RTVoiceRecordManager.shareinstance.maxTimeAllow  * 1000.0))) * maxAudioWidth
        self.audioWidth = CGFloat(fminf(Float(currAudioWidth), Float(RTVoiceRecordManager.shareinstance.maxTimeAllow)))
    }
    
    func resetMessageObj(_ message:NIMMessage) {
        let audioObj:NIMAudioObject = message.messageObject as! NIMAudioObject
        if FileManager.default.fileExists(atPath: audioObj.path ?? "") {
            self.audioPath = audioObj.path
        } else {
            self.audioPath = audioObj.url
        }
        
        debugPrint("重置音频地址:" + (self.audioPath ?? ""))
        self.duration = audioObj.duration
        self.durationStr = lrint(Double(self.duration ?? 0) / 1000.0).description + "''"
        let maxAudioWidth:CGFloat = screenWidth - 233.0
        let currAudioWidth = (CGFloat(self.duration ?? 0) / CGFloat((RTVoiceRecordManager.shareinstance.maxTimeAllow  * 1000.0))) * maxAudioWidth
        self.audioWidth = CGFloat(fminf(Float(currAudioWidth), Float(RTVoiceRecordManager.shareinstance.maxTimeAllow)))
    }
    
    func playAudio() -> Bool {
        guard let message = self.message, let audioPath = self.audioPath else {
            return false
        }
        
        if self.downloadStatus.value == .needDownload || self.downloadStatus.value == .failed {
            try? NIMSDK.shared().chatManager.fetchMessageAttachment(message)
            self.downloadStatus.accept(.downloading)
            return true
        }
        
        self.isPlaying.accept(!self.isPlaying.value)
        if self.isPlaying.value {
            NIMSDK.shared().mediaManager.play(audioPath)
        } else {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        return true
    }
}

