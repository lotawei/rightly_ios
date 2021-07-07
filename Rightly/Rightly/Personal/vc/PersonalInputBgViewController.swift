//
//  PersonalInputBgViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/12.
//

import UIKit
import RxSwift
import FSPagerView
import MBProgressHUD
import RxCocoa
import Kingfisher
import ZLPhotoBrowser
import KMPlaceholderTextView
import IQKeyboardManagerSwift
class PersonalCustomLinearTransformer: FSPagerViewTransformer {
    override func proposedInteritemSpacing() -> CGFloat {
        return  14
    }
}
class PersonalInputBgViewController:BaseViewController{
    var refreshBlock:(() -> Void)?=nil
    var  currentUrl:String? = nil
    fileprivate let  itemsize = CGSize.init(width: scaleWidth(67), height: scaleWidth(67))
    fileprivate let  itemspace:CGFloat = 14
    var selectImage:UIImage?=nil {
        didSet {
            self.enableCommitBtn((selectImage==nil) ? false:true)
        }
    }
    var  maxcount = 120
    @IBOutlet weak var contentV: UIView!
    @IBOutlet weak var bodyscrolleView: UIScrollView!
    @IBOutlet weak var lblstrikeup: UILabel!
    @IBOutlet weak var lbldestip: UILabel!
    @IBOutlet weak var lblrecently: UILabel!
    var  firstCompleReload:Bool = false
    @IBOutlet weak var selectedBtn: LoadingButton!
    @IBOutlet weak var backbtn: UIImageView!
    var  inputvalidSuccess:PublishSubject<Bool> = PublishSubject()
    var  avatarselectIndex:Int = 0
    let  personalBackImages:[UIImage] = [UIImage.init(named: "piclocal1")!,UIImage.init(named: "piclocal2")!,UIImage.init(named: "piclocal3")!,UIImage.init(named: "piclocal4")!]
    @IBOutlet weak var btncommit: UIButton!
    @IBOutlet weak var selectBannerView: UIView!
    lazy var bannerView:UIScrollView = {
        let bannerview = UIScrollView.init()
        bannerview.showsVerticalScrollIndicator = false
        bannerview.showsHorizontalScrollIndicator = false
        return  bannerview
    }()
    var  itemContainers:[UIImageView] = [UIImageView]()
    fileprivate func setSelectBackImage(_ image:UIImage?) {
        
        self.selectedBtn.setBackgroundImage(image, for: .normal)
        self.selectedBtn.setBackgroundImage(image, for: .selected)
        self.selectedBtn.setBackgroundImage(image, for: [.selected,.highlighted])
    }
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        let normalImage = UIImage.init(named: "addPhoto")
        setSelectBackImage(normalImage)
    }
    fileprivate func setupView() {
        IQKeyboardManager.shared.enable = false
        lbldestip.text = "A generation, a positive photo of himself.More people will complete your task with high-quality photos~".localiz()
        if firstCompleReload {
            lblstrikeup.text = "Upload personal photos".localiz()
        }else{
            lblstrikeup.text = "Update personal photos".localiz()
        }
        
        lblrecently.text = "Recently uploaded by Right.ly users".localiz()
        self.selectBannerView.addSubview(self.bannerView)
        var  i = 0
        for item in  personalBackImages{
            let itemimg = UIImageView.init()
            itemimg.isUserInteractionEnabled = true
            itemimg.image = item
            itemimg.frame = CGRect.init(x: CGFloat(i)*(itemsize.width + itemspace), y: 0, width: itemsize.width, height: itemsize.height)
            itemimg.tag = i
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(updateImage(_:)))
            itemimg.addGestureRecognizer(tap)
            itemContainers.append(itemimg)
            i = i + 1
            self.bannerView.addSubview(itemimg)
        }
        let sizew = CGFloat(personalBackImages.count)*(itemsize.width + itemspace) - itemspace
        self.bannerView.contentSize = CGSize.init(width: sizew, height: 0.0)
        bannerView.snp.makeConstraints { (makers) in
            makers.left.right.top.bottom.equalToSuperview()
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        self.backbtn.isHidden =  ((self.navigationController?.viewControllers.count ?? 0) > 1) ? false:true
        setupView()
        dataInital()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentV.setRoundCorners([.topLeft,.topRight], radius: 30)
        self.contentV.layoutIfNeeded()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    func dataInital()  {
        inputvalidSuccess.asObserver().bind(to: self.btncommit.rx.isSelected).disposed(by: self.rx.disposeBag)
        self.btncommit.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.actiondealWith()
        }).disposed(by: self.rx.disposeBag)
        if let url = self.currentUrl {
            self.selectedBtn.kf.setBackgroundImage(with:URL.init(string: url) , for: .normal, placeholder:  UIImage.init(named: "images")) { [weak self]
                (result) in
                guard let `self` = self  else {return }
                switch result {
                case .success(let res):
                    self.selectImage = res.image
                case .failure(_):
                    
                     break
                }
            }
            self.enableCommitBtn(true)
        }else{
            self.enableCommitBtn(false)
        }
    }
    func enableCommitBtn(_ enable:Bool){
        self.btncommit.isEnabled = enable
        self.btncommit.backgroundColor = enable ? themeBarColor:UIColor.lightGray
    }
    @objc func updateImage(_ sender:UITapGestureRecognizer) {
        //        guard let v = sender.view else {
        //            return
        //        }
        //        let tag = v.tag
        //        if tag <= personalBackImages.count - 1{
        //            self.selectedBtn.setBackgroundImage(personalBackImages[tag], for: .normal)
        //            self.selectImage = personalBackImages[tag]
        //        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func selectImageAction(_ sender: Any) {
        jumpPhotoLibrary()
    }
    func actiondealWith(){
        guard let selectimg = self.selectImage else {
            self.toastTip("Please choose a image")
            return
        }
        self.uploadBackGroundColor(image: selectimg)
    }
    
}



extension  PersonalInputBgViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func jumpPhotoLibrary(){
        let picker = UIImagePickerController()
        picker.automaticallyAdjustsScrollViewInsets = false
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        picker.navigationBar.isTranslucent = false
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .automatic
            } else {
                // Fallback on earlier versions
            }
            self.present(picker, animated: true, completion: nil)
        } else {
            self.toastTip("No permission".localiz())
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        picker.dismiss(animated: false, completion: nil)
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.cropImageProcess(img)
        }
    }
    func cropImageProcess(_ img:UIImage)  {
        let  cropVc = CropImageViewController.init()
        cropVc.configure = Configure.init(img.fixOrientation())
        cropVc.forceCrop = (self.selectImage==nil) ? true:false //首次是否
        cropVc.cropDone = { [weak self] (cropimage, configure) in
            guard let self = self else { return }
            self.selectImage = cropimage
            UIView.transition(with: self.selectedBtn,duration: 0.8,options: .transitionCrossDissolve,animations: {
                    self.setSelectBackImage(cropimage)
            }, completion: nil)
        }
        self.navigationController?.pushViewController(cropVc, animated: false)
    }
    
    func  uploadBackGroundColor(image:UIImage?){
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
        UserProVider.init().editUser(backgroundUrl: backurl,bgViewType: UserManager.manager.currentUser?.additionalInfo?.bgViewType ?? .Public, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                
//                switch res {
//                case .success(_):
//                    if self.firstCompleReload {
//                        AppDelegate.reloadRootVC()
//                    }else{
//                        self.refreshBlock?()
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                case .failed(_):
//
//                    self.toastTip("refresh failed".localiz())
//                }
                
            },onError: { (err) in
                self.toastTip("refresh failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
}
