//
//  SessionInfoViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import RxSwift
import NIMSDK
import RxDataSources
import RxCocoa
import IQKeyboardManagerSwift
import MJRefresh
import AVFoundation
import KTVHTTPCache
import MBProgressHUD
import Photos
import ZLPhotoBrowser
import AVKit


class SessionInfoViewController: BaseViewController {
    var loadType:LoadMessageState = .local
    var isFirstPush:Bool = true
    var matchGreeting:MatchGreeting?=nil
    var messageDatas:[TimeInterval:[MessageViewModel]] = Dictionary()
    var messageKeys:[TimeInterval] = []
    var apnsPayload:[AnyHashable:Any] = Dictionary<AnyHashable, Any>()
    
    fileprivate var beforeMessage:NIMMessage? = nil
    fileprivate var session:NIMSession?
    fileprivate var userId:String?
    fileprivate var userInfo:UserAdditionalInfo?
    fileprivate let userPorvider = UserProVider.init()
    
    lazy var followBtn:FollowUIButton = {
        let resultBtn = FollowUIButton.init(type: .custom)
        resultBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 28)
        resultBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        resultBtn.isEnabled = false
        resultBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext:{ [weak self] (sender) in
                guard let `self` = self  else {return }
                guard let  userid = Int64(self.userId ?? "0") ,userid > 0 else {
                    return
                }
                self.followUser(userid: userid)
            }).disposed(by: self.rx.disposeBag)
        return resultBtn
    }()
    
    lazy var tableView:UITableView = {
        let resultView = UITableView.init(frame: self.view.bounds, style: .grouped)
        resultView.initTableView()
        resultView.register(nibName: "MessageFromTextTableViewCell", forCellId: "fromTextId")
        resultView.register(nibName: "MessageFromImageTableViewCell", forCellId: "fromImageId")
        resultView.register(nibName: "MessageFromAudioTableViewCell", forCellId: "fromAudioId")
        resultView.register(nibName: "MessageFromVideoTableViewCell", forCellId: "fromVideoId")
        resultView.register(nibName: "MessageFromTaskTableViewCell", forCellId: "fromTaskId")
        resultView.register(nibName: "MessageFromGreetingTableViewCell", forCellId: "fromGreetingId")
        resultView.register(nibName: "MessageToTextTableViewCell", forCellId: "toTextId")
        resultView.register(nibName: "MessageToImageTableViewCell", forCellId: "toImageId")
        resultView.register(nibName: "MessageToAudioTableViewCell", forCellId: "toAudioId")
        resultView.register(nibName: "MessageToVideoTableViewCell", forCellId: "toVideoId")
        resultView.register(nibName: "MessageToTaskTableViewCell", forCellId: "toTaskId")
        resultView.register(nibName: "MessageToGreetingTableViewCell", forCellId: "toGreetingId")
        
        resultView.register(MessageTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: "timeHeaderId")
        resultView.register(MessageTimeFooterView.self, forHeaderFooterViewReuseIdentifier: "timeFooterId")
        resultView.delegate = self
        resultView.dataSource = self
        resultView.mj_header = GlobalRefreshAutoGiftHeader.init(refreshingBlock: { [weak self] in
            debugPrint("下拉刷新")
            self?.loadMessages(isPull: true)
        })
        return resultView
    }()
    
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
        NIMSDK.shared().chatManager.remove(self)
    }
    
    var editView:MessageEditView = {
        let resultView = MessageEditView.loadNibView() ?? MessageEditView.init()
        return resultView
    }()
    
    init(session:NIMSession, userId:String) {
        super.init(nibName: nil, bundle: nil)
        self.session = session
        self.userId = userId
        
        let apnsUserId = UserManager.manager.currentUser?.additionalInfo?.userId ?? 0
        let sessionId = UserManager.manager.currentUser?.additionalInfo?.imAccId ?? "0"
        let sessionType = session.sessionType.rawValue
        self.apnsPayload = ["userId" : apnsUserId, "sessionid" : sessionId, "sessiontype" : sessionType]
    }
    
    init(session:NIMSession , greeting:MatchGreeting?) {
        super.init(nibName: nil, bundle: nil)
        self.session = session
        self.matchGreeting = greeting
        let userIdStr = String(greeting?.userId ?? 0)
        self.userId = userIdStr
        
        let apnsUserId = UserManager.manager.currentUser?.additionalInfo?.userId ?? 0
        let sessionId = UserManager.manager.currentUser?.additionalInfo?.imAccId ?? "0"
        let sessionType = session.sessionType.rawValue
        self.apnsPayload = ["userId" : apnsUserId, "sessionid" : sessionId, "sessiontype" : sessionType]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().chatManager.add(self)
        self.isFirstPush = true
        self.setupView()
        self.bindData()
        self.addTapDealHideView()
        self.loadMessages(isPull: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestUserInfo()
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
        
        if self.isFirstPush {
            self.isFirstPush = false
            self.view.layoutIfNeeded()
            self.scrollTableViewToBottom()
        }
        
        if let sendSession = self.session {
            NIMSDK.shared().conversationManager.markAllMessagesRead(in: sendSession)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NIMSDK.shared().mediaManager.stopPlay()
        NIMSDK.shared().mediaManager.cancelRecord()
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
    }
    
    fileprivate func setupView() {
        let rightItem = UIBarButtonItem.init(customView: self.followBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        self.followBtn.isEnabled = false
        
        let userInfo = NIMSDK.shared().userManager.userInfo(self.session?.sessionId ?? "")
        self.title = userInfo?.alias != nil ? userInfo?.alias : userInfo?.userInfo?.nickName
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.editView)
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: (screenHeight - navBarH - 88 - safeBottomH))
        self.editView.frame = CGRect(x: 0, y: self.tableView.mj_h, width: screenWidth, height: (88 + safeBottomH))
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(self.editView.snp.top)
        }
        
        self.editView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
        }
    }
    
    func followUser(userid:Int64)  {
        UserProVider.focusUser(self.followBtn.isSelected, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
            guard let `self` = self  else {return }
            self.followBtn.isSelected =  isfocus
        }
    }
    
    // MARK: - 请求用户信息
    fileprivate func requestUserInfo()  {
        guard let userId = self.userId else {
            return
        }
        
        self.userPorvider.userAdditionalInfo(userId, self.rx.disposeBag).subscribe(onNext:{ [weak self] (userResponse) in
            guard let `self` = self  else {return }
            if let userResult = userResponse.modeDataKJTypeSelf(typeSelf: UserAdditionalInfo.self) {
                self.userInfo = userResult
                self.followBtn.isEnabled = true
                self.followBtn.isSelected = self.userInfo?.isfocused ?? false
                self.title = self.userInfo?.nickname
                
                for tempCell in self.tableView.visibleCells {
                    if let taskCell = tempCell as? MessageToTaskTableViewCell {
                        taskCell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
                    } else if let taskCell = tempCell as? MessageFromTaskTableViewCell {
                        taskCell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
                    }
                }
                
            }
            //            switch userResponse {
            //            case .success(let userResult):
            //                guard let `self` = self else {return}
            //                self.userInfo = userResult
            //                self.followBtn.isEnabled = true
            //                self.followBtn.isSelected = self.userInfo?.isfocused ?? false
            //                self.title = self.userInfo?.nickname
            //
            //                for tempCell in self.tableView.visibleCells {
            //                    if let taskCell = tempCell as? MessageToTaskTableViewCell {
            //                        taskCell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
            //                    } else if let taskCell = tempCell as? MessageFromTaskTableViewCell {
            //                        taskCell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
            //                    }
            //                }
            //            case .failed(_):
            //                break
            //            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    // MARK: - 展示cell
    fileprivate func bindData() {
        self.editView.messageSendBtnActionBlock = { [weak self] in
            guard let `self` = self  else {return }
            let willSentText = self.editView.exportTextView()
            self.editView.resetSendedView()
            guard let sendSession = self.session else {
                return
            }
            
            // MARK: 发送消息
            if self.editView.imageBtn.isSelected {
                self.editView.resetInitView()
                for tempModel in MediaResourceManager.shared.allselectedMedia.value {
                    let message = NIMMessage.init()
                    if tempModel.type == .video {
                        self.insertVideoMessage(tempModel, message, sendSession)
                    } else {
                        self.insertNewImageMessage(tempModel, message, sendSession)
                    }
                }
            } else {
                let message = NIMMessage.init()
                message.text = willSentText
                message.apnsPayload = self.apnsPayload
                try? NIMSDK.shared().chatManager.send(message, to: sendSession)
            }
        }
        
        self.editView.cameraBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext:{[weak self] (sender) in
                guard let `self` = self else {return }
                self.editView.resetInitView()
                guard let currentVc = self.getCurrentViewController() else {
                    return
                }
                ZLPhotoConfiguration.default().allowRecordVideo  = true
                ZLPhotoConfiguration.default().allowSelectImage = true
                ZLPhotoConfiguration.default().allowTakePhoto  = true
                let camera = ZLCustomCamera()
                camera.takeDoneBlock = { [weak self] (image, videoUrl) in
                    guard let `self` = self else {return}
                    guard let sendSession = self.session else {
                        debugPrint("会话错误")
                        return
                    }
                    
                    let message = NIMMessage.init()
                    if videoUrl == nil {
                        //拍摄的图片
                        guard let sendImage = image else {
                            debugPrint("拍摄图片错误")
                            return
                        }
                        let imageObj = NIMImageObject.init(image: sendImage)
                        message.messageObject = imageObj
                        message.apnsPayload = self.apnsPayload
                        try? NIMSDK.shared().chatManager.send(message, to: sendSession)
                    } else {
                        //拍摄的视频
                        guard let resultURL = videoUrl else {
                            debugPrint("拍摄视频失败")
                            return
                        }
                        
                        guard let videoData = try? Data.init(contentsOf: resultURL) else {
                            debugPrint("拍摄视频错误:\(resultURL)")
                            return
                        }
                        
                        let videoObj = NIMVideoObject.init(data: videoData, extension: resultURL.pathExtension.lowercased())
                        message.messageObject = videoObj
                        message.apnsPayload = self.apnsPayload
                        try? NIMSDK.shared().chatManager.send(message, to: sendSession)
                    }
                }
                currentVc.showDetailViewController(camera, sender: nil)
            }).disposed(by: self.rx.disposeBag)
        
        self.editView.messageEditBtnActionBlock = { [weak self] in
            guard let `self` = self else {return}
            self.scrollTableViewToBottom()
        }
    }
    
    fileprivate func loadMessages(isPull:Bool) {
        switch loadType {
        case .local:
            let limitMessages:[NIMMessage] = NIMSDK.shared().conversationManager.messages(in: self.session!, message: self.beforeMessage, limit: 20) ?? []
            
            var firstMessage:MessageViewModel? = nil
            if self.messageKeys.count > 0 {
                if let firstMessageKey = self.messageKeys.first {
                    firstMessage = self.messageDatas[firstMessageKey]?.first
                }
            }
            
            for tempMessage in limitMessages {
                if let message = self.beforeMessage {
                    if tempMessage.timestamp <= message.timestamp {
                        self.beforeMessage = tempMessage
                    }
                } else {
                    self.beforeMessage = tempMessage
                }
                
                self.insertMessage(tempMessage)
            }
            
            if limitMessages.count < 20 {
                self.loadType = .server
            }
            
            self.tableView.mj_header?.endRefreshing()
            self.tableView.reloadData()
            
            if firstMessage != nil {
                if isPull {
                    for i in 0..<self.messageKeys.count {
                        let timeKey = self.messageKeys[i]
                        let tempArray = self.messageDatas[timeKey] ?? []
                        for j in 0..<tempArray.count {
                            let tempViewModel = tempArray[j]
                            if firstMessage?.messageId == tempViewModel.message?.messageId {
                                let tempIndexPath = IndexPath.init(row: j, section: i)
                                self.tableView.scrollToRow(at: tempIndexPath, at: .top, animated: false)
                                debugPrint("滚动\(i) : \(j)")
                                return
                            }
                        }
                    }
                }
            }
        //            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        case .server:
            let option = NIMHistoryMessageSearchOption()
            option.createRecentSessionIfNotExists = true
            option.limit = 20
            //            option.endTime = self.beforeMessage?.timestamp ?? 0
            option.endTime = self.beforeMessage?.timestamp ?? 0
            option.currentMessage = self.beforeMessage
            option.sync = self.messageDatas.count <= 30 ? true : false
            option.createRecentSessionIfNotExists = true
            option.order = .desc
            debugPrint("查询开始时间:", option.startTime.description)
            NIMSDK.shared().conversationManager.fetchMessageHistory(self.session!, option: option) { [weak self] (error, messages) in
                guard let `self` = self else {return}
                self.tableView.mj_header?.endRefreshing()
                if error != nil {
                    return
                }
                
                guard let limitMessages = messages else {
                    return
                }
                
                for tempMessage in limitMessages {
                    if let message = self.beforeMessage {
                        if tempMessage.timestamp <= message.timestamp {
                            self.beforeMessage = tempMessage
                        }
                    } else {
                        self.beforeMessage = tempMessage
                    }
                    debugPrint("服务器返回消息时间:", tempMessage.timestamp.description)
                    self.insertMessage(tempMessage)
                }
                
                if limitMessages.count < 10 {
                    self.loadType = .noMore
                    self.tableView.mj_header?.isHidden = true
                }
                
                self.tableView.reloadData()
            }
        default:
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_header?.isHidden = true
        }
    }
    
    // MARK: - 插入消息
    fileprivate func insertMessage(_ message:NIMMessage) {
        objc_sync_enter(self.messageDatas)
        var insertViewModel:MessageViewModel = MessageViewModel.init(message)
        switch message.messageType {
        case .image:
            insertViewModel = MessageImageViewModel.init(message)
        case .audio:
            insertViewModel = MessageAudioViewModel.init(message)
        case .video:
            insertViewModel = MessageVideoViewModel.init(message)
        case .custom:
            if let customObj:NIMCustomObject = message.messageObject as? NIMCustomObject {
                let attachmentDecode = NIMAttachmentDecode.init()
                var tempAttachment = customObj.attachment
                if tempAttachment is GreetInfoGreetTaskAttachmentViewModel {
                    tempAttachment = attachmentDecode.decodeAttachment(tempAttachment?.encode())
                } else if tempAttachment is GreetInfoGreetGreetAttachmentViewModel {
                    tempAttachment = attachmentDecode.decodeAttachment(tempAttachment?.encode())
                }
                
                guard let attObj = tempAttachment as? NIMAttachmentObj else {
                    objc_sync_exit(self.messageDatas)
                    return
                }
                
                switch attObj.type {
                case "greeting":
                    guard let greetingData = attObj.jsonData as? Dictionary<String, Any> else {
                        objc_sync_exit(self.messageDatas)
                        return
                    }
                    
                    let greetingViewModel = GreetInfoGreetViewModel.init(jsonData: greetingData)
                    message.text = greetingViewModel.firstContent
                    insertViewModel = MessageTextViewModel.init(message)
                case "greeting_with_task":
                    guard let greetingData = attObj.jsonData as? Dictionary<String, Any> else {
                        objc_sync_exit(self.messageDatas)
                        return
                    }
                    insertViewModel = MessageTaskViewModel.init(message, greetData: greetingData)
                case "greeting_with_greeting":
                    guard let greetingData = attObj.jsonData as? Dictionary<String, Any> else {
                        objc_sync_exit(self.messageDatas)
                        return
                    }
                    
                    insertViewModel = MessageGreetingViewModel.init(message, greetData: greetingData)
                default:
                    debugPrint("出现自定义消息不认识的类型")
                    objc_sync_exit(self.messageDatas)
                    return
                }
            }
        case .text:
            insertViewModel = MessageTextViewModel.init(message)
        default:
            debugPrint("出现不认识的消息")
            objc_sync_exit(self.messageDatas)
            return
        }
        
        if self.messageDatas[insertViewModel.timeMinute] == nil {
            self.messageDatas[insertViewModel.timeMinute] = [insertViewModel]
            self.messageKeys = self.messageDatas.keys.sorted()
            if let changeSection = self.messageKeys.firstIndex(of: insertViewModel.timeMinute) {
                self.tableView.beginUpdates()
                self.tableView.insertSections([changeSection], animationStyle: .none)
                self.tableView.endUpdates()
            } else {
                self.tableView.reloadData()
            }
        } else {
            self.messageDatas[insertViewModel.timeMinute]?.append(insertViewModel)
            self.messageDatas[insertViewModel.timeMinute]?.sort(by: { (viewModel1, viewModel2) -> Bool in
                return viewModel1.timeStamp < viewModel2.timeStamp
            })
            
            if let changeSection = self.messageKeys.firstIndex(of: insertViewModel.timeMinute) {
                self.tableView.reloadSections([changeSection], animationStyle: .none)
            } else {
                self.tableView.reloadData()
            }
        }
        
        objc_sync_exit(self.messageDatas)
    }
    
    
    /// 查询ViewModel
    /// - Parameters:
    ///   - isNew: 是否为新的:true:不筛选时间    false:筛选时间
    func searchViewModel(_ message:NIMMessage, isNew:Bool) -> MessageViewModel? {
        if isNew {
            for messageArray in self.messageDatas.values {
                for tempViewModel in messageArray {
                    if tempViewModel.message?.messageId == message.messageId {
                        return tempViewModel
                    }
                }
            }
        } else {
            let timeInt = Int64.init(message.timestamp)
            let minTime = TimeInterval.init(timeInt - (timeInt % 60))
            for tempViewModel in self.messageDatas[minTime] ?? [] {
                if tempViewModel.message?.messageId == message.messageId {
                    return tempViewModel
                }
            }
        }
        return nil
    }
    
    func resetAllMessage(audioPlaying:Bool) {
        NIMSDK.shared().mediaManager.stopPlay()
        
        for tempArray in self.messageDatas.values {
            for tempViewModel in tempArray {
                guard let audioViewModel = tempViewModel as? MessageAudioViewModel else {
                    continue
                }
                audioViewModel.isPlaying.accept(audioPlaying)
            }
        }
    }
    
    func resetAllMessage(readed:Bool) {
        for tempArray in self.messageDatas.values {
            for tempViewModel in tempArray {
                tempViewModel.showStatus = .readed
            }
        }
    }
    
    func scrollTableViewToBottom() {
        self.view.layoutIfNeeded()
        self.tableView.scrollToBottom(animated: true)
    }
}


extension SessionInfoViewController {
    // MARK: - 交互
    @objc fileprivate func audioPlayBtnAction(sender:UIButton) {
        let sec:Int = sender.tag / 10000
        let row:Int = sender.tag % 10000
        
        let timeKey = self.messageKeys[sec]
        guard let audioViewModel = self.messageDatas[timeKey]?[row] as? MessageAudioViewModel else {
            MBProgressHUD.showError("Audio doesn't exist".localiz())
            return
        }
        self.playAudio(audioViewModel, indexPath: IndexPath.init(row: row, section: sec))
    }
    
    @objc fileprivate func imageBtnAction(sender:UIButton) {
        self.audioAllStop()
        let sec:Int = sender.tag / 10000
        let row:Int = sender.tag % 10000
        
        let timeKey = self.messageKeys[sec]
        let imageViewModel = self.messageDatas[timeKey]?[row] as? MessageImageViewModel
        guard let imageURL = imageViewModel?.imageURL else {
            MBProgressHUD.showError("Image doesn't exist".localiz())
            return
        }
        
//        self.jumpPreViewResource(resources: [imageURL])
        self.jumpNewPreViewResource(resources:[imageURL])
    }
    
    @objc fileprivate func videoPlayBtnAction(sender:UIButton) {
        self.audioAllStop()
        let sec:Int = sender.tag / 10000
        let row:Int = sender.tag % 10000
        let timeKey = self.messageKeys[sec]
        let videoViewModel = self.messageDatas[timeKey]?[row] as? MessageVideoViewModel
        
        guard let videoURL = videoViewModel?.videoURL else {
            MBProgressHUD.showError("Video doesn't exist".localiz())
            return
        }
        self.preViewVideo(url: videoURL, cover: videoViewModel?.coverURL)
    }
    
    @objc fileprivate func failureBtnAction(sender:UIButton) {
        let sec:Int = sender.tag / 10000
        let row:Int = sender.tag % 10000
        let timeKey = self.messageKeys[sec]
        let messageViewModel = self.messageDatas[timeKey]?[row]
        
        guard let failureMessage = messageViewModel?.message else {
            return
        }
        
        messageViewModel?.sendStatus.accept(.sending)
        if messageViewModel?.createType == MessageCreatorType.me {
            //重新发送
            try? NIMSDK.shared().chatManager.resend(failureMessage)
        } else {
            //重新接收
            try? NIMSDK.shared().chatManager.fetchMessageAttachment(failureMessage)
        }
    }
    
    @objc fileprivate func otherHeaderBtnAction(sender:UIButton) {
        guard let userId = Int64(self.userId ?? "-1") else {
            return
        }
        
        if userId >= 0 {
            GlobalRouter.shared.jumpUserHomePage(userid: userId)
        }
    }
}

extension SessionInfoViewController {
    func audioAllStop() {
        NIMSDK.shared().mediaManager.stopPlay()
        self.resetAllMessage(audioPlaying: false)
    }
    
    // MARK: 播放音频  indexPath = -1 停止所有播放
    func playAudio(_ viewModel:MessageAudioViewModel, indexPath:IndexPath) {
        NIMSDK.shared().mediaManager.stopPlay()
        
        for i in 0..<self.messageKeys.count {
            let tempTimeKey = self.messageKeys[i]
            let tempRowCount = self.messageDatas[tempTimeKey]?.count ?? 0
            for j in 0..<tempRowCount {
                if (indexPath.section != i || indexPath.row != j) {
                    if let tempViewModel = self.messageDatas[tempTimeKey]?[j] as? MessageAudioViewModel, tempViewModel.isPlaying.value {
                        tempViewModel.isPlaying.accept(false)
                    }
                }
            }
        }
        
        guard let message = viewModel.message, let audioPath = viewModel.audioPath else {
            MBProgressHUD.showError("The audio file is wrong!".localiz())
            return
        }
        
        if viewModel.downloadStatus.value == .needDownload, viewModel.downloadStatus.value == .failed {
            try? NIMSDK.shared().chatManager.fetchMessageAttachment(message)
            viewModel.downloadStatus.accept(.downloading)
            return
        }
        
        if !viewModel.isPlaying.value {
            viewModel.isPlaying.accept(true)
            NIMSDK.shared().mediaManager.play(audioPath)
        } else {
            viewModel.isPlaying.accept(false)
            NIMSDK.shared().mediaManager.stopPlay()
        }
    }
    
    func  jumpPublish() {
        let userpublish = UserPublishViewController.loadFromNib()
        userpublish.tasktype = self.matchGreeting?.task?.type ?? .photo
        userpublish.tipTaskDes = self.matchGreeting?.task?.descriptionField
        userpublish.taskid = self.matchGreeting?.task?.taskId
        userpublish.toUserID = self.matchGreeting?.userId
        self.navigationController?.pushViewController(userpublish, animated: true)
    }
    
}

extension SessionInfoViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.3) {
            let overHeight = self.view.mj_h - self.tableView.mj_y - (48 + 4 + keyboardHeight)
            var offsetY = self.tableView.contentSize.height - overHeight
            offsetY = offsetY > 0 ? offsetY : 0
            self.editView.textViewBottom.constant = 40 + keyboardHeight
            self.scrollTableViewToBottom()
            self.view.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            if !self.editView.audioBtn.isSelected && !self.editView.imageBtn.isSelected && !self.editView.emojiBtn.isSelected {
                self.editView.textViewBottom.constant = 40 + safeBottomH
            }
            self.view.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
}

