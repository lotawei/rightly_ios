//
//  ZFPreVideoViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/11.
//

import Foundation
import KTVHTTPCache
class ZFPreVideoViewController:UIViewController {
    var  videoUrl:URL?
    var  coverUrl:URL?
    lazy var backButton: UIButton = {
          let button = UIButton()
          button.addTarget(self, action: #selector(topbackaction), for: .touchUpInside)
          button.setImage(UIImage.init(named: "arrow_white_left"), for: .normal)
          return button
    }()
    lazy var  containerView:UIView = {
        let cv = UIView.init(frame: .zero)
        return cv
    }()
    let playerManager = ZFAVPlayerManager.init()
    lazy var purePlayer:ZFPlayerController =  {
        let  player = ZFPlayerController.init(playerManager: self.playerManager, containerView: self.containerView)
        player.controlView = self.videoConrolView
         return player
    }()
    
    lazy var videoConrolView:ZFPlayerControlView = {
        return ZFPlayerControlView.init()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        self.createBackBtn()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.containerView)
        self.videoConrolView.backBtnClickCallback = {
            [weak self] in
            guard let `self` = self  else {return }
            self.navigationController?.popViewController(animated: false)
        }
        self.containerView.snp.remakeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(backButton.snp.bottom)
            maker.bottom.equalTo(bottomLayoutGuide.snp.bottom)
        }
        videoConrolView.prepareShowLoading = true
        purePlayer.containerView = self.containerView
        purePlayer.orientationWillChange = {
            [weak self] (zfplay,isfull) in
            guard let `self` = self  else {return }
            debugPrint("-------- \(isfull)")
        }
        /// 播放完成
        self.purePlayer.playerDidToEnd = {  [weak self] asset in
            guard let `self` = self  else {return }
            self.purePlayer.currentPlayerManager.replay()
            self.purePlayer.playTheNext()
        }
        configVideoInfo()
        
    }
    func   createBackBtn(){
        if backButton.superview == nil {
            self.view.addSubview(self.backButton)
            backButton.snp.remakeConstraints { (maker) in
                maker.top.equalTo(topLayoutGuide.snp.top).offset(50)
                maker.left.equalToSuperview().offset(16)
                maker.width.height.equalTo(30)
            }
        }
         
    }
    deinit {
        debugPrint("------- 释放可")
    }
    @objc func topbackaction(){
         self.navigationController?.popViewController(animated: false)
     }
    fileprivate func configVideoInfo(){
        
        guard  let curl = coverUrl else {
            return
        }
        let  res = curl.locaurlImageLoad()
        guard let vurl =  videoUrl?.convertToProxyUrlString() else {
            return
        }
        playerManager.assetURL = vurl
        purePlayer.enterPortraitFullScreen(true, animated: false)
//        playerManager.player.automaticallyWaitsToMinimizeStalling = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationToolManager.forceOrientationPortrait()
       
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
extension  URL {
    //URL转换成唱吧的url
    func convertToProxyUrlString() -> URL? {
        let url = KTVHTTPCache.proxyURL(withOriginalURL: self)
        return url
    }
    // Url 本地有的图片
    func locaurlImageLoad() -> Any? {
        if self.absoluteString.contains("http") || self.absoluteString.contains("https") {
            return self
        }else{
            if let dt = try? NSData.init(contentsOf: self) as? Data {
                let img = UIImage.init(data: dt)
                return img
            }
            return nil
        }
    }
}
