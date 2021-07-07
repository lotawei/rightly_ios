//
//  NewPersonalViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/13.
//
import UIKit
import SnapKit
import RxSwift
import Reusable
import RxDataSources
import MJRefresh
import MBProgressHUD
import ZLPhotoBrowser
class NewPersonalOwerViewController: BaseViewController {
    fileprivate var  detailUserInfo:UserAdditionalInfo?=nil
    var settingClickBlock:(()-> Void)?=nil
    var messageClickBlock:(()-> Void)?=nil
    var userid:Int64? = nil
    var loadingStatus:Int = 0
    var disposable:Disposable? = nil
    let personalHead = PersonalOwerHeadView.loadNibView()
    var viewModel: UserOwerSettingViewModel  = UserOwerSettingViewModel()
    var taskCellHeight:Constraint?
    private var dataSource: RxTableViewSectionedReloadDataSource<UserInfoListSection>!
    var deleteTipView:AlterViewTipView?=AlterViewTipView.loadNibView()
    var operationView:GreetingItemBottomView?=GreetingItemBottomView.loadNibView()
    
    var viewtypeSelectView:PublishViewTypeSelectView?=PublishViewTypeSelectView.loadNibView()
    fileprivate lazy var  tableview:UITableView = {
        let tableview = UITableView.init(frame: .zero, style: .plain)
        tableview.initTableView()
        tableview.estimatedRowHeight = 300
        tableview.rowHeight = UITableView.automaticDimension
        tableview.backgroundColor = .clear
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: OwerPersonalCell.self)
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        self.setupViews()
        self.bindViewModel(to: self.viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingStatus = 0
        self.requestUserInfo()
    }
    
