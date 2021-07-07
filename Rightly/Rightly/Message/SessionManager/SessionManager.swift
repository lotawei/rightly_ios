//
//  SessionManager.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import Foundation
import RxSwift
import NIMSDK

class SessionManager: NSObject {
    public var sessionList:[NIMRecentSession]? = []
    
    private static let staticInstance = SessionManager()
    static func shared() -> SessionManager {
        return staticInstance
    }
    
    private override init() {
        super.init()
        NIMSDK.shared().loginManager.add(self)
        NIMSDK.shared().conversationManager.add(self)
        NIMSDK.shared().chatManager.add(self)
    }
    
    func loadAllSession() {
        self.sessionList = NIMSDK.shared().conversationManager.allRecentSessions()
    }
    
    func login(handle:@escaping (Error?) -> Void)  {
        if !NIMSDK.shared().loginManager.isLogined() {
            guard let accId = UserManager.manager.currentUser?.imInfo?.accId, let token = UserManager.manager.currentUser?.imInfo?.token else {
                handle(NSError.init(domain: "保存的accId 和 token有问题 需要重新登录!!!", code: -1, userInfo: nil))
                return
            }
            
            NIMSDK.shared().loginManager.login(accId, token: token) { (error) in
                debugPrint("网易云信登录: " + (error == nil ? "成功" : "失败"))
                handle(error)
            }
        }
    }
    
    func logout() {
        self.sessionList?.removeAll()
        NIMSDK.shared().loginManager.logout { (error) in
            debugPrint("网易云信 退出登录" + (error == nil ? "成功" : "失败:\(String(describing: error))"))
        }
    }
    
    func insertLocalGreetData(_ session:NIMSession, greetData:[String:Any]) {
        let searchOption = NIMMessageSearchOption.init()
        searchOption.startTime = 0
        searchOption.endTime = 0
        searchOption.order = .asc
        searchOption.messageTypes = [NSNumber.init(value: NIMMessageType.custom.rawValue)]
        debugPrint("插入数据:" + session.sessionId)
        NIMSDK.shared().conversationManager.searchMessages(session, option: searchOption) { (error, messages) in
            for tempMessage in messages ?? [] {
                guard let locExt = tempMessage.localExt, let messLocType:String = locExt["message_type"] as? String else {
                    continue
                }
                
                if (messLocType == "greeting_with_task" || messLocType == "greeting_with_greeting") {
                    debugPrint("已经存在本地打招呼会话")
                    return
                }
            }
            
            guard let userInfo = UserManager.manager.currentUser else {
                return
            }
            
            let meUserId = userInfo.additionalInfo?.userId?.description
            let meAccId = userInfo.additionalInfo?.imAccId
            
            let locTaskViewModel = GreetInfoGreetTaskAttachmentViewModel.init(jsonData: greetData)
            let locTaskMess = NIMMessage.init()
            let locTaskCusObj = NIMCustomObject.init()
            locTaskCusObj.attachment = locTaskViewModel
            if locTaskViewModel.userId == meUserId {
                locTaskMess.from = session.sessionId
            } else {
                locTaskMess.from = meAccId
            }
            locTaskMess.messageObject = locTaskCusObj
            locTaskMess.timestamp = (locTaskViewModel.creatTimestamp > maxTimeStamp ? (locTaskViewModel.creatTimestamp / 1000.0) : locTaskViewModel.creatTimestamp) - 30
            locTaskMess.localExt = ["message_type":"greeting_with_task"]
            locTaskMess.status = .read
            
            let locGreetViewModel = GreetInfoGreetGreetAttachmentViewModel.init(jsonData: greetData)
            let locGreetMess = NIMMessage.init()
            let locGreetCusObj = NIMCustomObject.init()
            locGreetCusObj.attachment = locGreetViewModel
            if locGreetViewModel.userId == meUserId {
                locGreetMess.from = meAccId
            } else {
                locGreetMess.from = session.sessionId
            }
            locGreetMess.messageObject = locGreetCusObj
            locGreetMess.timestamp = (locGreetViewModel.creatTimestamp > maxTimeStamp ? (locGreetViewModel.creatTimestamp / 1000.0) : locGreetViewModel.creatTimestamp) - 29
            locGreetMess.localExt = ["message_type":"greeting_with_greeting"]
            locGreetMess.status = .read
            
            NIMSDK.shared().conversationManager.save(locTaskMess, for: session) { (error) in
                debugPrint("插入本地任务消息:" + (error == nil ? "成功" : "失败"))
                self.loadAllSession()
            }
            
            NIMSDK.shared().conversationManager.save(locGreetMess, for: session) { (error) in
                debugPrint("插入本地打招呼消息:" + (error == nil ? "成功" : "失败"))
                self.loadAllSession()
            }
        }
    }
    
