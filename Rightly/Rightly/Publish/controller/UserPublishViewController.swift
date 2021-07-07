//
//  UserPublishViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/8.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import ZLPhotoBrowser
import Photos
import SnapKit
import KMPlaceholderTextView
class UserPublishViewController: BaseViewController {
    var  userpublishSuccess:((_ userid:Int64) -> Void)?=nil
    fileprivate var  limitMaxWord = 200
    var blockRefresh:(()->Void)?=nil
    var taskid:Int64?=nil
    var toUserID:Int64?=nil
    var lng:Double?=nil
    var lat:Double?=nil
    var address:String?=nil
    var viewType:ViewType = .Public {
        didSet {
            let  title = (viewType == .Private) ? "Private".localiz():"Public".localiz()
            self.btnviewTypee.setTitle(title.localiz() , for: .normal)
        }
    }
    
    var tipTaskDes:String?=nil{
        didSet {
            self.tasktipview?.lbldes.text = tipTaskDes
        }
    }
    
    var releaseType:ReleaseType = .greeting //具体看定义
    @IBOutlet weak var selectVoiceView: UIView!
    @IBOutlet weak var voiceheight: NSLayoutConstraint!
    
    let uploadtype:Int = 10
    lazy var postButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(postAction(_:)), for: .touchUpInside)
        button.setTitle("Post".localiz(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.frame = CGRect.init(x: 0, y: 0, width: 68, height: 30)
        return button
    }()
    var voiceWidth:Constraint?=nil
    let audioView:ReleaseAudioView?=ReleaseAudioView.loadNibView()
    var voiceDuration:Int = 0
    var videiDuration:[TimeInterval] = []
    let viewtypeSelectView:PublishViewTypeSelectView?=PublishViewTypeSelectView.loadNibView()
    lazy var deleteAudioBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(deleteAudio), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setImage(UIImage.init(named: "删除"), for: .normal)
        return button
    }()
    let selectView = MediaResourceSelectView.loadNibView()
    let voicerecordView = UserPublishVoiceRecordView.loadNibView()
    
    @IBOutlet weak var locationbtn: UIButton!
    @IBOutlet weak var locationdelete: UIButton!
    @IBOutlet weak var btnviewTypee: UIButton!
    let locationmanager = LocationManager.init()
    var datas:[Any] = [Any]()
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tipview: UIView!
    var tasktype:TaskType = .photo {
        didSet {
            self.viewModel.input.releastType.onNext(self.tasktype)
        }
    }
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    var sectionVoice:(String?,String?)=(nil,nil)
    let tasktipview:TaskTipView? = TaskTipView.loadNibView()
    var viewModel: UserReleaseVmModel = UserReleaseVmModel.init()
    @IBOutlet weak var tipheight: NSLayoutConstraint!
    @IBOutlet weak var collectionhheight: NSLayoutConstraint!
    @IBOutlet weak var collectionBodyView: UIView!
    @IBOutlet weak var txtcontext: KMPlaceholderTextView!
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: RTReleaseImageCell.self)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnviewTypee.setTitle("Public".localiz(), for: .normal)
        locationdelete.setTitle("delete".localiz(), for: .normal)
        self.locationbtn.setTitle("Where are you from".localiz(), for: .normal)
        txtcontext.placeholder = "What are you thinking of?".localiz()
        MediaResourceManager.shared.allselectedMedia.accept([])
        MediaResourceManager.shared.allselectedMedia.subscribe(onNext: { [weak self] value in
            guard let `self` = self  else {return }
            self.datas = []
            var  section:CGFloat = CGFloat(Int.getSection(value.count + 1, 3))
            if  value.count == MediaResourceManager.shared.allowMaxPicResource {
                section = 3
            }
            self.collectionhheight.constant = (section * (screenWidth - 50.0) / 3.0) + 20.0
            let check = (self.tasktype == .photo ) ? (MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowMaxPicResource):(MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowMaxVideoResource)
            self.datas += value
            self.postButtonState(self.datas.count > 0 )
            if   check {
                self.datas.append(1)
            }
            self.collectionView.reloadData()
        }).disposed(by: self.rx.disposeBag)
        setUpView()
        bindViewModel(to: self.viewModel)
        postButtonState(false)
        
        //过滤 emoj
        txtcontext.delegate = self
    }
    func postButtonState(_ isenable:Bool)  {
        if isenable {
            self.postButton.backgroundColor = UIColor.init(hex: "27D3CF")
        } else{
            self.postButton.backgroundColor = UIColor.init(red: 180.0/255.0, green: 230.0/255, blue: 240/255.0, alpha: 1)
        }
        self.postButton.isEnabled = isenable
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationdelete.isHidden = true
        
        locationmanager.startOnceLocation {
            [weak self]
            status in
            guard let `self` = self  else {return }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectResource()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationmanager.stopLocation()
    }
    func setUpView(){
        let backitem = UIBarButtonItem.init(image:UIImage.init(named: "关闭"), style: .plain , target:self , action: #selector(closeaction))
        self.navigationItem.leftBarButtonItem = backitem
        let  postItem = UIBarButtonItem.init(customView: self.postButton)
        self.navigationItem.rightBarButtonItem = postItem
        self.collectionBodyView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        guard let tasktopview = self.tasktipview else {
            return
        }
        self.tipview.addSubview(tasktopview)
        tasktopview.snp.makeConstraints { (maker) in
            maker.top.equalTo(12)
            maker.bottom.equalTo(-12)
            maker.left.equalTo(16)
            maker.right.equalTo(-16)
        }
        tasktopview.taskType = tasktype
        if self.tasktype == .voice {
            self.collectionhheight.constant = 0
            self.collectionBodyView.layoutIfNeeded()
            self.contentHeight.constant = 150
            self.txtcontext.layoutIfNeeded()
        } else {
            self.contentHeight.constant = 90
            self.voiceheight.constant = 0
        }
        
        
        if self.tasktype == .photo || self.tasktype == .video {
            guard let selecview = self.selectView else {
                return
            }
            self.bottomView.addSubview(selecview)
            selecview.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
        else{
            guard let voiceview = self.voicerecordView , let releaseVoiceView = self.audioView else {
                return
            }
            voiceview.deleTeActionBlock = {
                [ weak self ] in
                guard let `self` = self  else {return }
                self.deleteAudio()
            }
            
            voiceview.filename =  "aac"
            
            self.bottomView.addSubview(voiceview)
            voiceview.snp.makeConstraints { (maker) in
                maker.left.right.top.bottom.equalToSuperview()
            }
            //            录音结果
            voiceview.recordSuccessBlock = {
                [weak self] path in
                guard let `self` = self  else {return }
                if path.isEmpty {
                    return
                }
                self.postButtonState(true)
                self.voiceheight.constant =  72
                UIView.animate(withDuration: 0.3) {
                    
                    self.selectVoiceView.layoutIfNeeded()
                }
                self.audioView?.audiopath = path
                let widthAndDuration =  self.audioView?.layoutReleaseAudioView()
                self.voiceWidth?.update(offset: (widthAndDuration?.0 ?? 23) + 85)
                self.sectionVoice.1 = self.voicerecordView?.filename
                self.sectionVoice.0 = path
                self.voiceDuration = widthAndDuration?.1 ?? 0
            }
            
            self.selectVoiceView.addSubview(releaseVoiceView)
            releaseVoiceView.snp.makeConstraints { (maker) in
                maker.left.equalToSuperview().offset(16)
                self.voiceWidth  =  maker.width.equalTo(300).constraint
                maker.height.equalTo(40)
                maker.top.equalToSuperview().offset(16)
            }
            
            self.selectVoiceView.addSubview(self.deleteAudioBtn)
            
            self.deleteAudioBtn.snp.makeConstraints { (maker) in
                maker.left.equalTo(releaseVoiceView.snp.right).offset(3)
                maker.centerY.equalTo(releaseVoiceView)
                maker.width.height.equalTo(16)
            }
            voiceheight.constant = 0
            
            self.selectVoiceView.layoutIfNeeded()
        }
        
        self.tasktipview?.lbldes.text = self.tipTaskDes
        let tipH = (self.tasktipview?.lbldes.sizeThatFits(CGSize(width: (screenWidth - 70), height: screenHeight)).height ?? 18) + 16 + 24
        self.tipheight.constant = max(tipH, 58)
        
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func closeaction(_ sender: Any) {
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
            
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func dismissBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteAudio(){
        self.voicerecordView?.clearSetting()
        self.voiceheight.constant = 0
        self.audioView?.audiopath = ""
        UIView.animate(withDuration: 0.3) {
            self.selectVoiceView.layoutIfNeeded()
        }
        postButtonState(false)
    }
    
    
    
    
    
    
    @objc func postAction(_ sender: Any) {
        let  selectedModelAssets = MediaResourceManager.shared.allselectedMedia.value
        guard let user = UserManager.manager.currentUser else {
            AppDelegate.jumpLogin()
            return
        }
        guard let taskId = taskid  else {
            debugPrint("no  taskid")
            return
        }
        if self.txtcontext.text.count > limitMaxWord  {
            self.toastTip("Input Text Should be limited".localiz() +  " \(limitMaxWord)" +  "charaters".localiz())
            return
        }
        if self.tasktype == .video {
            self.videiDuration = selectedModelAssets.map({ (model) -> TimeInterval in
                return model.asset.duration
            })
            if selectedModelAssets.count == 0  {
                MBProgressHUD.showError("Please select video".localiz())
                return
            }
            uploadSelectedVideo(selectedModelAssets)
        }
        else if self.tasktype == .photo {
            if selectedModelAssets.count == 0  {
                MBProgressHUD.showError("Please select photo".localiz())
                return
            }
            
            uploadSelectedImage(selectedModelAssets)
        }
        else if self.tasktype == .voice {
            guard let voicepath = self.sectionVoice.0 ,let voicefilename = self.sectionVoice.1 else {
                MBProgressHUD.showError("Please Record Voice".localiz())
                return
            }
            let audioinfo = AudioInfo.init(filename: voicefilename, urlpath: voicepath)
            self.uploadSelectedVoice(audioinfo)
        }
        
    }
    
    
    
    
}


extension UserPublishViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 40 - 10) / 3
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.datas[indexPath.row] as? ZLPhotoModel
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RTReleaseImageCell", for: indexPath) as! RTReleaseImageCell
        if model != nil {
            
            cell.updateModel(model: model!)
        } else {
            cell.imageView.image = UIImage(named: "addPhoto")
            cell.playImageView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.datas.count - 1 {
            selectResource()
        } else {
            let  assetdatas = MediaResourceManager.shared.allselectedMedia.value.map({ (model) -> PHAsset in
                return model.asset
            })
            if assetdatas.count > 0  {
                let previewVC = ZLImagePreviewController(datas: assetdatas, index: indexPath.row, showSelectBtn: false,showBottomView: false)
                previewVC.doneBlock = { [weak self] (res) in
                    guard let `self` = self else { return }
                    if res.count == 0  {
                        MediaResourceManager.shared.allselectedMedia.accept([])
                        return
                    }
                    for asset  in res {
                        if let  assetvalue = asset as? PHAsset {
                            let zlmodel = ZLPhotoModel.init(asset: assetvalue)
                            MediaResourceManager.shared.selectModelAction(zlmodel)
                        }
                    }
                }
                previewVC.modalPresentationStyle = .fullScreen
                showDetailViewController(previewVC, sender: nil)
            }
            
        }
    }
    func selectResource() {
        if MediaResourceManager.shared.allselectedMedia.value.count > 0  {
            return 
        }
        if self.txtcontext.canResignFirstResponder {
            self.txtcontext.resignFirstResponder()
        }
        if tasktype == .voice {
            return
        }
        if tasktype == .photo  {
            self.selectView?.requestMediaResource(type: .image)
        } else if  tasktype == .video {
            self.selectView?.requestMediaResource(type: .video)
        }
        UIView.animate(withDuration: 0.4) {
            self.selectView?.alpha = 1
        }
        self.selectView?.collectionView.scrollRectToVisible(.zero, animated: true)
    }
    
}



extension   UserPublishViewController:VMBinding{
    func bindViewModel(to model: UserReleaseVmModel) {
        
        self.viewModel.output.displayTitle.asDriver().drive(self.rx.title).disposed(by: self.rx.disposeBag)
        
        self.locationbtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.locationmanager.startOnceLocation()
            
            
        }).disposed(by: self.rx.disposeBag)
        self.locationmanager.city
            .subscribe(onNext: { [weak self] (city) in
                guard let `self` = self  else {return }
                self.locationbtn.setTitle(city, for: .normal)
                self.locationdelete.isHidden = city.isEmpty
            }).disposed(by: self.rx.disposeBag)
        self.locationdelete.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.locationbtn.setTitle("Where are you from".localiz(), for: .normal)
            self.locationdelete.isHidden = true
        }).disposed(by: self.rx.disposeBag)
        self.locationmanager.curlocationinfo.asObserver().subscribe(onNext: { [weak self] (location) in
            guard let `self` = self  else {return }
            self.lng = location.coordinate.longitude
            self.lat = location.coordinate.latitude
        }).disposed(by: self.rx.disposeBag)
        self.locationmanager.address.asObserver().subscribe(onNext: { [weak self] (location) in
            guard let `self` = self  else {return }
            self.address = location
        }).disposed(by: self.rx.disposeBag)
        self.btnviewTypee.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            if self.txtcontext.canResignFirstResponder {
                self.txtcontext.resignFirstResponder()
            }
            self.viewtypeSelectView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 200)
            self.viewtypeSelectView?.showOnWindow( direction: .up)
            self.viewtypeSelectView?.clickSenderType =  { [weak self]
                viewtype in
                guard let `self` = self  else {return }
                self.viewType = ViewType.init(rawValue: viewtype) ?? .Public
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
}
extension UserPublishViewController {
    
