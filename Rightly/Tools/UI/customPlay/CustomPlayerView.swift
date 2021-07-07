//
//  CustomPlayerView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/7.
//

import Foundation
import RxSwift
import NVActivityIndicatorView
class CustomPlayerView:UIView {
    var  shouldAutoPlay:Bool = true {
        didSet {
            self.playerManager.shouldAutoPlay = shouldAutoPlay
        }
    }
    var  shouldReply:Bool =  true //是否返回播放
    // 封面视图
    lazy var  coverView:UIImageView = {
        let  coverImageBackV:UIImageView = UIImageView.init()
        coverImageBackV.alpha = 0.8
        coverImageBackV.image = UIImage.init(named: "images")
        return coverImageBackV
    }()
    //视频容器
    lazy var containerV:UIView = {
        let  conV = UIView.init()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick(_:)))
        conV.addGestureRecognizer(tap)
        conV.isUserInteractionEnabled = true
        return conV
    }()
    var  controlView:CustomControlView?=CustomControlView.loadNibView()
    fileprivate var currentPlayUrl:(String,String) = ("https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4","")
    fileprivate let playerManager = ZFAVPlayerManager.init()
    lazy var purePlayer:ZFPlayerController =  {
        let  player = ZFPlayerController.init(playerManager: self.playerManager, containerView: self.containerV)
        player.pauseWhenAppResignActive = false
        player.resumePlayRecord = true
        player.isWWANAutoPlay = true
        return player
    }()
    fileprivate var  playUrls:([String],[String]) = ([],[])
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubView()
    }
    fileprivate  func setUpSubView(){
        self.addSubview(self.coverView)
        self.addSubview(self.containerV)
        
        self.coverView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.containerV.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        playMangerSubcribe()
    }
    fileprivate func sendBackCover(_ backCover:Bool)  {
        if backCover {
            self.sendSubviewToBack(coverView)
        }else{
            self.bringSubviewToFront(self.containerV)
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubView()
    }
    
    fileprivate func playMangerSubcribe() {
        /// 播放状态
        self.playerManager.rx.observeWeakly(ZFPlayerPlaybackState.self, "playState").asObservable().subscribe(onNext: { [weak self] (playstate) in
            guard let pstate = playstate,let `self` = self else {
                return
            }
            debugPrint("----kkk-\(pstate.rawValue)")
            switch pstate {
            case .playStatePaused:
                break
            case .playStatePlayFailed:
                break
            case .playStatePlayStopped:
                break
            case .playStatePlaying:
                self.sendBackCover(true)
                break
            case .playStateUnknown:
                break
            }
        }).disposed(by: self.rx.disposeBag)
        
        /// 加载状态
        self.playerManager.rx.observeWeakly(ZFPlayerLoadState.self, "loadState").asObservable().subscribe(onNext: { [weak self] (loadState) in
            guard let lstate = loadState ,let `self` = self else {
                return
            }
            debugPrint("----kkkjjj-\(lstate.rawValue)")
            switch lstate {
            case .prepare:
                break
            case .playable:
//                self.loadingView.stopAnimating()
                break
            case .playthroughOK:
//                self.loadingView.stopAnimating()
                break
            case .stalled:
                
                break
            default:
                
                break
            }
        }).disposed(by: self.rx.disposeBag)
//        监听播放器是否播放
        self.playerManager.rx.observeWeakly(Bool.self, "isPlaying").subscribe(onNext: { [weak self] (isplaying) in
            guard let `self` = self , let isplay = isplaying else {return }
//            if isplay {
//                self.loadingView.stopAnimating()
//            }
        }).disposed(by: self.rx.disposeBag)
    }
    fileprivate func initalPlayer(_ url:String,coverUrl:String = "")  {
        guard let videoUrl = URL.init(string: url) ,let controlV = self.controlView else {
            debugPrint("---- error url ")
            return
        }
        if self.playerManager.isPlaying {
            self.playerManager.stop()
        }
        self.purePlayer.assetURL = videoUrl
        if !coverUrl.isEmpty,let cover = URL.init(string: coverUrl) {
            self.coverView.kf.setImage(with: cover,options: webpOptional)
        }
        purePlayer.controlView = controlV
        self.playerManager.prepareToPlay()
        self.purePlayer.playerDidToEnd = {
            [weak self] asset in
            guard let `self` = self  else {return }
            self.purePlayer.currentPlayerManager.replay()
            self.purePlayer.playTheNext()
        }
        self.sendBackCover(false)
    }
    @objc func tapClick(_ sender:UITapGestureRecognizer){
        debugPrint("show tool")
    }
}
extension CustomPlayerView{
    public func initPlayer(urls: [String],coverUlrs:[String]) {
        self.playUrls = (urls,coverUlrs)
        guard let firstUrl = self.playUrls.0.first else { return }
        self.currentPlayUrl.0 = firstUrl
        self.currentPlayUrl.1 = coverUlrs.first ?? ""
        self.initalPlayer(firstUrl,coverUrl: coverUlrs.first ?? "")
    }
}