    func checkCustomMessage(_ message:NIMMessage) {
        if message.messageType == .custom {
            if let customObj:NIMCustomObject = message.messageObject as? NIMCustomObject {
                guard let attObj = customObj.attachment as? NIMAttachmentObj else {
                    return
                }
                
                switch attObj.type {
                case "greeting":
                    guard let greetingData = attObj.jsonData as? Dictionary<String, Any>, let session = message.session else {
                        return
                    }
                    
                    self.insertLocalGreetData(session, greetData: greetingData)
                default:
                    debugPrint("出现自定义消息不认识的类型:\(String(describing: attObj.type))")
                }
            }
        }
    }
}

// MARK: - 登录的回调
extension SessionManager : NIMLoginManagerDelegate {
    /// 被踢(服务器/其他端)回调
    /// - Parameter result: 被踢原因
    func onKickout(_ result: NIMLoginKickoutResult) {
        debugPrint("网易云信 被踢(服务器/其他端)回调:\(result.reasonDesc)")
    }
    
    /// 登录回调 这个回调主要用于客户端UI的刷新
    /// - Parameter step: 登录步骤
    func onLogin(_ step: NIMLoginStep) {
        switch step {
        case .linking:
            debugPrint("网易云信 连接服务器")
        case .linkOK:
            debugPrint("网易云信 连接服务器成功")
        case .linkFailed:
            debugPrint("网易云信 连接服务器失败")
//            DispatchQueue.main.async {
//                UIViewController.getCurrentViewController()?.toastTip("Link server failed".localiz())
//            }
           
        case .logining:
            debugPrint("网易云信 登录")
        case .loginOK:
            debugPrint("网易云信 登录成功")
        case .loginFailed:
            debugPrint("网易云信 登录失败")
        case .syncing:
            debugPrint("网易云信 开始同步")
        case .syncOK:
            debugPrint("网易云信 同步完成")
        case .loseConnection:
            debugPrint("网易云信 连接断开")
        case .netChanged:
            debugPrint("网易云信 网络切换")
        
        default:
            debugPrint("连接服务器 其他状态")
        }
    }
    
    /// 自动登录失败回调 自动重连不需要上层开发关心，但是如果发生一些需要上层开发处理的错误，SDK 会通过这个方法回调
    /// 用户需要处理的情况包括：AppKey 未被设置，参数错误，密码错误，多端登录冲突，账号被封禁，操作过于频繁等
    /// - Parameter error: 失败原因
    func onAutoLoginFailed(_ error: Error) {
        debugPrint("网易云信 自动登录失败回调:\(error)")
    }

    /// 多端登录发生变化
    func onMultiLoginClientsChanged() {
        debugPrint("网易云信 多端登录发生变化")
    }
    
    /// 多端登录发生变化
    /// - Parameter type: 多端登陆的状态
    func onMultiLoginClientsChanged(with type: NIMMultiLoginType) {
        debugPrint("网易云信 多端登录发生变化:\(type.rawValue)")
    }

    /// 群用户同步完成通知
    /// - Parameter success: 群用户信息同步是否成功
    func onTeamUsersSyncFinished(_ success: Bool) {
        debugPrint("网易云信 群用户同步完成通知:\(success)")
    }
    
    /// 超大群用户同步完成通知
    /// - Parameter success: 群用户信息同步是否成功
    func onSuperTeamUsersSyncFinished(_ success: Bool) {
        debugPrint("网易云信 超大群用户同步完成通知:\(success)")
    }

//    /// 提供动态登陆Token
//    /// - Parameter account: 账号
//    /// - Returns: 返回登录的token
//    func provideDynamicToken(forAccount account: String) -> String {
//
//    }
}

// MARK: - 会话的回调
extension SessionManager : NIMConversationManagerDelegate {
    /// 最近会话数据库读取完成
    /// - Returns: 该回调执行表示最近会话全部加载完毕可以通过allRecentSessions来取全部对话。
    func didLoadAllRecentSessionCompletion() {
        self.sessionList = NIMSDK.shared().conversationManager.allRecentSessions()
        debugPrint("网易云信 最近会话数据库读取完成")
    }
    
