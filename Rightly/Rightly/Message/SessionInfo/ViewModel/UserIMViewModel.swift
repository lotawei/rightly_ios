//
//  UserIMViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/7/1.
//

import Foundation
import RxSwift
import RxCocoa
import NIMSDK

enum LoadMessageState {
    case local
    case server
    case noMore
}

class UserIMViewModel {
    let session:NIMSession
    
    let loadState = LoadMessageState.local
    var messageTimeKeys:[Double] = []
    var messageList:[Double:[MessageViewModel]] = [:]
    var firstMessage:NIMMessage? = nil
    
    init(_ session:NIMSession) {
        self.session = session
    }
    
    func getMessViewModel(_ btnTag:Int) -> MessageViewModel? {
        return self.getMessViewModel(IndexPath(row: (btnTag % 10000), section: (btnTag / 10000)))
    }
    
    func getMessViewModel(_ indexPath:IndexPath) -> MessageViewModel? {
        if indexPath.section >= messageTimeKeys.count {
            return nil
        }
        
        let timeKey = self.messageTimeKeys[indexPath.section]
        let messArray = self.messageList[timeKey]
        if indexPath.row >= messArray?.count ?? 0 {
            return nil
        }
        
        return messArray?[indexPath.row]
    }
    
    func getMessViewModel(_ message:NIMMessage) -> MessageViewModel? {
        for tempTimeKey in self.messageTimeKeys {
            if let messArray = self.messageList[tempTimeKey] {
                for tempViewModel in messArray {
                    if message.messageId == tempViewModel.messageId {
                        return tempViewModel
                    }
                }
            }
        }
        
        return nil
    }
    
    //停止播放音频
    func stopAllAudio(except:IndexPath?) {
        NIMSDK.shared().mediaManager.stopPlay()
        for i in 0..<self.messageTimeKeys.count {
            let tempTimeKey = self.messageTimeKeys[i]
            let tempRowCount = self.messageList[tempTimeKey]?.count ?? 0
            for j in 0..<tempRowCount {
                if let tempViewModel = self.messageList[tempTimeKey]?[j] as? MessageAudioViewModel, tempViewModel.isPlaying.value {
                    if except == nil || except?.section != i || except?.row != j {
                        tempViewModel.isPlaying.accept(false)
                    }
                }
            }
        }
    }
    
    
}

//MARK: - 获取IM消息
extension UserIMViewModel {
    func loadMessages() {
        switch self.loadState {
        case .local:
            self.loadLocalMessages()
        case .server:
            self.loadServerMessages()
        default:
            break
        }
    }
    
    fileprivate func loadLocalMessages() {
        let limitMessages:[NIMMessage] = NIMSDK.shared().conversationManager.messages(in: self.session, message: self.firstMessage, limit: 20) ?? []
        self.conversionMessageToViewModel(limitMessages)
    }
    
    fileprivate func loadServerMessages() {
        let option = NIMHistoryMessageSearchOption()
        option.createRecentSessionIfNotExists = true
        option.limit = 20
        option.endTime = self.firstMessage?.timestamp ?? 0
        option.currentMessage = self.firstMessage
        option.sync = true
        option.createRecentSessionIfNotExists = true
        option.order = .desc
        debugPrint("查询开始时间:", option.startTime.description)
        NIMSDK.shared().conversationManager.fetchMessageHistory(self.session, option: option) { [weak self] (error, messages) in
            guard let `self` = self else {return}
            guard let limitMessages = messages else {
                return
            }
            
            self.conversionMessageToViewModel(limitMessages)
        }
    }
    
    fileprivate func conversionMessageToViewModel(_ limitMessages:[NIMMessage]) {
        for tempMessage in limitMessages {
            if self.firstMessage == nil || tempMessage.timestamp <= (self.firstMessage?.timestamp ?? 0) {
                self.firstMessage = tempMessage
            }
            
            self.insertMessage(tempMessage)
        }
    }
    
    // MARK: - 插入消息
    fileprivate func insertMessage(_ message:NIMMessage) {
        objc_sync_enter(self.messageList)
        var insertViewModel:MessageViewModel = MessageViewModel.init(message)
        switch message.messageType {
        case .image:
            insertViewModel = MessageImageViewModel.init(message)
        case .audio:
            insertViewModel = MessageAudioViewModel.init(message)
        case .video:
            insertViewModel = MessageVideoViewModel.init(message)
        case .custom:
            guard let customVM = self.createCustomViewModel(message) else {
                objc_sync_exit(self.messageList)
                return
            }
            
            insertViewModel = customVM
        case .text:
            insertViewModel = MessageTextViewModel.init(message)
        default:
            objc_sync_exit(self.messageList)
            return
        }
        
        if self.messageList[insertViewModel.timeMinute] == nil {
            self.messageList[insertViewModel.timeMinute] = [insertViewModel]
            self.messageTimeKeys = self.messageList.keys.sorted()
        } else {
            self.messageList[insertViewModel.timeMinute]?.append(insertViewModel)
            self.messageList[insertViewModel.timeMinute]?.sort(by: { (viewModel1, viewModel2) -> Bool in
                return viewModel1.timeStamp < viewModel2.timeStamp
            })
        }
        
        objc_sync_exit(self.messageList)
    }
    
    fileprivate func createCustomViewModel(_ message:NIMMessage) -> MessageViewModel? {
        guard let customObj:NIMCustomObject = message.messageObject as? NIMCustomObject else {
            return nil
        }
        
        let attachmentDecode = NIMAttachmentDecode.init()
        var tempAttachment = customObj.attachment
        if tempAttachment is GreetInfoGreetTaskAttachmentViewModel {
            tempAttachment = attachmentDecode.decodeAttachment(tempAttachment?.encode())
        } else if tempAttachment is GreetInfoGreetGreetAttachmentViewModel {
            tempAttachment = attachmentDecode.decodeAttachment(tempAttachment?.encode())
        }
        
        guard let attObj = tempAttachment as? NIMAttachmentObj, let greetingData = attObj.jsonData as? Dictionary<String, Any> else {
            return nil
        }
        
        switch attObj.type {
        case "greeting":
            let greetingViewModel = GreetInfoGreetViewModel.init(jsonData: greetingData)
            message.text = greetingViewModel.firstContent
            return MessageTextViewModel.init(message)
        case "greeting_with_task":
            return MessageTaskViewModel.init(message, greetData: greetingData)
        case "greeting_with_greeting":
            return MessageGreetingViewModel.init(message, greetData: greetingData)
        default:
            debugPrint("出现自定义消息不认识的类型")
        }
        
        return nil
    }
}

