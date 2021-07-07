////
////  VideoPlayerViewController.swift
////  Rightly
////
////  Created by lejing_lotawei on 2021/4/6.
////
//
//import Foundation
//
//import UIKit
//import BMPlayer
//import AVFoundation
//import NVActivityIndicatorView
//class PreVideoPlayerViewController: UIViewController {
//    var  videoUrl:URL?=nil
//    var  coverimageUrl:URL?=nil
//    var player: BMPlayer!
//    var index: IndexPath!
//    lazy var backButton: UIButton = {
//        let button = UIButton()
//        button.addTarget(self, action: #selector(topbackaction), for: .touchUpInside)
//        button.setImage(UIImage.init(named: "arrow_white_left"), for: .normal)
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.black
//        self.fd_prefersNavigationBarHidden = true
//        setupPlayerManager()
//        preparePlayer()
//        createBackBtn()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(applicationDidEnterBackground),
//                                               name: UIApplication.didEnterBackgroundNotification,
//                                               object: nil)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(applicationWillEnterForeground),
//                                               name: UIApplication.willEnterForegroundNotification,
//                                               object: nil)
//
//    }
//
//    @objc func applicationWillEnterForeground() {
//
//    }
//
//    @objc func applicationDidEnterBackground() {
//        player.pause(allowAutoPlay: false)
//    }
//
//    /**
//     prepare playerView
//     */
//    func preparePlayer() {
//        var controller: BMPlayerControlView? = nil
//        player = BMPlayer(customControlView: controller)
//        view.addSubview(player)
//        player.snp.remakeConstraints { (make) in
//          make.top.equalTo(view.snp.top)
//          make.left.equalTo(view.snp.left)
//          make.right.equalTo(view.snp.right)
//          make.bottom.equalToSuperview()
//        }
//
//        player.delegate = self
//        player.backBlock = { [unowned self] (isFullScreen) in
//            if isFullScreen {
//                return
//            } else {
//                let _ = self.navigationController?.popViewController(animated: true)
//            }
//            self.view.layoutIfNeeded()
//        }
//    }
//    func   createBackBtn(){
//        self.view.addSubview(self.backButton)
//        backButton.snp.makeConstraints { (maker) in
//            maker.top.equalToSuperview().offset(30)
//            maker.left.equalToSuperview().offset(16)
//            maker.width.height.equalTo(40)
//        }
//
//    }
//    @objc func topbackaction(){
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    // 设置播放器单例，修改属性
//    func setupPlayerManager() {
//        resetPlayerManager()
//        BMPlayerConf.topBarShowInCase = .none
//    }
//    func resetPlayerManager() {
//        BMPlayerConf.allowLog = false
//        BMPlayerConf.shouldAutoPlay = true
//        BMPlayerConf.tintColor = UIColor.white
//        BMPlayerConf.topBarShowInCase = .always
//        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        player.pause(allowAutoPlay: true)
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        OrientationToolManager.forceOrientationAll()
//        if let  viurl  = videoUrl {
//            let asset = BMPlayerResource(name: "",
//                                         definitions: [BMPlayerResourceDefinition(url: viurl, definition: "480p")],
//                                         cover: self.coverimageUrl)
//            player.setVideo(resource: asset)
//
//        }
//
//        // If use the slide to back, remember to call this method
//        // 使用手势返回的时候，调用下面方法
//        //    player.autoPlay()
//    }
//
//    deinit {
//        // If use the slide to back, remember to call this method
//        // 使用手势返回的时候，调用下面方法手动销毁
//        player.prepareToDealloc()
//        print("VideoPlayViewController Deinit")
//    }
//}
//
//// MARK:- BMPlayerDelegate example
//extension PreVideoPlayerViewController: BMPlayerDelegate {
//    // Call when player orinet changed
//    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
//        player.snp.remakeConstraints { (make) in
//          make.top.equalTo(view.snp.top)
//          make.left.equalTo(view.snp.left)
//          make.right.equalTo(view.snp.right)
//          make.bottom.equalToSuperview()
//        }
//        backButton.snp.remakeConstraints { (maker) in
//            maker.top.equalToSuperview()
//            maker.left.equalToSuperview().offset(16)
//            maker.width.height.equalTo(40)
//        }
//    }
//
//    // Call back when playing state changed, use to detect is playing or not
//    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
//        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
//    }
//
//    // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
//    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
//        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
//    }
//
//    // Call back when play time change
//    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
//        //        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
//    }
//
//    // Call back when the video loaded duration changed
//    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
//        //        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
//    }
//}
//
