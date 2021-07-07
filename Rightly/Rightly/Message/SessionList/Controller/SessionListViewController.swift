//
//  SessionListViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/5.
//

import UIKit
import RxSwift
import NIMSDK
import RxCocoa

fileprivate let cellSizeheight:CGFloat = 66.0
class SessionListViewController: BaseViewController {
    private var showEmpty = false {
        didSet {
            self.tableView.setNeedsDisplay()
        }
    }
    private var emptyView:UIView?=nil
    private var lastUpdateAt:Int64 = 0
    private var greetProvider = MessageTaskGreetProvider.init()
    private var greetViewModel:SessionListGreetViewModel = SessionListGreetViewModel()
    private var messageDatas:[SessionListCellViewModel] = [] 
    lazy var messageBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(messageClick(_:)), for: .touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage.init(named: "messagetip_black"), for: .normal)
        return button
    }()
    lazy var tableView:UITableView = {
        let resultView = UITableView()
        resultView.separatorStyle = .none
        resultView.rowHeight = cellSizeheight
        resultView.delegate = self
        resultView.dataSource = self
        resultView.register(.init(nibName: "SessionListTableViewCell", bundle: nil), forCellReuseIdentifier: "sessionListId")
        resultView.register(.init(nibName: "SessionNewGreetTableViewCell", bundle: nil), forCellReuseIdentifier: "newGreetId")
        return resultView
    }()
    
    deinit {
        NIMSDK.shared().userManager.remove(self)
        NIMSDK.shared().conversationManager.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  rightBtn = UIBarButtonItem.init(customView: self.messageBtn)
        self.navigationItem.rightBarButtonItem  = rightBtn
        NIMSDK.shared().conversationManager.add(self)
        NIMSDK.shared().userManager.add(self)
        self.updateLastTime()
        self.setupView()
        self.subscribeData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SessionManager.shared().loadAllSession()
        self.updateFriends(1)
        self.configUnReadNumber()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if NIMSDK.shared().loginManager.isLogined() {
            self.updateData()
            self.refreshData()
            self.updateUserList()
        } else {
            SessionManager.shared().login { (error) in
                if error != nil {
                    return
                }
                
                self.updateData()
                self.refreshData()
                self.updateUserList()
            }
        }
    }
    
    private func setupView() {
        self.tableView.setEmtpyViewDelegate(target: self)
        self.navigationItem.title = "chat_title".localiz()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.tableView)
        let bottom = !(self.tabBarController?.tabBar.isHidden ?? false) ? -(68 + safeBottomH) : 0
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(bottom)
        }
    }
    
    private func subscribeData() {
        UserRedDotRecordManager.shared.systemPageUnreadCount.subscribe(onNext: { [weak self] systemCount in
            guard let `self` = self  else {return }
            if  systemCount > 0 {
                self.messageBtn.showViewBadgOn()
            } else{
                self.messageBtn.hideViewBadg()
            }
        }).disposed(by: self.rx.disposeBag)
        
        GreetingManager.shared().greetingUnreadCount.subscribe(onNext:{ [weak self] unreadCount in
            guard let `self` = self else {return}
            self.greetViewModel.unreadCount.accept(unreadCount)
            self.tableView.reloadSections([0], animationStyle: .none)
        }).disposed(by: self.rx.disposeBag)
    }
    
    func configUnReadNumber() {
        UserRedDotRecordManager.shared.checksystemUnread()
        GreetingManager.shared().resetGreetingCount()
    }
    
    @objc func messageClick(_ sender:UIButton){
        let   noticevc = PersonalCenterViewController.init()
        self.navigationController?.pushViewController(noticevc, animated: false)
    }
    
    func updateLastTime() {
        guard let currRealm = FriendsDBManager.shared().currRealm else {
            debugPrint("无法打开数据库")
            return
        }
        
        let tempModels = currRealm.objects(FriendDBModel.self).sorted(byKeyPath: "updatedAt", ascending: false)
        if let dbModel = tempModels.first {
            self.lastUpdateAt = dbModel.updatedAt
        }
    }
    
    fileprivate func updateData() {
        objc_sync_enter(self.messageDatas)
        let option = NIMFetchServerSessionOption.init()
        option.minTimestamp = 0
        
        let allRecentSessions:[NIMRecentSession] = NIMSDK.shared().conversationManager.allRecentSessions() ?? []
        
        for tempRecentSession in allRecentSessions {
            self.insertSession(tempRecentSession)
        }
        
        messageDatas.sort { (viewModel1, viewModel2) -> Bool in
            return viewModel1.timeStamp > viewModel2.timeStamp
        }
        self.showEmpty = (self.messageDatas.count == 0)
        objc_sync_exit(self.messageDatas)
        self.tableView.reloadData()
        self.updateMessageTabbar()
    }
    
    fileprivate func refreshData() {
        NIMSDK.shared().conversationManager.fetchServerSessions(nil) { [weak self] (error, recentSessions, hasMore) in
            self?.updateData()
        }
    }
    fileprivate func  updateMessageTabbar(){
        
        var   unreadCount = UserRedDotRecordManager.shared.systemPageUnreadCount.value
        unreadCount = unreadCount + GreetingManager.shared().greetingUnreadCount.value
        for  message in self.messageDatas {
            unreadCount += message.unreadCount.value
        }
        guard  var tabbarvc =  UIViewController.getCurrentViewController()?.tabBarController  as? RightlyTabBarViewController else {return }
        if unreadCount > 0  {
            tabbarvc.itemsbtn[3].showViewBadgOn()
        } else {
            tabbarvc.itemsbtn[3].hideViewBadg()
        }
    }
    
    fileprivate func updateUserList() {
        var userList = [String]()
        for tempViewModel in self.messageDatas {
            guard let tempUserId = tempViewModel.accId else {
                continue
            }
            userList.append(tempUserId)
        }
        
        NIMSDK.shared().userManager.fetchUserInfos(userList) { (users, error) in
            for tempUser in users ?? [] {
                guard let accId = tempUser.userId else {
                    continue
                }
                
                for tempViewModel in self.messageDatas {
                    if accId == tempViewModel.accId {
                        tempViewModel.resetUserInfo(accId)
                    }
                }
            }
        }
    }
    
    fileprivate func insertSession(_ recentSession:NIMRecentSession) {
        for i in (0..<self.messageDatas.count).reversed() {
            let tempViewModel = self.messageDatas[i]
            if tempViewModel.recentSession.session?.sessionId == recentSession.session?.sessionId {
                self.messageDatas.remove(at: i)
                break
            }
        }
        
        let cellViewModel = SessionListCellViewModel.init(recentSession)
        if let currRealm = FriendsDBManager.shared().currRealm, let sessionId = recentSession.session?.sessionId {
            let tempModels = currRealm.objects(FriendDBModel.self).filter("keyUserId = %@", sessionId)
            if let dbModel = tempModels.first {
                cellViewModel.userId = dbModel.user?.userId.description
            }
        }
        
        self.messageDatas.append(cellViewModel)
        self.showEmpty = self.messageDatas.count == 0
    }
    
    // MARK: 更新好友数据库信息
    fileprivate func updateFriends(_ currPage:Int) {
        self.greetProvider.greetingAllowList(self.lastUpdateAt.description, self.rx.disposeBag)
            .subscribe(onNext:{[weak self] (resultData) in
                guard let `self` = self else {return}
                let dataDic:[String:Any] = resultData.data as? [String:Any] ?? Dictionary()
                let results:Array<[String:Any]> = dataDic["results"] as? Array<[String:Any]> ?? []
                
                guard let currRealm = FriendsDBManager.shared().currRealm else {
                    debugPrint("无法打开数据库")
                    return
                }
                
                for tempData in results {
                    if let updatedAt:Int64 = tempData["updatedAt"] as? Int64 {
                        if self.lastUpdateAt < updatedAt {
                            self.lastUpdateAt = updatedAt
                        }
                    }
                    
                    if let user:[String:Any] = tempData["user"] as? [String : Any] {
                        guard let accId:String = user["imAccId"] as? String else {
                            continue
                        }
                        
                        var dbData = tempData
                        dbData["keyUserId"] = accId
                        try! currRealm.write {
                            currRealm.create(FriendDBModel.self, value: dbData, update: .modified)
                        }
                        
                        let session = NIMSession.init(accId, type: .P2P)
                        SessionManager.shared().insertLocalGreetData(session, greetData: tempData)
                    }
                }
                
                SessionManager.shared().loadAllSession()
                self.updateData()
                guard let totalPage:Int = dataDic["totalPage"] as? Int else {
                    return
                }
                
                if currPage < totalPage {
                    self.updateFriends(currPage + 1)
                }
            }, onError: { (error) in
                debugPrint(error)
            }).disposed(by: self.rx.disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension SessionListViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellSizeheight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.messageDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell:SessionNewGreetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "newGreetId", for: indexPath) as! SessionNewGreetTableViewCell
            cell.bindViewModel(self.greetViewModel)
            return cell
        } else {
            let cell:SessionListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "sessionListId", for: indexPath) as! SessionListTableViewCell
            if indexPath.row < self.messageDatas.count {
                cell.bindViewModel(self.messageDatas[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let viewCtrl = GreetListViewController()
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        } else if indexPath.row < self.messageDatas.count {
            let tempViewModel = self.messageDatas[indexPath.row]
            
            var pushUserId:String? = tempViewModel.userId
            if pushUserId == nil {
                if let currRealm = FriendsDBManager.shared().currRealm, let sessionId = tempViewModel.recentSession.session?.sessionId {
                    let tempModels = currRealm.objects(FriendDBModel.self).filter("keyUserId = %@", sessionId)
                    if let dbModel = tempModels.first {
                        pushUserId = dbModel.user?.userId.description
                        tempViewModel.userId = dbModel.user?.userId.description
                    }
                }
            }
            
            guard let userId = pushUserId else {
                MBProgressHUD.showError("User error".localiz())
                return
            }
            
            guard let session = tempViewModel.recentSession.session else {
                MBProgressHUD.showError("User error".localiz())
                return
            }
            
            let viewCtrl = SessionInfoViewController(session: session, userId: userId)
            self.navigationController?.pushViewController(viewCtrl, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localiz()
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction.init(style: .destructive, title: "Delete".localiz()) { (action, view, completion) in
            tableView.setEditing(false, animated: true)
            objc_sync_enter(self.messageDatas)
            if indexPath.row < self.messageDatas.count {
                let tempViewModel = self.messageDatas[indexPath.row]
                self.messageDatas.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                NIMSDK.shared().conversationManager.delete(tempViewModel.recentSession)
                self.showEmpty = (self.messageDatas.count == 0)
            }
            objc_sync_exit(self.messageDatas)
            completion(true)
        }
        
        let actions = UISwipeActionsConfiguration.init(actions: [deleteAction])
        actions.performsFirstActionWithFullSwipe = false
        return actions
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objc_sync_enter(self.messageDatas)
            if indexPath.row < self.messageDatas.count {
                let tempViewModel = self.messageDatas[indexPath.row]
                self.messageDatas.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                NIMSDK.shared().conversationManager.delete(tempViewModel.recentSession)
            }
            objc_sync_exit(self.messageDatas)
        }
    }
}

// MARK: - 会话的回调
extension SessionListViewController : NIMConversationManagerDelegate {
    /// 最近会话数据库读取完成
    /// - Returns: 该回调执行表示最近会话全部加载完毕可以通过allRecentSessions来取全部对话。
    func didLoadAllRecentSessionCompletion() {
        debugPrint("")
        self.updateData()
        self.updateFriends(1)
    }
    
    /// 增加最近会话的回调
    /// - Parameters: 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("增加最近会话的回调")
        self.updateData()
    }
    
    /// 最近会话修改的回调
    /// - Parameters: 触发条件包括: 1.当新增一条消息，并且本地存在该消息所属的会话。
    /// 2.所属会话的未读清零。
    /// 3.所属会话的最后一条消息的内容发送变化。(例如成功发送后，修正发送时间为服务器时间)
    /// 4.删除消息，并且删除的消息为当前会话的最后一条消息。
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("最近会话修改的回调")
        self.insertSession(recentSession)
        self.updateData()
    }
    
    /// 删除最近会话的回调
    /// - Parameters:
    ///   - recentSession: 最近会话
    ///   - totalUnreadCount: 目前总未读数
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        debugPrint("删除最近会话的回调")
        self.updateData()
    }
    
    /// 单个会话里所有消息被删除的回调
    /// - Parameter session: 消息所属会话
    func messagesDeleted(in session: NIMSession) {
        debugPrint("单个会话里所有消息被删除的回调")
        self.updateData()
    }
    
    /// 所有消息被删除的回调
    func allMessagesDeleted() {
        debugPrint("所有消息被删除的回调")
        self.updateData()
    }
    
    /// 单个会话所有消息在本地和服务端都被清空
    /// - Parameters:
    ///   - session: 消息所属会话
    ///   - step: 清空会话消息完成时状态
    func allMessagesCleared(in session: NIMSession, step: NIMClearMessagesStatus) {
        debugPrint("单个会话所有消息在本地和服务端都被清空")
    }
    
    /// 所有消息已读的回调
    func allMessagesRead() {
        debugPrint("所有消息已读的回调")
    }
    
    /// 会话服务，会话更新
    /// - Parameter recentSession: 最近会话
    func didServerSessionUpdated(_ recentSession: NIMRecentSession?) {
        debugPrint("会话服务，会话更新")
    }
    
    /// 消息单向删除通知
    /// - Parameters:
    ///   - messages: 被删除消息
    ///   - exts: 删除时的扩展字段字典，key: messageId，value: ext
    func onRecvMessagesDeleted(_ messages: [NIMMessage], exts: [String : String]?) {
        debugPrint("消息单向删除通知")
    }
    
    /// 未漫游完整会话列表回调
    /// - Parameter infos: 未漫游完整的会话信息
    func onRecvIncompleteSessionInfos(_ infos: [NIMIncompleteSessionInfo]?) {
        debugPrint("未漫游完整会话列表回调")
    }
    
    /// 标记已读回调
    /// - Parameters:
    ///   - session: session
    ///   - error: 失败原因
    func onMarkMessageReadComplete(in session: NIMSession, error: Error?) {
        debugPrint("标记已读回调")
    }
    
    /// 批量标记已读的回调
    /// - Parameter sessions: session
    func onBatchMarkMessagesRead(in sessions: [NIMSession]) {
        debugPrint("批量标记已读的回调")
    }
}