    func setupViews() {
        self.view.backgroundColor = UIColor.white
        personalHead?.frame = CGRect.init(x: 0, y: 0, width:screenWidth, height: 300)
        guard let headview = personalHead else {
            return
        }
        
        if !self.checkIsOwerMySelf() {
            headview.itemviews.last?.isHidden = true
        }
        
        headview.clipsToBounds = false
        headview.userPageClickBlock = {[weak self] in
            guard let `self` = self  else {return }
            let  perVc = PersonalViewController.loadFromNib()
            self.navigationController?.pushViewController(perVc, animated: false)
            
//            let ctrl = DynamicDetailViewController.init(1397459857265770498)
//            self.navigationController?.pushViewController(ctrl, animated: true)
//
//            let dynamicListCtrl = DynamicListViewController.init(nil)
//            self.addChild(dynamicListCtrl)
//            dynamicListCtrl.didMove(toParent: self)
//            dynamicListCtrl.view.frame = self.view.bounds
//            self.view.addSubview(dynamicListCtrl.view)
        }
        headview.backGroundImgBlock = { [weak self] in
            guard let `self` = self  else {return }
            if self.checkIsOwerMySelf() {
                self.takePhotoAsBg()
            }
        }
        
        //点击下部的一些组件
        headview.clickTapIndexBlock = { [weak self] index in
            guard let `self` = self  else {return }
            
            switch index {
            case 0:
                //我关注的
                let  followervc =  UserFollowViewController.init()
                followervc.viewModel.input.followingType.accept(.following)
                followervc.userid = self.userid
                self.navigationController?.pushViewController(followervc, animated: true)
            case 1:
                let  followervc =  UserFollowViewController.init()
                followervc.viewModel.input.followingType.accept(.fans)
                followervc.userid = self.userid
                self.navigationController?.pushViewController(followervc, animated: true)
            case 2:
                let  likevc =  UserLikeViewControlelr.init()
                likevc.userid = self.userid
                self.navigationController?.pushViewController(likevc, animated: false)
            case 3:
                if !self.checkIsOwerMySelf() {
                    return
                }
                
                //浏览列表
                let  followervc =  UserFollowViewController.init()
                followervc.viewModel.input.followingType.accept(.vistor)
                followervc.userid = self.userid
                self.navigationController?.pushViewController(followervc, animated: true)
            default:
                break
            }
        }
        
        //选择头像
        headview.avatarClick = { [weak self] in
            guard let `self` = self  else {return }
            if self.checkIsOwerMySelf() {
                self.navigationController?.pushViewController(UserChooseAvatarViewController.loadFromNib(), animated: true)
            }
        }
        //更改昵称
        headview.nicknameClick = { [weak self] in
            guard let `self` = self else {return }
            if self.checkIsOwerMySelf() {
                self.navigationController?.pushViewController(UserNickNameEditorViewController.loadFromNib(), animated: true)
            }
        }
        
        //用户已被删除的处理
        headview.userIsEmptyBlock = { [weak self] in
            guard let `self` = self  else {return }
            self.toastTip("User is not exist".localiz())
            self.afterDelay(2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        headview.isfriendCheck = { [weak self] isfriend in
            guard let `self` = self  else {return }
            self.taskCellHeight?.update(offset: isfriend ? 0:90)
        }
        self.tableview.tableHeaderView = headview
        self.view.addSubview(self.tableview)
        
        let bottom = !(self.tabBarController?.tabBar.isHidden ?? false) ? -(68 + safeBottomH) : 0
        self.tableview.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view.snp.top)
            maker.bottom.equalToSuperview().offset(bottom)
            maker.width.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        self.tableview.rx.didScroll.subscribe(onNext: { [weak self]  in
            guard let `self` = self else {return }
            self.personalHead?.offyCallBack?(self.tableview.contentOffset.y)
            if self.tableview.contentOffset.y < -64 {
                if self.loadingStatus == 0 {
                    self.requestUserInfo()
                }
            } else {
                if self.loadingStatus == 2 {
                    self.loadingStatus = 0
                }
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    func checkIsOwerMySelf() -> Bool {
        return UserManager.isOwnerMySelf(self.userid)
    }
}

extension NewPersonalOwerViewController :VMBinding {
    func bindViewModel(to model: UserOwerSettingViewModel) {
        self.viewModel.output.sampleDatas.asDriver(onErrorJustReturn: []).drive(tableview.rx.items(dataSource: self.viewModel.output.dataSource)).disposed(by: self.rx.disposeBag)
        self.disposable = self.tableview.rx.setDelegate(self)
    }
}

extension NewPersonalOwerViewController {
    /// 选择背景做
    func takePhotoAsBg() {
        let editBackimg = PersonalInputBgViewController.loadFromNib()
        editBackimg.currentUrl = UserManager.manager.currentUser?.additionalInfo?.backgroundUrl?.dominFullPath()
        self.navigationController?.pushViewController(editBackimg, animated: true)
        editBackimg.refreshBlock = {
            [weak self] in
            guard let `self` = self  else {return }
            self.loadingStatus = 0
            self.requestUserInfo()
        }
    }
    func jumpPhotoLibrary(){
        ZLPhotoConfiguration.default().allowRecordVideo  = false
        ZLPhotoConfiguration.default().allowSelectImage = true
        ZLPhotoConfiguration.default().allowTakePhoto  = true
        ZLPhotoConfiguration.default().allowEditImage = true
        ZLPhotoConfiguration.default().allowSelectVideo = false
        ZLPhotoConfiguration.default().maxSelectCount = 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            guard let `self` = self  else {return }
            self.personalHead?.backheadView.image = images.first
            self.uploadBackGroundColor(image: images.first)
        }
        
        ps.showPhotoLibrary(sender: self)
    }
    
    func jumpCamera(){
        //调相机拍照
        SystemPermission.checkCamera(alertEnable: true) { [weak self](has) in
            guard let `self` = self  else {return }
            if has {
                DispatchQueue.main.async {
                    self.enterCamera()
                }
            }
        }
    }
    func enterCamera(){
        guard let currentVc = self.getCurrentViewController() else {
            return
        }
        
        ZLPhotoConfiguration.default().allowRecordVideo  = false
 
        ZLPhotoConfiguration.default().allowSelectImage  = true
        ZLPhotoConfiguration.default().allowTakePhoto  = true
        ZLPhotoConfiguration.default().allowEditImage = true
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = { [weak self] (image, videoUrl) in
            guard let `self` = self  else {return }
            self.personalHead?.backheadView.image = image
            self.uploadBackGroundColor(image: image)
        }
        currentVc.showDetailViewController(camera, sender: nil)
    }
    
    func uploadBackGroundColor(image:UIImage?){
        guard let backimg = image else {
            return
        }
        
        MBProgressHUD.showStatusInfo("updating ....".localiz())
        RTUploadFileTool.RTUploadFile(type: .taskMulityImage(backimg, preview: true, type: .userpotrait), fileName: "jpg")?.filterSuccessfulStatusCodes().subscribe({ [weak self] (res) in
            MBProgressHUD.dismiss()
            guard let `self` = self  else {return }
            switch res {
            case .success(let response):
                var  uploadresponse:UploadResponseData? = ReqResult.init(requestData: response.data).modeDataKJTypeSelf(typeSelf: UploadResponseData.self)
                if let data =  uploadresponse ,let url = data.url  {
                    self.userBackUrlRefresh(url)
                } else {
                    DispatchQueue.main.async {
                        self.toastTip("server  upload failed".localiz())
                    }
                }
                break
            case .error(_):
                self.toastTip("Update failed")
            }
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    func userBackUrlRefresh(_ backurl:String)  {
        let  user = UserManager.manager.currentUser
        user?.additionalInfo?.backgroundUrl = backurl
        UserProVider.init().editUser(backgroundUrl: backurl, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                self.requestUserInfo()
            },onError: { (err) in
                self.toastTip("refresh failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
}

extension NewPersonalOwerViewController :UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let personalVc = UserAccountViewController.loadFromNib()
            self.navigationController?.pushViewController(personalVc, animated: true)
        } else {
            let settingvc = UserSettingViewController.init()
            self.navigationController?.pushViewController(settingvc, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            guard let head = self.personalHead else {
                return
            }
            self.tableview.sendSubviewToBack(head)
        }
    }
}

extension  NewPersonalOwerViewController {
    func  requestUserInfo() {
        if self.loadingStatus >= 1 {
            return
        }
        
        self.loadingStatus = 1
        UserProVider.init().detailUser(self.rx.disposeBag).subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (userdetail) in
            guard let `self` = self else {return }
            self.loadingStatus = 2
            if let dicData = userdetail.data as? [String:Any] {
                let auser = dicData.kj.model(UserAdditionalInfo.self)
                self.personalHead?.updateUserInfo(auser)
            }
                
        },onError: { (err) in
            MBProgressHUD.showError("gain user Info failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
}
