//
//  MessageViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/8.
//

import Foundation
import NIMSDK
import RxSwift
import RxCocoa

enum MessageType:Int {
    case text = 1
    case image = 2
    case audio = 3
    case video = 4
    case task = 5
    case greeting = 6
}

enum MessageCreatorType:Int {
    case system = 0
    case me = 1
    case other = 2
}

enum ShowStatus:Int {
    case none = 0       //默认
    case readed = 1     //已读
    case deleted = 2    //已删除
}

enum SendStatus:Int {
    case sending = 0    //发送中
    case sended = 1     //已发送
    case failure = 2    //发送失败
}

enum ReceiveStatus:Int {
    case received = 0     //已收到消息
    case notYet = 1     //有附件消息但是还未开始下载
    case receiving = 2    //正在接收
    case failure = 3    //收到消息失败(只会出现在带附件的 图片，音频，视频等)
}

class MessageViewModel {
    var message:NIMMessage? = nil
    var messageId:String? = nil
    var timeStamp:TimeInterval = 0.0
    var timeMinute:TimeInterval = 0.0
    var messageType:MessageType
    var createType:MessageCreatorType
    var showStatus:ShowStatus = .none
    let sendStatus:BehaviorRelay<SendStatus> = BehaviorRelay.init(value: .sended)
    let receiveStatus:BehaviorRelay<ReceiveStatus> = BehaviorRelay.init(value: .received)
    
    var userName:String? = ""
    var userHead:String? = ""
    var userHeadURL:URL? = nil
    var accId:String? = ""
    
    var cellHeight:CGFloat = 56.0
    
    init(_ message:NIMMessage) {
        switch message.messageType {
        case .text:
            self.messageType = .text
        case .image:
            self.messageType = .image
        case .audio:
            self.messageType = .audio
        case .video:
            self.messageType = .video
        default:
            self.messageType = .text
        }
        
        if message.isOutgoingMsg {
            self.createType = .me
        } else {
            self.createType = .other
        }
        
        switch message.deliveryState {
        case .deliveried:
            self.sendStatus.accept(.sended)
        case .delivering:
            self.sendStatus.accept(.sending)
        case .failed:
            self.sendStatus.accept(.failure)
        default:
            self.sendStatus.accept(.sended)
        }
        
        switch message.status {
        case .none:
            self.showStatus = .none
        case .read:
            self.showStatus = .readed
        case .deleted:
            self.showStatus = .deleted
        default:
            self.showStatus = .none
        }
        
        self.message = message
        self.messageId = message.messageId

        self.setupTime(message.timestamp)
        
        if self.createType == .me {
            let userInfo = UserManager.manager.currentUser?.additionalInfo
            self.accId = userInfo?.imAccId
            self.userName = userInfo?.nickname
            self.userHead = userInfo?.avatar
            self.userHeadURL = URL.init(string: self.userHead?.dominFullPath() ?? "")
        } else {
            if let userId = message.from {
                let userInfo = NIMSDK.shared().userManager.userInfo(userId)
                self.accId = userId
                self.userName = userInfo?.alias == nil ? userInfo?.userInfo?.nickName : "unknow"
                self.userHead = userInfo?.userInfo?.avatarUrl
                self.userHeadURL = URL.init(string: self.userHead?.dominFullPath() ?? "")
            }
        }
    }
    
    func setupTime(_ timestamp:TimeInterval) {
        self.timeStamp = timestamp
        
        let timeInt = Int64.init(timestamp)
        self.timeMinute = TimeInterval.init(timeInt - (timeInt % 60))
    }
}

