//
//  PersonalViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/2.
//

import UIKit
import SnapKit
import RxSwift
import Reusable
import RxDataSources
import MJRefresh
import MBProgressHUD
import ZLPhotoBrowser
import NIMSDK
import JXSegmentedView

//看别人和自己个人主页
class PersonalViewController: BaseViewController {
    var isFollowingRequest:Bool = false
    var userid:Int64? = nil
    fileprivate var detailUserInfo:UserAdditionalInfo?=nil
    var emptyView:UIView?
    var listCtrl:DynamicListViewController? = nil
    let navView:PersonalNavBarView? = PersonalNavBarView.loadNibView()
    var viewModel:UserInfoViewModel = UserInfoViewModel()
    var viewtypeSelectView:PublishViewTypeSelectView?=PublishViewTypeSelectView.loadNibView()
    
    lazy var imBtn: UIButton = {
        let resultBtn = self.createBtn()
        resultBtn.setImage(UIImage.init(named: "my_home_page_im_btn"), for: .normal)
        resultBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ (sender) in
            if UserManager.isOwnerMySelf(self.userid) {
                return
            }
            
            guard let sessionId = self.detailUserInfo?.imAccId, let otherId = self.userid else {
                return
            }
            
            let session:NIMSession = NIMSession.init(sessionId, type: .P2P)
            let nextViewCtrl = SessionInfoViewController.init(session: session, userId: otherId.description)
            self.navigationController?.pushViewController(nextViewCtrl, animated: true)
        }).disposed(by: self.rx.disposeBag)
        return resultBtn
    }()
    
    lazy var imBtnView: UIView = {
        let resultView = self.creatShadowView()
        resultView.addSubview(self.imBtn)
        self.imBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return resultView
    }()
    
    lazy var followBtn: UIButton = {
        let resultBtn = self.createBtn()
        resultBtn.setImage(UIImage.init(named: "my_home_page_unfollow_btn"), for: .selected)
        resultBtn.setImage(UIImage.init(named: "my_home_page_follow_btn"), for: .normal)
        resultBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ (sender) in
            self.followUser()
        }).disposed(by: self.rx.disposeBag)
        return resultBtn
    }()
    
    lazy var followBtnView: UIView = {
        let resultView = self.creatShadowView()
        resultView.addSubview(self.followBtn)
        self.followBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return resultView
    }()
    
    func createBtn() -> UIButton {
        let resultBtn = UIButton.init(type: .custom)
        resultBtn.frame = CGRect.init(x: 0, y: 0, width: 68, height: 68)
        resultBtn.backgroundColor = .white
        resultBtn.cornerRadius = 34
        return resultBtn
    }
    
    func creatShadowView() -> UIView {
        let resultView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 68, height: 68))
        resultView.isHidden = true
        //        resultView.layer.shadowColor = UIColor.init(hex: "9A9A9A", alpha: 0.5).cgColor
        resultView.layer.shadowColor = UIColor.black.cgColor
        resultView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        resultView.layer.masksToBounds = false
        resultView.layer.shadowRadius = 4
        resultView.layer.shadowOpacity = 0.1
        return resultView
    }
    
    lazy var headerHasTaskView:PersonalHeaderHasTaskView = {
        let resultView = PersonalHeaderHasTaskView.loadNibView() ?? PersonalHeaderHasTaskView.init()
        resultView.followBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] (sender) in
            guard let `self` = self else {return}
            self.followUser()
        }).disposed(by: self.rx.disposeBag)
        return resultView
    }()
    
    lazy var headerNoTaskView:PersonalHeaderNoTaskView = {
        let resultView = PersonalHeaderNoTaskView.loadNibView() ?? PersonalHeaderNoTaskView.init()
        return resultView
    }()
    
    //    fileprivate lazy var  tableview:UITableView = {
    //        let tableview = UITableView.init(frame: .zero, style: .plain)
    //        tableview.initTableView()
    //        tableview.estimatedRowHeight = 10
    //        tableview.rowHeight = UITableView.automaticDimension
    //        tableview.backgroundColor = .clear
    //        tableview.showsVerticalScrollIndicator = false
    //        tableview.register(cellType: UserPersonalGreetingCell.self)
    //        tableview.register(cellType: PersonalOtherUnlockMoreCell.self)
    //        tableview.register(cellType: EmptyOwerCell.self)
    //        tableview.register(cellType: EmptyContentCell.self)
    //        return tableview
    //    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        self.setupViews()
        self.bindViewModel(to: self.viewModel)
        forceRefresh(notification: nil)
        self.navView?.bgypeView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func forceRefresh(notification: NSNotification? = nil) {
        self.viewModel.output.refreshHeader.accept(.normal)
        self.navView?.updateUser(userid: self.userid)
        self.viewModel.refreshInfo(userid: self.userid)
        self.viewModel.input.refreshTags.onNext(self.userid)
    }
    
    func setupViews() {
        self.view.backgroundColor  = UIColor.white
        
        guard let navBarview = self.navView else {
            return
        }
        
        //右边按钮
        navBarview.messageClickBlock = { [weak self] in
            guard let `self` = self  else {return }
            if UserManager.isOwnerMySelf(self.userid) {
                let  noticeVc = PersonalCenterViewController.init()
                self.navigationController?.pushViewController(noticeVc, animated: false)
                AppDelegate.removeRedBagBar(index: 2)
            } else {
                self.showOtherTipView(true)
            }
        }
        
        //关注我的
        navBarview.followedClickBlock = { [weak self] in
            guard let `self` = self  else {return }
            let  followervc =  UserFollowViewController.init()
            followervc.viewModel.input.followingType.accept(.following)
            followervc.userid = self.userid
            self.navigationController?.pushViewController(followervc, animated: true)
        }
        
        //我关注的
        navBarview.followerClickBlock = { [weak self] in
            guard let `self` = self  else {return }
            let  followervc =  UserFollowViewController.init()
            followervc.viewModel.input.followingType.accept(.fans)
            followervc.userid = self.userid
            self.navigationController?.pushViewController(followervc, animated: true)
        }
        
        //公开隐藏
        navBarview.bgypeView.isHidden = true
        navBarview.bgViewTypeClickBlock = {
            [weak self] in
            guard let `self` = self  else {return }
            self.changeBgView()
        }
        
        //返回
        navBarview.settingClickBlock = { [weak self] in
            guard let `self` = self  else {return }
            self.navigationController?.popViewController(animated: true)
        }
        
        self.view.addSubview(navBarview)
        navBarview.snp.makeConstraints({ (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(navBarH)
        })
        
        self.view.addSubview(self.imBtnView)
        self.view.addSubview(self.followBtnView)
        
        let btnCenterX = screenWidth / 6.0
        let btnWH = 68.0
        let btnBottom = -20 - safeBottomH
        self.imBtnView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(btnCenterX)
            make.bottom.equalTo(btnBottom)
            make.width.height.equalTo(btnWH)
        }
        
        self.followBtnView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-btnCenterX)
            make.bottom.equalTo(btnBottom)
            make.width.height.equalTo(btnWH)
        }
    }
}

