//
//  UserLightOrJoinTopicViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/27.

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import ZLPhotoBrowser
import Photos
import SnapKit
import KMPlaceholderTextView
enum ProcessPublishType {
    case joinTopic(_ topic:DiscoverTopicModel?),
         lightTag(_ itemtag:[ItemTag])
}

class UserLightOrJoinTopicViewController: BaseViewController {
    fileprivate var  limitMaxWord = 200
    var blockRefresh:(()->Void)?=nil
    var processType:ProcessPublishType = .lightTag([]) {
        didSet {
            
        }
    }
    lazy var topicAddBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addTopic(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor.init(hex: "A3A3A3"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("#" + "Add topic".localiz(), for: .normal)
        button.backgroundColor = UIColor.init(hex: "EDEDED")
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        return button
    }()
    fileprivate  var itemLighttags:[ItemTag] = [] //电亮标签
    fileprivate var joinTopics:[DiscoverTopicModel] = []{
        //参与话题
        didSet {
            self.topicAddBtn.isHidden =  !(joinTopics.count == 0)
        }
    }
    var limitLightType:TaskType?=nil
    var lng:Double?=nil
    var lat:Double?=nil
    var address:String?=nil
    var viewType:ViewType = .Public {
        didSet {
            let  title = (viewType == .Private) ? "Private".localiz():"Public".localiz()
            self.btnviewTypee.setTitle(title.localiz() , for: .normal)
        }
    }
    @IBOutlet weak var presentNavView: UIView!
    @IBOutlet weak var presentBtnBack: UIButton!
    @IBOutlet weak var presentLabelTitle: UILabel!
    @IBOutlet weak var presentBtnSend: UIButton!
    
    @IBOutlet var opreratorBtns: [UIButton]!
    var releaseType:ReleaseType = .greeting //具体看定义
    @IBOutlet weak var selectVoiceView: UIView!
    @IBOutlet weak var voiceheight: NSLayoutConstraint!
    let  topicOrLightTagView = TagSelectView.init()
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
    let emojiView = MessageEditSelectEmojiView.loadNibView() ?? MessageEditSelectEmojiView()
    @IBOutlet weak var locationbtn: UIButton!
    @IBOutlet weak var locationdelete: UIButton!
    @IBOutlet weak var btnviewTypee: UIButton!
    let locationmanager = LocationManager.init()
    var datas:[Any] = [Any]()
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tagView: UIView!
    var tasktype:TaskType = .photo {
        didSet {
            self.viewModel.input.releastType.onNext(self.tasktype)
        }
    }
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    var sectionVoice:(String?,String?)=(nil,nil)
    var viewModel: UserReleaseVmModel = UserReleaseVmModel.init()
    @IBOutlet weak var collectionhheight: NSLayoutConstraint!
    @IBOutlet weak var collectionBodyView: UIView!
    @IBOutlet weak var txtcontext: KMPlaceholderTextView!
    @IBOutlet weak var bodyView: UIView!
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
        self.fd_prefersNavigationBarHidden = true
        self.presentLabelTitle.text = "Release Dynamic".localiz()
        locationdelete.setTitle("delete".localiz(), for: .normal)
        self.locationbtn.setTitle("Where are you from".localiz(), for: .normal)
        txtcontext.placeholder = "What are you thinking of?".localiz()
        MediaResourceManager.shared.allselectedMedia.accept([])
        MediaResourceManager.shared.allselectedMedia.subscribe(onNext: { [weak self] value in
            guard let `self` = self  else {return }
            if self.tasktype == .voice {return }
            self.datas = []
            var  section:CGFloat = CGFloat(Int.getSection(value.count + 1, 3))
            if  value.count == MediaResourceManager.shared.allowMaxPicResource {
                section = 3
            }
            self.collectionhheight.constant = (section * (screenWidth - 50.0) / 3.0) + 20
            let check = (self.tasktype == .photo ) ? (MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowMaxPicResource):(MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowMaxVideoResource)
            self.datas += value
            self.postButtonState(self.datas.count > 0 )
            if   check {
                self.datas.append(1)
            }
            self.collectionView.reloadData()
            self.bodyView.layoutIfNeeded()
        }).disposed(by: self.rx.disposeBag)
        setUpView()
        bindViewModel(to: self.viewModel)
        postButtonState(false)
        updateSubViews()
    }
    func postButtonState(_ isenable:Bool)  {
        if isenable {
            self.presentBtnSend.backgroundColor = UIColor.init(hex: "27D3CF")
        } else{
            self.presentBtnSend.backgroundColor = UIColor.init(red: 180.0/255.0, green: 230.0/255, blue: 240/255.0, alpha: 1)
        }
        self.presentBtnSend.isEnabled = isenable
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationdelete.isHidden = true
        locationmanager.startOnceLocation{
            [weak self]
            status in
            guard let `self` = self  else {return }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationmanager.stopLocation()
    }
    func setUpView(){
        self.collectionBodyView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        self.tagView.addSubview(topicOrLightTagView)
        topicOrLightTagView.loadGrayStyle()
        self.topicOrLightTagView.frame = .zero
        switch self.processType {
        case .joinTopic(let  topic):
            //传进来的不能删
            topicOrLightTagView.showRemoveButton = false
            if let limitTopic = topic {
                self.tasktype = limitTopic.type.mapTaskType()
                joinTopics = [limitTopic]
                
            }else{
                joinTopics = []
            }
            
            if self.joinTopics.count == 0  {
                self.tagView.addSubview(self.topicAddBtn)
                topicAddBtn.snp.makeConstraints { (maker) in
                    maker.left.equalToSuperview().offset(16)
                    maker.centerY.equalToSuperview()
                    maker.height.equalTo(24)
                    maker.width.equalTo(80)
                }
            }else{
                self.topicOrLightTagView.setTags(joinTopics.map({ (topics) -> String in
                    return "#" + (topics.name ?? "")
                }))
            }
            
        case .lightTag(let itemtags):
            itemLighttags = itemtags
            //点亮标签的逻辑复杂些 需要关联话题
            
            self.topicOrLightTagView.setTags(itemtags.map({ (tag) -> String in
                return  tag.name ?? ""
            }))
            self.limitLightType =   itemtags.first?.relationTopic?.type.mapTaskType()
            if let limitTaskType = self.limitLightType {
                self.tasktype = limitTaskType
            }
        }
        self.topicOrLightTagView.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(16)
            maker.bottom.equalToSuperview()
            maker.height.equalTo(24)
            maker.width.equalTo((topicOrLightTagView.contensizeWidth > screenWidth - 16) ?  screenWidth - 32:topicOrLightTagView.contensizeWidth )
        }
        self.tagView.addSubview(topicOrLightTagView)
        self.bottomView.addSubview(self.emojiView)
        emojiView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        emojiView.isHidden = true
        emojiView.emojiSelectBlock = { [weak self] (text, imagePath) in
            guard let `self` = self  else {return }
            guard let emojiImage = UIImage(contentsOfFile: imagePath) else {
                return
            }
            
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.image = emojiImage
            attachment.emojiKey = text
            attachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
            let attachmentStr = NSMutableAttributedString(attachment: attachment)
            let attributedText:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.txtcontext.attributedText ?? attachmentStr)
            attributedText.append(attachmentStr)
            attributedText.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: attributedText.length))
            self.txtcontext.attributedText = attributedText
        }
        guard let selecview = self.selectView else {
            return
        }
        selectView?.alpha = 0
        self.bottomView.addSubview(selecview)
        selecview.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
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
    fileprivate func updateSubViews() {
        UIView.animate(withDuration: 0.3) {
            if self.tasktype == .photo || self.tasktype == .video{
                self.selectView?.isHidden = false
                self.voicerecordView?.isHidden = true
                MediaResourceManager.shared.allselectedMedia.accept([])
                self.contentHeight.constant = 80
                self.txtcontext.layoutIfNeeded()
                self.collectionhheight.constant = 100
                self.collectionBodyView.layoutIfNeeded()
                self.selectResource()
                self.voiceheight.constant = 0
            }else{
                self.selectView?.isHidden = true
                self.voicerecordView?.isHidden = false
                self.collectionhheight.constant = 0
                self.collectionBodyView.layoutIfNeeded()
                self.contentHeight.constant = 200
                self.txtcontext.layoutIfNeeded()
            }
        }
        
        self.resetState(self.tasktype.mapKeyTag())
    }
    
    @IBAction func voicebtnaction(_ sender: UIButton) {
        if checkLimitLight(.voice) {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if tasktype == .voice {
            if self.emojiView.isHidden == false {
                resetState(sender.tag)
                self.bottomView.sendSubviewToBack(self.emojiView)
                self.emojiView.isHidden = true
            }
            return
        }
        if self.judgeTopicLimit() {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if MediaResourceManager.shared.allselectedMedia.value.count > 0 && tasktype == .video  {
            self.toastTip("This is Photo Type can not change".localiz())
            return
        }
        if MediaResourceManager.shared.allselectedMedia.value.count > 0 && tasktype == .photo  {
            self.toastTip("This is Video Type can not change".localiz())
            return
        }
        self.tasktype = .voice
        updateSubViews()
    }
    
    func judgeTopicLimit() -> Bool {
        let  limitInfoType = joinTopics.filter { (model) -> Bool in
            if model.type == .voice {
                return true
            }
            if model.type == .photo {
                return true
            }
            if model.type == .video{
                return true
            }
            return false
        }
        if  limitInfoType.count > 0 {
            self.toastTip("Topic type limit can not change".localiz())
            return true
        }
        return false
    }
    
    @IBAction func photobtnaction(_ sender: UIButton) {
        if checkLimitLight(.photo) {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if  tasktype == .voice  {
            if (self.voicerecordView?.isrecord ?? false) {
                self.toastTip("Change media resource ,should clean voice at first".localiz())
                return
            }
        }
        if tasktype == .photo {
            if self.emojiView.isHidden == false {
                resetState(sender.tag)
                self.bottomView.sendSubviewToBack(self.emojiView)
                self.emojiView.isHidden = true
            }
            return
        }
        
        if self.judgeTopicLimit() {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if MediaResourceManager.shared.allselectedMedia.value.count > 0 && tasktype == .video  {
            self.toastTip("This is Photo Type can not change".localiz())
            return
        }
        if  let voicepath = self.sectionVoice.0 ,!voicepath.isEmpty  {
            self.toastTip("This is Voice Type can not change".localiz())
            return
        }
        resetState(sender.tag)
        self.tasktype = .photo
        updateSubViews()
    }
    @IBAction func cameraVideobtnaction(_ sender: UIButton) {
        if checkLimitLight(.video) {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if  tasktype == .voice  {
            if (self.voicerecordView?.isrecord ?? false) {
                self.toastTip("Change media resource ,should clean voice at first".localiz())
                return
            }
        }
        if tasktype == .video {
            if self.emojiView.isHidden == false {
                resetState(sender.tag)
                
            }
            return
        }
        if self.judgeTopicLimit() {
            self.toastTip("Topic type limit can not change".localiz())
            return
        }
        if MediaResourceManager.shared.allselectedMedia.value.count > 0 && tasktype == .photo  {
            self.toastTip("This is Video Type can not change".localiz())
            return
        }
        if  let voicepath = self.sectionVoice.0 ,!voicepath.isEmpty  {
            self.toastTip("This is Voice Type can not change".localiz())
            return
        }
        resetState(sender.tag)
        self.tasktype = .video
        updateSubViews()
    }
    
    func checkLimitLight(_ type:TaskType) -> Bool {
        if let limitaskType = self.limitLightType {
            if limitaskType == .text  {
                return false
            }
            if limitaskType != type {
                return true
            }
        }
        return false
    }
    
    @IBAction func emojAlteraction(_ sender:UIButton)  {
        
        if !sender.isSelected {
            self.bottomView.bringSubviewToFront(self.emojiView)
            self.emojiView.isHidden = false
        }else{
            self.bottomView.sendSubviewToBack(self.emojiView)
            self.emojiView.isHidden = true
        }
        sender.isSelected = !sender.isSelected
    }
    func resetState(_ tag:Int){
        MediaResourceManager.shared.allselectedMedia.accept([])
        for item  in self.opreratorBtns {
            if item.tag == tag {
                item.isSelected = true
            }else{
                item.isSelected = false
            }
        }
        self.bottomView.sendSubviewToBack(self.emojiView)
        self.emojiView.isHidden = true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func closeaction(_ sender: Any) {
        
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func deleteAudio(){
        self.voicerecordView?.clearSetting()
        self.sectionVoice.0 = nil
        self.sectionVoice.1 = nil
        self.voiceheight.constant = 0
        self.audioView?.audiopath = ""
        UIView.animate(withDuration: 0.3) {
            self.selectVoiceView.layoutIfNeeded()
        }
        postButtonState(false)
    }
    @IBAction func postAction(_ sender: Any) {
        let  selectedModelAssets = MediaResourceManager.shared.allselectedMedia.value
        guard let user = UserManager.manager.currentUser else {
            AppDelegate.jumpLogin()
            return
        }
        if self.txtcontext.attributedText.string.count > limitMaxWord  {
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


extension UserLightOrJoinTopicViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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



extension   UserLightOrJoinTopicViewController:VMBinding{
    func bindViewModel(to model: UserReleaseVmModel) {
        self.title = "Release Dynamic".localiz()
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
            self.viewtypeSelectView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 300)
            self.viewtypeSelectView?.showOnWindow( direction: .up)
            self.viewtypeSelectView?.clickSenderType =  { [weak self]
                viewtype in
                guard let `self` = self  else {return }
                self.viewType = ViewType.init(rawValue: viewtype) ?? .Public
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
}
extension UserLightOrJoinTopicViewController {
    
    fileprivate func uploadSelectedImage(_ selectedModelAssets: [ZLPhotoModel]) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.image, type: .greeting, selectedModelAssets, {[weak self] (lists) in
            DispatchQueue.main.async {
                MBProgressHUD.dismiss()
            }
            self?.postDynamicTagOrTopic(resourceLists: lists)
        },disposebag: self.rx.disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            MBProgressHUD.dismiss()
        }
    }
    fileprivate func uploadSelectedVideo(_ selectedModelAssets: [ZLPhotoModel]) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.video, type: .greeting, selectedModelAssets, {[weak self] (lists) in
            DispatchQueue.main.async {
                MBProgressHUD.dismiss()
            }
            self?.postDynamicTagOrTopic(resourceLists: lists)
        },disposebag: self.rx.disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            MBProgressHUD.dismiss()
        }
    }
    fileprivate func uploadSelectedVoice(_ audio:AudioInfo) {
        MBProgressHUD.showStatusInfo("release...".localiz())
        RTUploadFileTool.uploadgreetingResourceList(.audio, type: .greeting, [audio], {[weak self] (lists) in
            DispatchQueue.main.async {
                MBProgressHUD.dismiss()
            }
            self?.postDynamicTagOrTopic(resourceLists: lists)
            
        },disposebag: self.rx.disposeBag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            MBProgressHUD.dismiss()
        }
    }
    
    fileprivate func postDynamicTagOrTopic(resourceLists:[GreetingResourceList]) {
        viewModel.input.data.address = self.address
        viewModel.input.data.content = self.txtcontext.attributedText.exportTransFormAttibuttextView()
        //且 删除按钮没隐藏则上传位置信息
        if !self.locationdelete.isHidden {
            viewModel.input.data.lat = self.lat
            viewModel.input.data.lng = self.lng
        }
        viewModel.input.data.resourcelists = resourceLists
        switch self.processType {
        case .joinTopic(_):
            self.releaseType = .topic
            viewModel.input.data.topicIds = self.joinTopics.map({ (topicModel) -> Int64 in
                return topicModel.topicId
            })
        case .lightTag(_):
            self.releaseType = .tag
            viewModel.input.data.tagids = self.itemLighttags.map({ (tag) -> Int64 in
                return tag.tagId
            })
        }
        
        if  self.itemLighttags.count == 0 && self.joinTopics.count == 0 {
            self.releaseType = .simple
        }
        viewModel.input.data.taskType = self.tasktype.rawValue
        viewModel.input.data.viewType = self.viewType
        viewModel.input.data.type = self.releaseType
        let userporvider = UserProVider.init()
        userporvider.greetingAdd(releaseData: viewModel.input.data, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    switch self.processType {
                    case .joinTopic(_):
                        if self.joinTopics.count > 0 {
                            MBProgressHUD.showSuccess("Join Topic Success".localiz())
                        }else{
                            MBProgressHUD.showSuccess("Post Dynamic Success".localiz())
                        }
                        self.closeaction(1)
                    case .lightTag(_):
                        MBProgressHUD.showSuccess("Light Tag Success".localiz())
                    }
                    self.blockRefresh?()
                    self.navigationController?.popViewController(animated: true)
                }
            },onError: { (err) in
                DispatchQueue.main.async {
                    switch self.processType {
                    case .joinTopic(_):
                        MBProgressHUD.showError("Join Topic Failed".localiz())
                    case .lightTag(_):
                        MBProgressHUD.showError("Light Tag Failed".localiz())
                    }
                }
            }).disposed(by: self.rx.disposeBag)
    }
}


extension  UserLightOrJoinTopicViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if String.isInputRuleNotBlank(str: text) {
            return true
        }
        /// 选择区域
        if let selectedRange = textView.markedTextRange {
            if let pos = textView.position(from: selectedRange.start, offset: 0) {
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


extension  TaskType {
    /// 用于当前界面的映射
    /// - Returns: <#description#>
    func mapKeyTag() -> Int {
        switch self {
        case .photo:
            return 2
        case .voice:
            return 1
        case .video :
            return 3
        default:
            return 2
        }
    }
}


//以下逻辑只关系到 话题标签类型的
extension UserLightOrJoinTopicViewController {
    
    ///
    /// - Parameter sender: <#sender description#>
    @objc func addTopic(_ sender:UIButton){
        let  selectTopicV = SelectTopicView.loadNibView()
        selectTopicV?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: scaleHeight(400))
        selectTopicV?.showOnWindow(direction:.up)
        selectTopicV?.requestTopicItems()
        selectTopicV?.selectedBlock =  {
            [weak self ] seletedTopics in
            guard let `self` = self  else {return }
            self.updateSelectedTopic(seletedTopics: seletedTopics)
        }
    }
    
    func  updateSelectedTopic(seletedTopics:[DiscoverTopicModel]){
        self.joinTopics = seletedTopics
        topicOrLightTagView.showRemoveButton = true
        self.topicOrLightTagView.setTags(joinTopics.map({ (topics) -> String in
            return "#" + (topics.name ?? "")
        }))
        self.topicOrLightTagView.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(16)
            maker.bottom.equalToSuperview()
            maker.height.equalTo(24)
            maker.width.equalTo((topicOrLightTagView.contensizeWidth > screenWidth - 16) ?  screenWidth - 32:topicOrLightTagView.contensizeWidth )
        }
        if self.joinTopics.count >= 0 {
            topicOrLightTagView.tagIndexBlock =  {
                [weak self] selectIndex  in
                guard let `self` = self  else {return }
                self.removeTagSelect(selectIndex)
            }
        }
        topicAddBtn.isHidden = !(seletedTopics.count == 0)
        //如果选中后的话题限定了类型 则更新视图
        if self.judgeTopicLimit() {
            if let selectedTaskType = seletedTopics.first?.type.mapTaskType()  {
                self.tasktype = selectedTaskType
                updateSubViews()
            }
        }
        
    }
    
    func removeTagSelect(_ index:Int)  {
        if index <= joinTopics.count - 1 {
            self.joinTopics.remove(at: index)
            self.updateSelectedTopic(seletedTopics:self.joinTopics)
        }
    }
}
