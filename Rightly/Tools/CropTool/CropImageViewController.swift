//
//  CropImageViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/16.
//

import Foundation
class CropImageViewController: BaseViewController {
    var forceCrop:Bool = true //是否强制裁剪
    var configure: Configure?
    var croper: Croper!
    var cropDone: ((UIImage?, Configure) -> ())?
    lazy var  customTopV:UIView = {
        let  topV = UIView.init()
        topV.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(20)
            maker.width.height.equalTo(24)
            maker.bottom.equalToSuperview()
        }
        topV.addSubview(self.saveBtn)
        self.saveBtn.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-20)
            maker.height.equalTo(30)
            maker.width.equalTo(80)
            maker.bottom.equalToSuperview()
        }
        return topV
    }()
    lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        button.setBackgroundImage(UIImage.init(named: "white_back"), for: .normal)
        return button
    }()
    lazy var saveBtn: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.setTitle("Done".localiz(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    var  orignalCropImage:UIImage?=nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    func enableCommitBtn(_ enable:Bool){
        self.saveBtn.isEnabled = enable
        self.saveBtn.backgroundColor = enable ? themeBarColor:UIColor.lightGray
    }
    fileprivate func setUpView(){
        self.view.backgroundColor  = .black
        self.closeBtn.isHidden = forceCrop
        self.fd_prefersNavigationBarHidden = true
        self.fd_interactivePopDisabled = true
        self.view.addSubview(self.customTopV)
        self.customTopV.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.topLayoutGuide.snp.top).offset(20)
            maker.height.equalTo(44)
            maker.left.right.equalToSuperview()
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        guard let configure = self.configure else {
            return
        }
        enableCommitBtn(true)
        let fr = CGRect.init(x: 0, y: customTopV.frame.maxY, width: screenWidth, height: screenHeight -  customTopV.frame.maxY - safeBottomH)
        self.croper = Croper.init(frame: fr, configure)
        self.view.insertSubview( self.croper, at: 0)
        croper.updateCropWHRatio(1, rotateGridCount: (4, 4), animated: true) //指定1：1裁剪
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc func closeAction(_ sender:Any){
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func saveAction(_ sender:Any){
        guard let cropDone = self.cropDone else { return }
        let configure = croper.syncConfigure()
        croper.asyncCrop {
            guard let image = $0 else { return }
            cropDone(image, configure)
        }
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