    /// 增加最近会话的回调
    /// - Parameters: 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("网易云信 增加最近会话的回调")
        self.sessionList = NIMSDK.shared().conversationManager.allRecentSessions()
    }
    
    /// 最近会话修改的回调
    /// - Parameters: 触发条件包括: 1.当新增一条消息，并且本地存在该消息所属的会话。
    /// 2.所属会话的未读清零。
    /// 3.所属会话的最后一条消息的内容发送变化。(例如成功发送后，修正发送时间为服务器时间)
    /// 4.删除消息，并且删除的消息为当前会话的最后一条消息。
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("网易云信 最近会话修改的回调")
    }
    
    /// 删除最近会话的回调
    /// - Parameters:
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("网易云信 删除最近会话的回调")
        self.sessionList = NIMSDK.shared().conversationManager.allRecentSessions()
        
    }

    /// 单个会话里所有消息被删除的回调
    /// - Parameter session: 消息所属会话
    func messagesDeleted(in session: NIMSession) {
        debugPrint("网易云信 单个会话里所有消息被删除的回调")
    }
    
    /// 所有消息被删除的回调
    func allMessagesDeleted() {
        debugPrint("网易云信 所有消息被删除的回调")
    }
    
    /// 单个会话所有消息在本地和服务端都被清空
    /// - Parameters:
    ///   - session: 消息所属会话
    ///   - step: 清空会话消息完成时状态
    func allMessagesCleared(in session: NIMSession, step: NIMClearMessagesStatus) {
        debugPrint("网易云信 单个会话所有消息在本地和服务端都被清空")
    }
    
    /// 所有消息已读的回调
    func allMessagesRead() {
        debugPrint("网易云信 所有消息已读的回调")
    }
    
    /// 会话服务，会话更新
    /// - Parameter recentSession: 最近会话
    func didServerSessionUpdated(_ recentSession: NIMRecentSession?) {
        debugPrint("网易云信 会话服务，会话更新")
    }
    
    /// 消息单向删除通知
    /// - Parameters:
    ///   - messages: 被删除消息
    ///   - exts: 删除时的扩展字段字典，key: messageId，value: ext
    func onRecvMessagesDeleted(_ messages: [NIMMessage], exts: [String : String]?) {
        debugPrint("网易云信 消息单向删除通知")
    }
    
    /// 未漫游完整会话列表回调
    /// - Parameter infos: 未漫游完整的会话信息
    func onRecvIncompleteSessionInfos(_ infos: [NIMIncompleteSessionInfo]?) {
        debugPrint("网易云信 未漫游完整会话列表回调")
    }
    
    /// 标记已读回调
    /// - Parameters:
    ///   - session: session
    ///   - error: 失败原因
    func onMarkMessageReadComplete(in session: NIMSession, error: Error?) {
        debugPrint("网易云信 标记已读回调")
    }
    
    /// 批量标记已读的回调
    /// - Parameter sessions: session
    func onBatchMarkMessagesRead(in sessions: [NIMSession]) {
        debugPrint("网易云信 批量标记已读的回调")
    }
}

// MARK: - 消息的回调
extension SessionManager : NIMChatManagerDelegate {
    /// 即将发送消息回调 因为发消息之前可能会有个准备过程,所以需要在收到这个回调时才将消息加入到 Datasource 中
    /// - Parameter message: 当前发送的消息
    func willSend(_ message: NIMMessage) {
        debugPrint("网易云信 消息的回调")
        self.checkCustomMessage(message)
    }
    
    /// 上传资源文件成功的回调 对于需要上传资源的消息(图片，视频，音频等)，SDK 将在上传资源成功后通过这个接口进行回调，上层可以在收到该回调后进行推送信息的重新配置 (APNS payload)
    /// - Parameters:
    ///   - urlString: 当前消息资源获得的 url 地址
    ///   - message: 当前发送的消息
    func uploadAttachmentSuccess(_ urlString: String, for message: NIMMessage) {
        debugPrint("网易云信 上传资源文件成功的回调")
    }
    
    /// 发送消息进度回调
    /// - Parameters:
    ///   - message: 当前发送的消息
    ///   - progress: 进度
    func send(_ message: NIMMessage, progress: Float) {
        debugPrint("网易云信 发送消息进度回调")
    }
    
    /// 发送消息完成回调
    /// - Parameters:
    ///   - message: 当前发送的消息
    ///   - error: 失败原因,如果发送成功则error为nil
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        debugPrint("网易云信 发送消息完成回调")
    }
    
    /// 收到消息回调
    /// - Parameter messages: 消息列表,内部为NIMMessage
    func onRecvMessages(_ messages: [NIMMessage]) {
        debugPrint("网易云信 收到消息回调")
        for message in messages {
            debugPrint("收到网易云信消息:" + message.messageId)
            self.checkCustomMessage(message)
        }
    }

    /// 收到消息回执  当上层收到此消息时所有的存储和 model 层业务都已经更新，只需要更新 UI 即可。
    /// - Parameter receipts: 消息回执数组
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        debugPrint("网易云信 收到消息回执")
    }

    /// 收到消息被撤回的通知 云信在收到消息撤回后，会先从本地数据库中找到对应消息并进行删除，之后通知上层消息已删除
    /// - Parameter notification: 被撤回的消息信息
    func onRecvRevokeMessageNotification(_ notification: NIMRevokeMessageNotification) {
        debugPrint("网易云信 收到消息被撤回的通知")
    }

    /// 收取消息附件回调  附件包括:图片,视频的缩略图,语音文件
    /// - Parameters:
    ///   - message: 当前收取的消息
    ///   - progress: 进度
    func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
//        debugPrint("网易云信 收取消息附件回调")
    }

    /// 收取消息附件完成回调
    /// - Parameters:
    ///   - message: 当前收取的消息
    ///   - error: 错误返回,如果收取成功,error为nil
    func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        debugPrint("网易云信 收取消息附件完成回调")
    }
}
