//
//  GreetInfoViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import NIMSDK

class GreetInfoViewController: BaseViewController {
    var otherUserId:String?
    private var taskCreatTime:TimeInterval = 0
    private var userInfo:UserAdditionalInfo?
    private let greetporvider = MessageTaskGreetProvider.init()
    private let userPorvider = UserProVider.init()
    var relationType:FriendType?
    var taskViewModel:GreetInfoGreetViewModel?
    var greetList:[GreetInfoGreetViewModel] = []
    
    /// 是否有历史模板动态
    var hasTaskHistory:Bool = false {
        didSet {
            let color = hasTaskHistory ? UIColor.black:UIColor.init(hex: "B7B7B7")
            taskFromView?.choosePostBtn.setTitleColor(color, for: .normal)
            taskFromView?.choosePostBtn.setTitleColor(color, for: .selected)
            taskFromView?.choosePostBtn.setTitleColor(color, for: .highlighted)
        }
    }
    var taskFromView:GreetInfoTaskFromView? = nil
    lazy var followBtn:FollowUIButton = {
        let resultBtn = FollowUIButton.init(type: .custom)
        resultBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 28)
        resultBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext:{ [weak self] (sender) in
                guard let `self` = self  else {return }
                guard let  userid = Int64(self.otherUserId ?? "0") ,userid > 0 else {
                    return
                }
                self.followUser(userid: userid)
            }).disposed(by: self.rx.disposeBag)
        resultBtn.alpha = 0
        return resultBtn
    }()
    
    lazy var scrollView : UIScrollView = {
        let resultView = UIScrollView()
        return resultView
    }()
    
    lazy var lockEditView: GreetInfoLockEditView = {
        let resultView = GreetInfoLockEditView.loadNibView() ?? GreetInfoLockEditView()
        return resultView
    }()
    
    init(_ userId:String) {
        super.init(nibName: nil, bundle: nil)
        self.otherUserId = userId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_interactivePopDisabled = true
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NIMSDK.shared().chatManager.add(self)
        if self.relationType == nil {
            self.requestData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NIMSDK.shared().chatManager.remove(self)
    }
    
    private func setupView() {
        let rightItem = UIBarButtonItem.init(customView: self.followBtn)
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.title = "User Name"
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.lockEditView)
        self.scrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(self.lockEditView.snp.top)
        }
        
        self.lockEditView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(95 + safeBottomH)
        }
    }
    
    private func updateView() {
        for tempView in self.scrollView.subviews.reversed() {
            tempView.removeFromSuperview()
        }
        
        switch self.relationType {
        case .friended:
            self.resetCurrentCtrl()
        case .fromMe:
            self.setupTitleView()
            self.setupFromMeView()
        case .toMe:
            self.setupTitleView()
            self.setupToMeView()
        default:
            self.setupTitleView()
            self.setupIrrelevantView()
        }
    }
    
    private func setupTitleView() {
        let setupTime = self.relationType == FriendType.irrelevant ? Date.init().timeIntervalSince1970 : self.taskCreatTime
        let viewY:CGFloat = self.setupTimeView(8.0, setupTime)
        
        guard let titleView = GreetInfoTitleView.loadNibView() else {
            return
        }
        titleView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 60)
        titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: self.userInfo?.nickname ?? "other")
        self.scrollView.addSubview(titleView)
    }
    
    private func setupIrrelevantView() {
        guard let taskViewModel = self.taskViewModel, let friendStatus = self.relationType else {
            return
        }
        guard let taskFromView = GreetInfoTaskFromView.loadNibView() else {
            return
        }
        taskFromView.frame = CGRect(x: 0, y: 108.0, width: screenWidth, height: 212)
        taskFromView.headBtn.addTarget(self, action: #selector(userHeadBtnAction(_:)), for: .touchUpInside)
        self.scrollView.addSubview(taskFromView)
        taskFromView.bindViewModel(taskViewModel, friendStatus: friendStatus, userInfo: self.userInfo ?? UserAdditionalInfo())
        taskFromView.doItNowBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext:{ (sender) in
                guard let taskType = self.taskViewModel?.taskInfo?.type, let taskId = self.taskViewModel?.taskInfo?.taskId, let toUserID = self.otherUserId else {
                    MBProgressHUD.showError("Task does not exist".localiz())
                    return
                }
                let userpublish = UserPublishViewController.loadFromNib()
                userpublish.tasktype = taskType
                userpublish.tipTaskDes = self.taskViewModel?.taskInfo?.descriptionField
                userpublish.taskid = Int64(taskId)
                userpublish.toUserID = Int64(toUserID)
                userpublish.blockRefresh = {
                    [weak self] in
                    self?.requestData()
                }
                userpublish.userpublishSuccess =  {
                    [weak self] userid in
                    guard let `self` = self  else {return }
                    self.showAlterUnlockSuccess(userid: userid)
                }
                self.navigationController?.pushViewController(userpublish, animated: true)
                
            }).disposed(by: self.rx.disposeBag)
        taskFromView.choosePostBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext:{ (sender) in
                guard let taskType = self.taskViewModel?.taskInfo?.type, let toUserID = self.otherUserId ,let  taskid = self.taskViewModel?.taskInfo?.taskId  else {
                    MBProgressHUD.showError("Task does not exist".localiz())
                    return
                }
                
                self.jumpTemplateChoose(taskType: taskType, taskid: taskid, toUserID: toUserID)
            }).disposed(by: self.rx.disposeBag)
        self.taskFromView = taskFromView
        
    }
    
    /// 检查是否有相关类型的
    /// - Parameters:
    ///   - taskType: <#taskType description#>
    ///   - hasResult: <#hasResult description#>
    fileprivate func checkTemplate(taskType:TaskType,_ hasResult:@escaping((_ hasTasktype:Bool)-> Void)) {
        MatchTaskGreetingProvider.init().greetingOwer(1, pageSize: 2, taskType: taskType.rawValue, disposebag: self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let results  = res.modelArrType(GreetingResult.self) {
                if results.count > 0 {
                                    hasResult(true)
                                }else{
                                    hasResult(false)
                                }
            }
        },onError: { (err) in
            DispatchQueue.main.async {
                              hasResult(true)
                          }
        }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func jumpTemplateChoose(taskType:TaskType,taskid:Int64,toUserID:String){
        if  hasTaskHistory {
            let templateVc = GreetingUsertemplateViewController.loadFromNib()
            templateVc.usertaskId = Int64(taskid)
            templateVc.taskType = taskType
            templateVc.toUserid = Int64(toUserID)
            templateVc.refreshBlock = {
                [weak self] in
                self?.requestData()
            }
            self.navigationController?.pushViewController(templateVc, animated: true)
        }else{
            DispatchQueue.main.async {
                self.toastTip("There are no such historical developments".localiz())
            }
        }
    }
    // MARK: 向对方打招呼
    private func setupFromMeView() {
        var viewY:CGFloat = 100.0
        for greetViewModel in self.greetList {
            guard let taskFromView = GreetInfoTaskFromView.loadNibView() else {
                return
            }
            
            taskFromView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 116.0)
            taskFromView.headBtn.addTarget(self, action: #selector(userHeadBtnAction(_:)), for: .touchUpInside)
            self.scrollView.addSubview(taskFromView)
            taskFromView.bindViewModel(greetViewModel, friendStatus: .fromMe, userInfo: self.userInfo ?? UserAdditionalInfo())
            viewY = viewY + 116.0
            //            viewY = self.setupTimeView(viewY, greetViewModel.creatTimestamp)
            
            guard let greetToView = GreetInfoGreetToView.loadNibView() else {
                return
            }
            
            greetToView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 112.0)
            self.scrollView.addSubview(greetToView)
            greetToView.bindViewModel(greetViewModel)
            viewY = viewY + 112.0
        }
        self.scrollView.contentSize = CGSize(width: screenWidth, height: viewY)
    }
    func followUser(userid:Int64)  {
        UserProVider.focusUser(self.followBtn.isSelected, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
            guard let `self` = self  else {return }
            self.followBtn.isSelected =  isfocus
        }
        
    }
    // MARK: 向我打招呼
    private func setupToMeView() {
        var viewY:CGFloat = 100.0
        for i in 0..<self.greetList.count {
            let greetViewModel = greetList[i]
            guard let taskToView = GreetInfoTaskToView.loadNibView() else {
                return
            }
            
            taskToView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 106.0)
            self.scrollView.addSubview(taskToView)
            taskToView.bindViewModel(greetViewModel)
            viewY = viewY + 106.0
            //            viewY = self.setupTimeView(viewY, greetViewModel.creatTimestamp)
            
            guard let greetFromView = GreetInfoGreetFromView.loadNibView() else {
                return
            }
            
            greetFromView.headBtn.addTarget(self, action: #selector(userHeadBtnAction(_:)), for: .touchUpInside)
            greetFromView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 140.0)
            greetFromView.tag = i
            self.scrollView.addSubview(greetFromView)
            greetFromView.bindViewModel(greetViewModel, userInfo: self.userInfo ?? UserAdditionalInfo())
            viewY = viewY + 140.0
            // MARK: 同意打招呼
            greetFromView.acceptBtn.rx.controlEvent(.touchUpInside)
                .subscribe(onNext:{ (sender) in
                    if self.relationType == .friended {
                        self.requestGreetingDetails(true)
                        return
                    }
                    
                    if let accId = self.userInfo?.imAccId {
                        NIMSDK.shared().userManager.fetchUserInfos([accId], completion: nil)
                    }
                    
                    guard let startSendView = GreetInfoStartSendView.loadNibView() else {
                        return
                    }
                    startSendView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
                    UIApplication.shared.keyWindow?.addSubview(startSendView)
                    startSendView.snp.makeConstraints({ (make) in
                        make.edges.equalTo(0)
                    })
                    
                    startSendView.sendBtn.rx.controlEvent(.touchUpInside)
                        .subscribe(onNext:{ [weak self] (sender) in
                            guard let `self` = self else {return}
                            guard let greetingId = greetViewModel.greetingId else {
                                return
                            }
                            
                            MBProgressHUD.showStatusInfo("sending...")
                            let firstMessage = startSendView.textView.text ?? ""
                            self.greetporvider.greetingAllow(greetingId, firstMessage, self.rx.disposeBag)
                                .subscribe(onNext:{ (requestResponse) in
                                    self.relationType = .friended
                                    guard let sendAccId = self.userInfo?.imAccId else {
                                        debugPrint("发送用户错误")
                                        MBProgressHUD.dismiss()
                                        return
                                    }
                                    
                                    greetViewModel.agreeGreeting(firstMessage, userId: self.userInfo?.userId)
                                    let nickName:String = UserManager.manager.currentUser?.additionalInfo?.nickname ?? ""
                                    let pushTitle = nickName + " adopted your hello task.Go and say hello"
                                    let sendSession = NIMSession.init(sendAccId, type: .P2P)
                                    let message = NIMMessage.init()
                                    let customObj = NIMCustomObject.init()
                                    customObj.attachment = greetViewModel
                                    message.messageObject = customObj
                                    message.apnsContent = firstMessage
                                    let apnuserId = UserManager.manager.currentUser?.additionalInfo?.userId ?? 0
                                    let apnsessionid = UserManager.manager.currentUser?.additionalInfo?.imAccId ?? "0"
                                    message.apnsPayload = ["pushTitle" : pushTitle, "userId" : apnuserId, "sessionid" : apnsessionid, "sessiontype" : NIMSessionType.P2P.rawValue]
                                    try? NIMSDK.shared().chatManager.send(message, to: sendSession)
                                    startSendView.hiddenFromSupper()
                                    self.requestGreetingDetails(true)
                                }, onError: { (error) in
                                    MBProgressHUD.showError("send failure".localiz())
                                }).disposed(by: self.rx.disposeBag)
                        }).disposed(by: startSendView.rx.disposeBag)
                }).disposed(by: self.rx.disposeBag)
        }
        self.scrollView.contentSize = CGSize(width: screenWidth, height: viewY)
    }
    
    private func setupTimeView(_ viewY:CGFloat, _ time:TimeInterval) -> CGFloat {
        guard let timeView = GreetInfoTimeView.loadNibView() else {
            return viewY
        }
        timeView.timeLabel.text = String.updateTimeToCurrennTime(timeStamp: time)
        timeView.frame = CGRect(x: 0, y: viewY, width: screenWidth, height: 32.0)
        self.scrollView.addSubview(timeView)
        return viewY + 32.0
    }
    
    // MARK: - 重置当前ViewController
    private func resetCurrentCtrl() {
        guard let userId = self.otherUserId, let accId = self.userInfo?.imAccId, let currNavCtrl:RTNavgationViewController = self.navigationController as? RTNavgationViewController else {
            return
        }
        
        let session:NIMSession = NIMSession.init(accId, type: .P2P)
        
        let nextViewCtrl = SessionInfoViewController.init(session: session, userId: userId)
        var viewCtrls = currNavCtrl.viewControllers
        viewCtrls.removeLast()
        currNavCtrl.setViewControllers(viewCtrls, animated: false)
        currNavCtrl.pushViewController(nextViewCtrl, animated: false)
    }
    
    fileprivate func requestData()  {
        guard let userId = self.otherUserId else {
            MBProgressHUD.showError("User error".localiz())
            return
        }
        
        MBProgressHUD.showStatusInfo("Loading...".localiz())
        self.userPorvider.userAdditionalInfo(userId, self.rx.disposeBag).subscribe(onNext:{ [weak self] (userResponse) in
            guard let `self` = self else {return}
            if let dicData = userResponse.data as? [String:Any] {
                self.userInfo = dicData.kj.model(UserAdditionalInfo.self)
                self.title = self.userInfo?.nickname
                UIView.animate(withDuration: 0.4) {
                                   self.followBtn.alpha = 1
                }
                self.followBtn.isSelected = self.userInfo?.isfocused ?? false
                self.requestGreetingDetails(true)
            }
        },onError: { (err) in
            MBProgressHUD.showError("request failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func dealWithExtenDataProcess(_ userId:String,_ extendData: [String : Any], _ datas: [String : Any]) {
        GreetingManager.shared().updateNumber(-1)
        let extendStatus:Int = extendData["status"] as? Int ?? 0
        self.relationType = FriendType(rawValue: extendStatus)
        switch self.relationType {
        case .irrelevant:
            guard  var userTask:[String:Any] = extendData["userTask"] as? [String : Any] else {
                return
            }
            userTask["userId"] = userId
            self.taskViewModel = GreetInfoGreetViewModel.init(jsonData: userTask)
            self.taskCreatTime = self.taskViewModel?.creatTimestamp ?? 0
            if let tasktype = self.taskViewModel?.taskInfo?.type {
                self.checkTemplate(taskType: tasktype) { (hasTask) in
                    self.hasTaskHistory = hasTask
                }
            }
            self.lockEditView.diplayInfo.text = "submit_the_task".localiz()
        case .friended:
            if let accId = self.userInfo?.imAccId {
                let results:[[String:Any]] = datas["results"] as? [[String:Any]] ?? []
                if let resultDic = results.first {
                    let session = NIMSession.init(accId, type: .P2P)
                    SessionManager.shared().insertLocalGreetData(session, greetData: resultDic)
                }
            }
            
            self.resetCurrentCtrl()
            return
        default:
            let results:[[String:Any]] = datas["results"] as? [[String:Any]] ?? []
            for tempDic:[String:Any] in results {
                let tempViewModel = GreetInfoGreetViewModel(jsonData: tempDic)
                self.greetList.append(tempViewModel)
                self.taskCreatTime = tempViewModel.updateTimestamp
            }
            if let  firstdic = results.first {
                let  firtempvmmodel = GreetInfoGreetViewModel(jsonData: firstdic)
                if (firstdic["status"] as? Int) != 1 {
                    if UserManager.isOwnerMySelf(Int64(firtempvmmodel.toUserId ?? "0")) {
                        self.lockEditView.diplayInfo.text = "adopt_the_task".localiz()
                    } else {
                        self.lockEditView.diplayInfo.text = "wait_for_your_task_to_pass".localiz()
                    }
                }
            }
        }
        self.updateView()
    }
    
    fileprivate func requestGreetingDetails(_ needHidHUD:Bool) {
        guard let userId = self.userInfo?.userId else {
            MBProgressHUD.showError("request failed".localiz())
            return
        }
        
        self.greetporvider.greetingSomeoneDetails(String(userId), self.rx.disposeBag).subscribe(onNext: { [weak self] (requestResponse) in
            if needHidHUD {
                MBProgressHUD.dismiss()
            }
            guard let `self` = self  else {return }
            
            guard let datas = requestResponse.dicData,  let extendData = datas["extendData"] as? [String:Any]  else {
                               return
            }
            self.dealWithExtenDataProcess(String(userId),extendData, datas)
        },onError: { (err) in
            MBProgressHUD.showError("request failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    @objc func userHeadBtnAction(_ sender:UIButton) {
        guard let userId = Int64(self.otherUserId ?? "-1") else {
            return
        }
        if userId > 0 {
            GlobalRouter.shared.jumpUserHomePage(userid: userId)
        }
        //        self.showAlterUnlockSuccess(userid: userId)
    }
}


///消息的回调
extension GreetInfoViewController : NIMChatManagerDelegate {
    func onRecvMessages(_ messages: [NIMMessage]) {
        guard let accId = self.userInfo?.imAccId else {
            return
        }
        
        for tempMessage in messages {
            if tempMessage.session?.sessionId == accId {
                self.requestGreetingDetails(false)
                return
            }
        }
    }
}
