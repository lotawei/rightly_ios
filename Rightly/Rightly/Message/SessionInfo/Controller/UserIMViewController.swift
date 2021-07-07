//
//  UserIMViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/7/1.
//

import UIKit
import RxSwift
import RxCocoa
import NIMSDK

class UserIMViewController: BaseViewController {
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
        NIMSDK.shared().chatManager.remove(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let viewModel:UserIMViewModel
    fileprivate let session:NIMSession
    fileprivate let apnsPayload:[AnyHashable:Any]
    
    lazy var editView:MessageEditView = {
        let resultView = MessageEditView.loadNibView() ?? MessageEditView.init()
        return resultView
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
        })
        return resultView
    }()
    
    init(session:NIMSession) {
        let userId = UserManager.manager.currentUser?.additionalInfo?.userId ?? 0
        self.session = session
        self.viewModel = UserIMViewModel.init(session)
        self.apnsPayload = ["userId" : userId, "sessionId" : session.sessionId, "sessionType" : session.sessionType.rawValue]
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().chatManager.add(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.messageTimeKeys.count <= 0 {
            self.tableView.mj_header?.beginRefreshing()
        }
        
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NIMSDK.shared().mediaManager.stopPlay()
        NIMSDK.shared().mediaManager.cancelRecord()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Function
extension UserIMViewController {
    fileprivate func scrollTableViewToBottom() {
        
    }
}

// MARK: - NSNotification回调
extension UserIMViewController {
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
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
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            if !self.editView.audioBtn.isSelected && !self.editView.imageBtn.isSelected && !self.editView.emojiBtn.isSelected {
                self.editView.textViewBottom.constant = 40 + safeBottomH
            }
            self.view.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSource
extension UserIMViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.messageTimeKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let timeKey = self.viewModel.messageTimeKeys[section]
        return self.viewModel.messageList[timeKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let timeKey = self.viewModel.messageTimeKeys[section]
        let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "timeHeaderId") as? MessageTimeHeaderView
        headView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 22)
        headView?.timeLabel.text = String.updateTimeToCurrennTime(timeStamp: timeKey)
        return headView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tempViewModel = self.viewModel.getMessViewModel(indexPath) else {
            return UITableViewCell.init()
        }
        
        if tempViewModel.createType == .me {
            switch tempViewModel.messageType {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toTextId", for: indexPath) as! MessageToTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toAudioId", for: indexPath) as! MessageToAudioTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageAudioViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.playBtn.addTarget(self, action: #selector(self.audioPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toImageId", for: indexPath) as! MessageToImageTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageImageViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.imageBtn.addTarget(self, action: #selector(self.imageBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toVideoId", for: indexPath) as! MessageToVideoTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageVideoViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.playBtn.addTarget(self, action: #selector(self.videoPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .task:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toTaskId", for: indexPath) as! MessageToTaskTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTaskViewModel)
                return cell
            case .greeting:
                let cell = tableView.dequeueReusableCell(withIdentifier: "toGreetingId", for: indexPath) as! MessageToGreetingTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageGreetingViewModel)
                return cell
            }
        } else {
            switch tempViewModel.messageType {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromTextId", for: indexPath) as! MessageFromTextTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTextViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromAudioId", for: indexPath) as! MessageFromAudioTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageAudioViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.playBtn.addTarget(self, action: #selector(self.audioPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromImageId", for: indexPath) as! MessageFromImageTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageImageViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.imageBtn.addTarget(self, action: #selector(self.imageBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromVideoId", for: indexPath) as! MessageFromVideoTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageVideoViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                cell.playBtn.addTarget(self, action: #selector(self.videoPlayBtnAction(sender:)), for: .touchUpInside)
                cell.faileBtn.addTarget(self, action: #selector(self.failureBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .task:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromTaskId", for: indexPath) as! MessageFromTaskTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageTaskViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            case .greeting:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fromGreetingId", for: indexPath) as! MessageFromGreetingTableViewCell
                cell.bindingViewModel(tempViewModel as! MessageGreetingViewModel)
                cell.setupViewTag(indexPath.section * 10000 + indexPath.row)
                cell.headBtn.addTarget(self, action: #selector(self.otherHeaderBtnAction(sender:)), for: .touchUpInside)
                return cell
            }
        }
    }
}

// MARK: - 交互
extension UserIMViewController {
    @objc fileprivate func audioPlayBtnAction(sender:UIButton) {
        let indexPath = IndexPath(row: (sender.tag % 10000), section: (sender.tag / 10000))
        self.viewModel.stopAllAudio(except: indexPath)
        guard let audioViewModel = self.viewModel.getMessViewModel(indexPath) as? MessageAudioViewModel else {
            MBProgressHUD.showError("Audio doesn't exist".localiz())
            return
        }
        
        if !audioViewModel.playAudio() {
            MBProgressHUD.showError("The audio file is wrong!".localiz())
            return
        }
    }
    
    @objc fileprivate func imageBtnAction(sender:UIButton) {
        self.viewModel.stopAllAudio(except: nil)
        let imageViewModel = self.viewModel.getMessViewModel(sender.tag) as? MessageImageViewModel
        guard let imageURL = imageViewModel?.imageURL else {
            MBProgressHUD.showError("Image doesn't exist".localiz())
            return
        }
        
        self.jumpNewPreViewResource(resources:[imageURL])
    }
    
    @objc fileprivate func videoPlayBtnAction(sender:UIButton) {
        self.viewModel.stopAllAudio(except: nil)
        guard let videoViewModel = self.viewModel.getMessViewModel(sender.tag) as? MessageVideoViewModel, let videoURL = videoViewModel.videoURL else {
            MBProgressHUD.showError("Video doesn't exist".localiz())
            return
        }
        
        self.preViewVideo(url: videoURL, cover: videoViewModel.coverURL)
    }
    
    @objc fileprivate func failureBtnAction(sender:UIButton) {
        let messageViewModel = self.viewModel.getMessViewModel(sender.tag)
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
        guard let messageViewModel = self.viewModel.getMessViewModel(sender.tag) else {
            return
        }
        
        if let accId = messageViewModel.accId, let userId = Int64(accId) {
            GlobalRouter.shared.jumpUserHomePage(userid: userId)
        }
    }
}

//MARK: - NIMMediaManagerDelegate
extension UserIMViewController:NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        debugPrint("播放完音频的回调:" + filePath)
        self.viewModel.stopAllAudio(except: nil)
    }
    
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        debugPrint("开始录制音频的回调 如果录音失败，filePath 有可能为 nil")
        self.viewModel.stopAllAudio(except: nil)
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
            try? NIMSDK.shared().chatManager.send(message, to: self.session)
        }
    }
}

//MARK: - NIMChatManagerDelegate
extension UserIMViewController:NIMChatManagerDelegate {
}