extension SessionInfoViewController : UITableViewDelegate, UITableViewDataSource {
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        debugPrint("")
    //    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.messageKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let timeKey = self.messageKeys[section]
        return self.messageDatas[timeKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= self.messageKeys.count {
            return 0.5
        }
        
        let timeKey = self.messageKeys[indexPath.section]
        if let tempViewModel = self.messageDatas[timeKey]?[indexPath.row] {
            return tempViewModel.cellHeight
        }
        
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let timeKey = self.messageKeys[section]
        
        if let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "timeHeaderId") as? MessageTimeHeaderView {
            headView.timeLabel.text = String.updateTimeToCurrennTime(timeStamp: timeKey)
            return headView
        }
        
        let headView = MessageTimeHeaderView(reuseIdentifier: "timeHeaderId")
        headView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 22)
        headView.timeLabel.text = String.updateTimeToCurrennTime(timeStamp: timeKey)
        return headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "timeFooterId") as? MessageTimeFooterView {
            return footerView
        }
        
        let footerView = MessageTimeFooterView.init(reuseIdentifier: "timeFooterId")
        footerView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 0.5)
        footerView.backgroundColor = .white
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section >= self.messageKeys.count {
            return UITableViewCell.init()
        }
        
        let timeKey = self.messageKeys[indexPath.section]
        if indexPath.row >= self.messageDatas[timeKey]?.count ?? 0 {
            return UITableViewCell.init()
        }
        
        guard let tempViewModel = self.messageDatas[timeKey]?[indexPath.row] else {
            return UITableViewCell.init()
        }
        
        if tempViewModel.createType == .me {
            switch tempViewModel.messageType {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toTextId", for: indexPath) as! MessageToTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toAudioId", for: indexPath) as! MessageToAudioTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageAudioViewModel)
                cell.playBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.playBtn.addTarget(self, action: #selector(self.audioPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toImageId", for: indexPath) as! MessageToImageTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageImageViewModel)
                cell.imageBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.imageBtn.addTarget(self, action: #selector(self.imageBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toVideoId", for: indexPath) as! MessageToVideoTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageVideoViewModel)
                cell.playBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.playBtn.addTarget(self, action: #selector(self.videoPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .task:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toTaskId", for: indexPath) as! MessageToTaskTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTaskViewModel)
                cell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
                return cell
            case .greeting:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toGreetingId", for: indexPath) as! MessageToGreetingTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageGreetingViewModel)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toTextId", for: indexPath) as! MessageToTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                return cell
            }
        }
        else {
            switch tempViewModel.messageType {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromTextId", for: indexPath) as! MessageFromTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromAudioId", for: indexPath) as! MessageFromAudioTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageAudioViewModel)
                cell.playBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.playBtn.addTarget(self, action: #selector(self.audioPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromImageId", for: indexPath) as! MessageFromImageTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageImageViewModel)
                cell.imageBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.imageBtn.addTarget(self, action: #selector(self.imageBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromVideoId", for: indexPath) as! MessageFromVideoTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageVideoViewModel)
                cell.playBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.faileBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.playBtn.addTarget(self, action: #selector(self.videoPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .task:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromTaskId", for: indexPath) as! MessageFromTaskTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTaskViewModel)
                cell.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .greeting:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromGreetingId", for: indexPath) as! MessageFromGreetingTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageGreetingViewModel)
                cell.headBtn.tag = indexPath.section * 10000 + indexPath.row
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromTextId", for: indexPath) as! MessageFromTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                return cell
            }
        }
    }
}