class CustomControlView:UIView,NibLoadable{
    var player: ZFPlayerController!
    var autoHiddenTimeInterval:Double = 6
    var  autoFadeTimeInterval:Double = 0.4
    @IBOutlet weak var playOrPauseBtn:UIButton! //播放暂停按钮
    @IBOutlet weak var totalTimeLabel:UILabel! //时间总长
    @IBOutlet weak var currentTimeLabel:UILabel! //当前时间
    @IBOutlet weak var bottomToolView:UIView!//底部工具条
    @IBOutlet weak var bottomAlign: NSLayoutConstraint!
    @IBOutlet weak var fullScreenBtn:UIButton! //全屏按钮
    @IBOutlet weak var slider: ZFSliderView! //进度条
    @IBOutlet weak var navBackBtn:UIButton! //返回按钮
    @IBOutlet weak var maskLoadView: UIView!
    lazy var loadView: NVActivityIndicatorView = {
        let loadView = NVActivityIndicatorView.init(frame: .zero,type: .circleStrokeSpin)
        loadView.color = .white
        return loadView
    }()
    @IBOutlet weak var topAlighn: NSLayoutConstraint!
    @IBOutlet weak var topToolView:UIView!
    fileprivate var afterBlock:DispatchWorkItem?
    fileprivate var  controlViewAppeared:Bool = false
    fileprivate var  isShow:Bool = false
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.maskLoadView.addSubview(self.loadView)
        self.loadView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(50)
        }
        self.configSubViewStyle()
        makerActionListener()
        resetControlView()
    }
    func configSubViewStyle(){
        self.slider.delegate = self
        self.slider.sliderHeight = 20
        self.slider.minimumTrackTintColor = .white
        self.slider.maximumTrackTintColor = .clear
        self.slider.bufferTrackTintColor = UIColor.init(red: 1/255.0, green: 1/255.0, blue: 1/255.0,alpha: 0.5)
        self.slider.sliderHeight = 1
        self.slider.setThumbImage(UIImage.init(named:"ZFPlayer_slider"),for:.normal)
        self.slider.isHideSliderBlock = false
        self.bottomToolView.layer.contents = UIImage.init(named:"ZFPlayer_bottom_shadow")?.cgImage
    }
}