    fileprivate func uploadSelectedImage(_ selectedModelAssets: [ZLPhotoModel]) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.image, type: .greeting, selectedModelAssets, {[weak self] (lists) in
            self?.greetingForUser(resourceLists: lists)
        },disposebag: self.rx.disposeBag)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        //            MBProgressHUD.dismiss()
        //        }
    }
    fileprivate func uploadSelectedVideo(_ selectedModelAssets: [ZLPhotoModel]) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.video, type: .greeting, selectedModelAssets, {[weak self] (lists) in
            self?.greetingForUser(resourceLists: lists)
        },disposebag: self.rx.disposeBag)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        //            MBProgressHUD.dismiss()
        //        }
    }
    fileprivate func uploadSelectedVoice(_ audio:AudioInfo) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.audio, type: .greeting, [audio], {[weak self] (lists) in
            self?.greetingForUser(resourceLists: lists)
            
        },disposebag: self.rx.disposeBag)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        //            MBProgressHUD.dismiss()
        //        }
    }
    
    fileprivate func greetingForUser(resourceLists:[GreetingResourceList]) {
        //如果头userid都没有直接走发任务后返回界面
        viewModel.input.data.address = self.address
        viewModel.input.data.content = self.txtcontext.text
        if let touserid  = self.toUserID{
            viewModel.input.data.toUserId = touserid
        }
        else{
            self.releaseType = .morechance //说明是积分任务
        }
        //且 删除按钮没隐藏则上传位置信息
        if !self.locationdelete.isHidden {
            viewModel.input.data.lat = self.lat
            viewModel.input.data.lng = self.lng
        }
        
        viewModel.input.data.resourcelists = resourceLists
        viewModel.input.data.taskId = self.taskid
        viewModel.input.data.taskType = self.tasktype.rawValue
        viewModel.input.data.viewType = self.viewType
        viewModel.input.data.type = self.releaseType
        let userporvider = UserProVider.init()
        userporvider.greetingAdd(releaseData: viewModel.input.data, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                DispatchQueue.main.async {
                    MBProgressHUD.dismiss()
                }
                if self.toUserID == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        MatchLimitCountManager.shared.firstRefreshLimit(true)
                        self.showMoreChanceSuccess()
                    }
                } else{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        MBProgressHUD.showSuccess("Greeting task success".localiz())
                        self.blockRefresh?()
                        self.navigationController?.popViewController(animated: true)
                        self.userpublishSuccess?(self.toUserID!)
                    }
                }
            },onError: { (err) in
                DispatchQueue.main.async {
                                      MBProgressHUD.showError("greeting failed".localiz())
                                  }
            }).disposed(by: self.rx.disposeBag)
    }
    
    /// 获取了多少次数的提示
    func showMoreChanceSuccess() {
        //todo
        let  alterunlockView:MoreChanceGainAlterView? =  MoreChanceGainAlterView.loadNibView()
        alterunlockView?.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(295), height: scaleHeight(326))
        alterunlockView?.showOnWindow( direction: .center,enableclose: false)
        alterunlockView?.doneBlock = {
            [weak self] in
            guard let `self` = self  else {return }
            self.blockRefresh?()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
extension  UserPublishViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if String.isInputRuleNotBlank(str: text) {
            return true
        }
        /// 选择区域
        if let selectedRange = textView.markedTextRange {
            if let pos = textView.position(from: selectedRange.start, offset: 0) {
                /// 获取高亮部分内容
                //        let selectedText = textView.text(in: selectedRange)
                let startOffset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                let endOffset   = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
                if offsetRange.location < limitMaxWord{
                    return true
                }else{
                    return false
                }
            }
        }
        
        let str = textView.text + text
        if str.count > limitMaxWord {
            let rangeIndex = (str as NSString).rangeOfComposedCharacterSequence(at: limitMaxWord)
            if rangeIndex.length == 1{
                textView.text = (str as NSString).substring(to: limitMaxWord)
                
            }else{
                let renageRange = (str as NSString).rangeOfComposedCharacterSequences(for: NSMakeRange(0, limitMaxWord))
                textView.text = (str as NSString).substring(with: renageRange)
                
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        /// 选择区域
        if let selectedRange = textView.markedTextRange {
            
            //获取高亮部分
            if let pos = textView.position(from: selectedRange.start, offset: 0) {
                //如果在变化中是高亮部分在变，就不要计算字符了
                return
            }
        }
        
        if textView.text.count > limitMaxWord {
            textView.text = (textView.text as NSString ).substring(to: limitMaxWord)
        }
        
    }
}