///消息的回调
extension SessionInfoViewController : NIMChatManagerDelegate {
    func willSend(_ message: NIMMessage) {
        debugPrint("即将发送消息回调")
        if let tempViewModel = self.searchViewModel(message, isNew: false) {
            tempViewModel.sendStatus.accept(.sending)
        } else {
            self.insertMessage(message)
            self.scrollTableViewToBottom()
        }
    }
    
    func uploadAttachmentSuccess(_ urlString: String, for message: NIMMessage) {
        debugPrint("上传资源文件成功的回调")
    }
    
    func send(_ message: NIMMessage, progress: Float) {
        debugPrint("发送消息进度回调:" + progress.description)
        guard let tempViewModel = self.searchViewModel(message, isNew: false) else {
            return
        }
        
        if let audioViewModel = tempViewModel as? MessageAudioViewModel {
            audioViewModel.progress.accept(progress * 100.0)
        } else if let imageViewModel = tempViewModel as? MessageImageViewModel {
            imageViewModel.progress.accept(progress * 100.0)
        } else if let videoViewModel = tempViewModel as? MessageVideoViewModel {
            videoViewModel.progress.accept(progress * 100.0)
        } else {
            debugPrint("发送消息进度错误 = \(message.messageId)")
        }
    }
    
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        debugPrint("发送消息完成回调")
        guard let tempViewModel = self.searchViewModel(message, isNew: true) else {
            return
        }
        