extension CustomControlView:ZFPlayerMediaControl,ZFSliderViewDelegate{
    /// 展示封面
    /// - Parameter cover:
    func showCover(_ cover:String)  {
        
    }
    func resetControlView()  {
        self.bottomToolView.alpha = 1
        self.currentTimeLabel.text = "00:00"
        self.totalTimeLabel.text = "00:00"
        self.backgroundColor = .clear
        self.playOrPauseBtn.isSelected = true
    }
    func showControlView()  {
        self.topToolView.alpha = 1
        self.bottomToolView.alpha = 1
        self.isShow = true
        self.bottomAlign.constant = 50
        self.topAlighn.constant = 50
        self.playOrPauseBtn.alpha = 1
        self.player.isStatusBarHidden = false
    }
    func hideControlView(){
        self.topToolView.alpha = 0
        self.bottomToolView.alpha = 0
        self.isShow = false
        self.bottomAlign.constant = 0
        self.topAlighn.constant = 0
        self.playOrPauseBtn.alpha = 1
        self.player.isStatusBarHidden = false
    }
    func hideControlViewWithAnimated(_ animated:Bool){
        self.controlViewAppeared = false
        UIView.animate(withDuration: animated ? self.autoFadeTimeInterval : 0) {
            self.hideControlView()
        } completion: { (finish) in
            
        }

    }
    func showControlViewWithAnimated(_ animated:Bool){
        self.controlViewAppeared = true
        self.autoFadeOutControlView()
        UIView.animate(withDuration: animated ? self.autoFadeTimeInterval : 0) {
            self.showControlView()
        } completion: { (finish) in
            
        }

    }
    func autoFadeOutControlView(){
        self.controlViewAppeared = true
        self.afterBlock =  DispatchWorkItem{ [weak self] in
            guard let `self` = self  else {return }
            self.hideControlViewWithAnimated(true)
        }
        guard let afBlock = afterBlock else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+self.autoHiddenTimeInterval,execute: afBlock)
    }
    
    func cancelAutoFadeOutControlView(){
        if self.afterBlock != nil {
            self.afterBlock?.cancel()
        }
    }
    func shouldResponseGestureWithPoint(_ point:CGPoint,touch:UITouch) ->Bool{
        return true
    }
    
    func showLoadingMask(_ show:Bool) {
        show ? self.bringSubviewToFront(self.maskLoadView):self.sendSubviewToBack(self.maskLoadView)
        UIView.animate(withDuration: 0.2) {
            self.maskLoadView.alpha = show ? 1:0
        }
        show ? self.loadView.startAnimating() : self.loadView.stopAnimating()
    }
    func makerActionListener(){
        self.playOrPauseBtn.addTarget(self, action: #selector(playPauseButtonClickAction(_:)), for: .touchUpInside)
    }
    
    func gestureTriggerCondition(_ gestureControl: ZFPlayerGestureControl, gestureType: ZFPlayerGestureType, gestureRecognizer: UIGestureRecognizer, touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        if self.player.isSmallFloatViewShow && !self.player.isFullScreen && gestureType != ZFPlayerGestureType.singleTap {
            return false
        }
        return true
    }
    func gestureSingleTapped(_ gestureControl: ZFPlayerGestureControl) {
        if self.player == nil {
            return
        }
        if self.player.isSmallFloatViewShow && !self.player.isFullScreen {
            self.player.enterFullScreen(true, animated: true)
        }else{
            if self.controlViewAppeared {
                self.hideControlViewWithAnimated(true)
            }else{
                self.hideControlViewWithAnimated(false)
                self.showControlViewWithAnimated(true)
            }
        }
    }
    func gestureDoubleTapped(_ gestureControl: ZFPlayerGestureControl) {
        self.playOrPause()
    }
    
    func gesturePinched(_ gestureControl: ZFPlayerGestureControl, scale: Float) {
        if scale > 1 {
            self.player.currentPlayerManager.scalingMode = .aspectFill
        }else{
            self.player.currentPlayerManager.scalingMode = .aspectFit
        }
    }
    func videoPlayer(_ videoPlayer: ZFPlayerController, prepareToPlay assetURL: URL) {
        self.hideControlViewWithAnimated(false)
    }
    func videoPlayer(_ videoPlayer: ZFPlayerController, playStateChanged state: ZFPlayerPlaybackState) {
        if state == .playStatePlaying {
            self.platBtnSelected(true)
            if self.player.currentPlayerManager.loadState == .stalled {
                self.showLoadingMask(true)
            }else if self.player.currentPlayerManager.loadState == .stalled || self.player.currentPlayerManager.loadState == .prepare{
                self.showLoadingMask(true)
            }
        }
        else if state == .playStatePaused{
            self.showLoadingMask(false)
        }else if state == .playStatePlayFailed {
            self.showLoadingMask(false)
        }
    }
    //加载状态
    func videoPlayer(_ videoPlayer: ZFPlayerController, loadStateChanged state: ZFPlayerLoadState) {
        if state == .prepare {
            showLoadingMask(true)
        }else if state == .playthroughOK || state == .playable {
            videoPlayer.currentPlayerManager.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
        if state == .stalled && videoPlayer.currentPlayerManager.isPlaying {
            showLoadingMask(true)
        }else{
            showLoadingMask(false)
        }
    }
    
    func videoPlayer(_ videoPlayer: ZFPlayerController, bufferTime: TimeInterval) {
        
    }
    func videoPlayer(_ videoPlayer: ZFPlayerController, presentationSizeChanged size: CGSize) {
        //size发生改变
    }
   @objc func playPauseButtonClickAction(_ sender:UIButton){
        self.playOrPause()
    }
    func playOrPause(){
        self.playOrPauseBtn.isSelected = !self.playOrPauseBtn.isSelected
        self.playOrPauseBtn.isSelected ? self.player.currentPlayerManager.play():self.player.currentPlayerManager.pause()
    }
    //
    func  platBtnSelected(_ selected:Bool){
        self.playOrPauseBtn.isSelected = selected
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    //slider delegate
    func sliderTouchBegan(_ value: Float) {
        self.slider.isdragging = true
    }
    func sliderTouchEnded(_ value: Float) {
        if self.player.totalTime > 0{
            self.player.seek(toTime: self.player.totalTime*Double(value)) {[weak self] (finish) in
                guard let `self` = self  else {return }
                if finish {
                    self.slider.isdragging = false
                }
            }
        }else{
            self.slider.isdragging = false
        }
    }
    func sliderValueChanged(_ value: Float) {
        if self.player.totalTime == 0 {
            self.slider.value = 0
            return
        }
        self.slider.isdragging = true
        
    }
    
    
    //时间戳相关
    func videoPlayer(_ videoPlayer: ZFPlayerController, currentTime: TimeInterval, totalTime: TimeInterval) {
        if !slider.isdragging {
            let currenttime = Date.convertTimeSecond(Int(currentTime))
            self.currentTimeLabel.text = currenttime
            let totaltime = Date.convertTimeSecond(Int(totalTime))
            self.totalTimeLabel.text = totaltime
            self.slider.value = videoPlayer.progress
        }
        
    }
}