extension SessionListViewController : NIMUserManagerDelegate {
    func onFriendChanged(_ user: NIMUser) {
        debugPrint("好友状态发生变化 (在线)")
    }
    
    func onBlackListChanged() {
        debugPrint("黑名单列表发生变化 (在线)")
    }
    
    func onMuteListChanged() {
        debugPrint("静音列表发生变化 (在线)")
    }
    
    //出于性能和上层 APP 处理难易度的考虑，本地调用批量接口获取用户信息时不触发当前回调。
    func onUserInfoChanged(_ user: NIMUser) {
        debugPrint("用户个人信息发生变化 (在线)")
        guard let accId = user.userId else {
            return
        }
        
        for tempViewModel in self.messageDatas {
            if accId == tempViewModel.accId {
                tempViewModel.resetUserInfo(accId)
            }
        }
    }
}


extension SessionListViewController:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return  self.showEmpty
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyView {
            return view
        }
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = CGRect.init(x: 0, y: cellSizeheight, width: screenWidth, height: tableView.bounds.size.height - cellSizeheight)
        emptyv?.placeimage.image = UIImage.init(named: "empty_message_palcehodler")
        emptyv?.lblcontent.text = "mess_empt".localiz()
        self.emptyView = emptyv
        return emptyv
        
    }
}