        if error == nil {
            tempViewModel.sendStatus.accept(.sended)
        } else {
            tempViewModel.sendStatus.accept(.failure)
        }
    }
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        debugPrint("收到消息回调")
        
        var scrollBottom = false    //是否滚动到底部
        if ((self.tableView.contentOffset.y + self.tableView.mj_h) >= (self.tableView.contentSize.height - 20)) {
            self.scrollTableViewToBottom()
            scrollBottom = true
        }
        
        var hasThisSession = false
        for message in messages {
            if message.session?.sessionId == self.session?.sessionId {
                self.insertMessage(message)
                hasThisSession = true
            }
        }
        
        if !hasThisSession {
            return
        }
        
        if scrollBottom {
            self.scrollTableViewToBottom()
        }
        
        if let sendSession = self.session {
            NIMSDK.shared().conversationManager.markAllMessagesRead(in: sendSession)
        }
    }
    
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        debugPrint("收到消息回执")
    }
    
    func onRecvRevokeMessageNotification(_ notification: NIMRevokeMessageNotification) {
        debugPrint("收到消息被撤回的通知")
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
        //        debugPrint("收取消息附件回调:", progress.debugDescription)
        guard let tempViewModel = self.searchViewModel(message, isNew: false) else {
            return
        }
        if let audioViewModel = tempViewModel as? MessageAudioViewModel {
            audioViewModel.progress.accept(progress * 100.0)
        } else if let imageViewModel = tempViewModel as? MessageImageViewModel {
            imageViewModel.progress.accept(progress * 100.0)
        } else if let videoViewModel = tempViewModel as? MessageVideoViewModel {
            videoViewModel.progress.accept(progress * 100.0)
        } else {
            debugPrint("发送消息进度错误 = \(message.messageId)")
        }
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        debugPrint("收取消息附件完成回调:" + (error == nil ? "成功" : error.debugDescription))
        guard let tempViewModel = self.searchViewModel(message, isNew: true) else {
            return
        }
        
        if error == nil {
            tempViewModel.receiveStatus.accept(.received)
            if let audioViewModel = tempViewModel as? MessageAudioViewModel {
                audioViewModel.resetMessageObj(message)
            } else if let videoViewModel = tempViewModel as? MessageVideoViewModel {
                videoViewModel.resetMessageObj(message)
            }
            
            self.tableView.reloadData()
        } else {
            tempViewModel.receiveStatus.accept(.failure)
        }
    }
}