extension PersonalViewController :VMBinding {
    func bindViewModel(to model: UserInfoViewModel) {
        ///订阅userInfo变化
        self.viewModel.output.detailUser.subscribe(onNext: { [weak self] (info) in
            guard let `self` = self else {return }
            self.detailUserInfo = info
            let isMySelf = UserManager.isOwnerMySelf(info.userId)
            self.navView?.lblbgviewtype.text  = info.bgViewType?.descShow()
            self.headerNoTaskView.updateUserInfo(info)
            self.headerHasTaskView.updateUserInfo(info)
            
            self.setupDynamicListView()
            self.listCtrl?.isLockUser.accept(!isMySelf && !(info.isUnlock ?? false) && !(info.isFriend ?? false))
            
            let isFriend = info.isFriend ?? false
            if !isMySelf && isFriend {
                self.followBtnView.isHidden = false
                self.imBtnView.isHidden = false
                self.listCtrl?.tableView.tableHeaderView = self.headerNoTaskView
                self.followBtn.isSelected = info.isfocused
                
                self.view.bringSubviewToFront(self.imBtnView)
                self.view.bringSubviewToFront(self.followBtnView)
            } else {
                self.followBtnView.isHidden = true
                self.imBtnView.isHidden = true
                self.listCtrl?.tableView.tableHeaderView = self.headerHasTaskView
            }
            
            self.navView?.bgypeView.isHidden = !isMySelf
            self.listCtrl?.tableView.reloadData()
        }).disposed(by: self.rx.disposeBag)
        
        ///订阅tags变化
        self.viewModel.output.tags.subscribe(onNext: { [weak self] (tags) in
            guard let `self` = self else {return }
            self.headerNoTaskView.configTagsView(tags)
            self.headerHasTaskView.configTagsView(tags, isMy: (self.userid == nil))
        }).disposed(by: self.rx.disposeBag)
        
        ///订阅任务变化
        self.viewModel.output.taskInfo.subscribe(onNext:{ [weak self] (taskInfo) in
            guard let `self` = self else {return }
            self.headerHasTaskView.updateTaskInfo(taskInfo)
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setupDynamicListView() {
        if self.listCtrl == nil {
            var parameter:String? = nil
            if let tempUserId = self.userid {
                parameter = String(tempUserId)
            }
            
            self.listCtrl = DynamicListViewController.init(parameter == nil ? .myDynamics : .otherDynamics , parameter)
            self.listCtrl?.userId = parameter
            self.listCtrl?.addParents(self, self.view)
            self.listCtrl?.view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
            
            self.listCtrl?.view.layoutIfNeeded()
            
            self.listCtrl?.headerRefreshBlock = { [weak self] in
                guard let `self` = self else {return}
                self.viewModel.output.refreshHeader.accept(.normal)
                self.viewModel.refreshInfo(userid: self.userid)
            }
            
            self.listCtrl?.viewDidScrollBlock = { [weak self] (offset) in
                guard let `self` = self else {return}
                
                self.headerNoTaskView.bgImageViewTop.constant = offset.y > 0 ? 0 : offset.y
                self.headerHasTaskView.bgImageViewTop.constant = offset.y > 0 ? 0 : offset.y
                
                if offset.y > 166 {
                    self.navView?.updateRenderColor(color: UIColor.black)
                } else {
                    self.navView?.updateRenderColor(color: UIColor.white)
                }
            }
            
            guard let navBarview = self.navView else {
                return
            }
            
            self.view.bringSubviewToFront(navBarview)
        }
    }
}

extension PersonalViewController {
    //更改背景权限
    func changeBgView()  {
        guard var viewtype = self.detailUserInfo?.bgViewType else {
            return
        }
        MBProgressHUD.showStatusInfo("Editing.....")
        let provider = UserProVider.init()
        if  viewtype == .Private {
            viewtype = .Public
        } else {
            viewtype = .Private
        }
        provider.editUser( bgViewType: viewtype,self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            MBProgressHUD.dismiss()
            self.viewModel.output.refreshHeader.accept(.normal)
            self.viewModel.input.requestCommand.onNext(self.userid)
            if viewtype == .Private {
                self.toastTip("其它用户需完成任务才可查看".localiz())
            }
            self.headerNoTaskView.updateBgViewType(viewtype)
            self.headerNoTaskView.updateBgViewType(viewtype)
            self.navView?.updateBgViewType(viewtype)
        },onError: { (err) in
            self.toastTip("Network failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    func showOtherTipView(_ withfollow:Bool){
        let otherAlterView:OtherAlterTipView?=OtherAlterTipView.loadNibView()
        otherAlterView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 300)
        otherAlterView?.showOnWindow( direction:.up)
        if withfollow {
            otherAlterView?.showfollow()
        } else{
            otherAlterView?.hidefollow()
        }
        otherAlterView?.btnfollow.isSelected = self.detailUserInfo?.isfocused ??  false
        otherAlterView?.selectItemBlock = {
            [weak self] (item,issues) in
            guard let `self` = self  else {return }
            switch item {
            case .itemReport:
                guard let userid = self.userid else {
                    return
                }
                self.reportUser(userid: userid,issues)
                break
            case .itemFollow:
                self.followUser()
                break
            default:
                break
            }
        }
    }
    
    //关注用户
    func followUser() {
        if isFollowingRequest {
            return
        }
        guard let otherFocus = self.detailUserInfo?.isfocused ,let followerUserid = userid else {
            return
        }
        isFollowingRequest  = true
        UserProVider.focusUser(otherFocus, userid: followerUserid, self.rx.disposeBag) { [weak self] (isfocus) in
            guard let `self` = self  else {return }
            self.headerHasTaskView.followBtn.isSelected = isfocus
            self.followBtn.isSelected = isfocus
            self.isFollowingRequest = false
            self.viewModel.output.refreshHeader.accept(.normal)
            self.viewModel.refreshInfo(userid: followerUserid)
        }
    }
    
    //举报用户
    func reportUser(userid:Int64,_ issues:[String])  {
        UserProVider.init().reportTarget(1, targetId: userid, issues.first?.reportType() ?? 0 ,content: issues.first ?? "other",self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                self.toastTip("Report success".localiz())
            },onError: { (err) in
                self.toastTip("Report failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
}

extension PersonalViewController:EmptyViewProtocol, JXSegmentedListContainerViewListDelegate {
    var showEmtpy: Bool {
        get {
            return self.detailUserInfo == nil
        }
    }
    
    func configEmptyView() -> UIView? {
        if let view = self.emptyView {
            return view
        }
        
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.view.bounds
        emptyv?.placeimage.image = UIImage(named: "emptyview")
        self.emptyView = emptyv
        return emptyv
    }
    
    func listView() -> UIView {
        return self.view
    }
}

