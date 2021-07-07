//
//  SessionListCellViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/6.
//

import UIKit
import NIMSDK
import RxSwift
import RxCocoa

class SessionListCellViewModel {
    let disposeBag = DisposeBag()
    var recentSession:NIMRecentSession
    var timeStamp:TimeInterval = 0.0
    var content:String? = nil
    var contentAttri:NSAttributedString? = nil
    var userName:BehaviorRelay<String> = BehaviorRelay.init(value: "Nickname".localiz())
    var userHead:String? = ""
    var userHeadURL:BehaviorRelay<URL> = BehaviorRelay.init(value: URL(fileURLWithPath: ""))
    var accId:String? = ""
    var userId:String? = ""
    var sessionId:String? = ""
    let unreadCount:BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
    
    init(_ recentSession:NIMRecentSession) {
        self.recentSession = recentSession
        
        if let lastMessage = recentSession.lastMessage {
            self.timeStamp = lastMessage.timestamp
            switch lastMessage.messageType {
            case .text:
                self.content = lastMessage.text ?? ""
            case .image:
                self.content = "[Image]".localiz()
            case .audio:
                self.content = "[Audio]".localiz()
            case .video:
                self.content = "[Video]".localiz()
            case .custom:
                self.content = "[Greeting]".localiz()
                if let customObj:NIMCustomObject = lastMessage.messageObject as? NIMCustomObject {
                    guard let attObj = customObj.attachment as? NIMAttachmentObj else {
                        break
                    }
                    
                    if attObj.type == "greeting" {
                        guard let greetingData = attObj.jsonData as? Dictionary<String, Any> else {
                            break
                        }
                        
                        let greetingViewModel = GreetInfoGreetViewModel.init(jsonData: greetingData)
                        self.content = greetingViewModel.firstContent
                    }
                }
            default:
                self.content = lastMessage.text ?? ""
            }
        }
        
        let resultContent = NSMutableAttributedString.init(string: self.content ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        resultContent.conversionEmoji(UIFont.systemFont(ofSize: 16))
        self.contentAttri = resultContent
        
        recentSession.rx.observeWeakly(Int.self, "unreadCount")
            .subscribe(onNext: { (newValue) in
                self.unreadCount.accept(newValue ?? 0)
            }).disposed(by: disposeBag)
        
        self.sessionId = recentSession.session?.sessionId
        guard let accId = recentSession.session?.sessionId else {
            return
        }
        
        self.resetUserInfo(accId)
    }
    
    func resetUserInfo(_ accId:String) {
        guard let userInfo:NIMUser = NIMSDK.shared().userManager.userInfo(accId) else {
            return
        }
        debugPrint("--- head avatar\(userInfo)")
        self.accId = userInfo.userId
        self.userName.accept((userInfo.alias ?? userInfo.userInfo?.nickName) ?? "")
        self.userHead = userInfo.userInfo?.avatarUrl
        self.userHeadURL.accept(URL.init(string: self.userHead?.dominFullPath() ?? "") ?? URL(fileURLWithPath: ""))
        debugPrint("--- head avatar \(self.userHead?.dominFullPath())")
        var userExt:String? = userInfo.serverExt
        if userExt == nil {
            userExt = userInfo.userInfo?.ext
        }
        
        if let serverExt = userExt {
            guard let serverData = serverExt.data(using: .utf8) else {
                return
            }
            
            var resultJSONData:[String : Any]?
            do {
                resultJSONData = try JSONSerialization.jsonObject(with: serverData, options: .mutableContainers) as? [String : Any]
            } catch {
                debugPrint("接口返回数据解析JSON错误")
                return
            }
            
            if let userIdStr:String = resultJSONData?["userId"] as? String {
                self.userId = userIdStr
            } else if let userIdInt:Int = resultJSONData?["userId"] as? Int {
                self.userId = String(userIdInt)
            }
        }
    }
}