extension SessionInfoViewController : NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        debugPrint("开始播放音频的回调:" + filePath)
    }
    
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        debugPrint("播放完音频的回调:" + filePath)
        self.resetAllMessage(audioPlaying: false)
    }
    
    func playAudio(_ filePath: String, progress value: Float) {
        //        debugPrint("播放完音频的进度回调:" + value.debugDescription)
    }
    
    func stopPlayAudio(_ filePath: String, didCompletedWithError error: Error?) {
        debugPrint("停止播放音频的回调:" + filePath)
    }
    
    func playAudioInterruptionBegin() {
        debugPrint("播放音频开始被打断回调")
    }
    
    func playAudioInterruptionEnd() {
        debugPrint("播放音频结束被打断回调")
    }
    
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        debugPrint("开始录制音频的回调 如果录音失败，filePath 有可能为 nil")
        self.resetAllMessage(audioPlaying: false)
    }
    
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?) {
        debugPrint("录制音频完成")
        if error != nil || filePath == nil {
            debugPrint("录制音频完成->失败" + error.debugDescription)
            return
        }
        
        guard let recordFilePath = filePath else {
            debugPrint("录制音频完成->文件错误")
            return
        }
        
        guard let sendSession = self.session else {
            return
        }
        
        let audioURL = URL(fileURLWithPath: recordFilePath)
        if let audioData = try? Data.init(contentsOf: URL(fileURLWithPath: recordFilePath)) {
            if audioData.isEmpty {
                debugPrint("文件错误:\(recordFilePath)")
                MBProgressHUD.showError("The recording is too short".localiz())
                return
            }
            
            let audioObj = NIMAudioObject.init(data: audioData, extension: audioURL.pathExtension)
            let message = NIMMessage.init()
            message.messageObject = audioObj
            message.apnsPayload = self.apnsPayload
            try? NIMSDK.shared().chatManager.send(message, to: sendSession)
        }
    }
    
    func recordAudioDidCancelled() {
        debugPrint("录音被取消的回调")
    }
    
    func recordAudioProgress(_ currentTime: TimeInterval) {
        debugPrint("音频录制进度更新回调")
    }
    
    func recordAudioInterruptionBegin() {
        debugPrint("录音开始被打断回调")
    }
    
    func recordAudioInterruptionEnd() {
        debugPrint("录音结束被打断回调")
    }
}

extension  SessionInfoViewController : UIGestureRecognizerDelegate{
    func  addTapDealHideView()  {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideToolMoreView))
        tap.delegate = self
        self.tableView.addGestureRecognizer(tap)
        self.tableView.isUserInteractionEnabled = true
    }
    
    @objc func hideToolMoreView() {
        self.editView.resetInitView(false)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.superview?.classForCoder == UITableViewCell().classForCoder{
            return false
        }
        
        return true
    }
}


extension  SessionInfoViewController {
    
    /// 插入新的视频消息im
    /// - Parameters:
    ///   - tempModel: <#tempModel description#>
    ///   - message: <#message description#>
    ///   - sendSession: <#sendSession description#>
    fileprivate func insertVideoMessage(_ tempModel: ZLPhotoModel, _ message: NIMMessage, _ sendSession: NIMSession) {
        tempModel.fetandConvertVideoData { (fileName, filePath) in
            guard let resultPath = filePath else {
                return
            }
            let resultURL = URL(string: resultPath) ?? URL.init(fileURLWithPath: resultPath)
            guard let videoData = try? Data.init(contentsOf: resultURL) else {
                debugPrint("获取视频失败:\(resultURL)")
                return
            }
            
            let videoObj = NIMVideoObject.init(data: videoData, extension: resultURL.pathExtension.lowercased())
            message.messageObject = videoObj
            message.apnsPayload = self.apnsPayload
            try? NIMSDK.shared().chatManager.send(message, to: sendSession)
        }
    }
    
    /// 插入新的图片消息
    /// - Parameters:
    ///   - tempModel: <#tempModel description#>
    ///   - message: <#message description#>
    ///   - sendSession: <#sendSession description#>
    fileprivate func insertNewImageMessage(_ tempModel: ZLPhotoModel, _ message: NIMMessage, _ sendSession: NIMSession) {
        //获取原图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        option.isSynchronous = true
        manager.requestImage(for: tempModel.asset, targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (originImage, info) in
            guard let sendImage = originImage?.smartCompressImg() else {
                debugPrint("转换图片错误")
                return
            }
            let imageObj = NIMImageObject.init(image: sendImage)
            message.messageObject = imageObj
            message.apnsPayload = self.apnsPayload
            try? NIMSDK.shared().chatManager.send(message, to: sendSession)
        }
    }
}
