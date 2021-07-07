//
//  RTVoiceRecordManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/10.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import MBProgressHUD
extension  String {
    static func  audioSaveDir() -> String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }
}
protocol RTVoiceRecordManagerDelegate {
    func millisecondsRecord(_ milliseconds:Int)
}
typealias RecordAccSuccessBlock = ((_ accfile:String) -> Void)
class RTVoiceRecordManager:NSObject, AVAudioRecorderDelegate{
    var  delegate:RTVoiceRecordManagerDelegate?=nil
    var  maxTimeAllow:TimeInterval = 60  //最大允许时长
    var  minTimeAllow:TimeInterval = 1  //最小允许音频
    var  audioPlayerFinishBlock:((_ finished:Bool) -> Void)?=nil
    var  recordAccBlock:RecordAccSuccessBlock?=nil
    var milliseconds: Int = 0
    static let  shareinstance:RTVoiceRecordManager = RTVoiceRecordManager.init()
    var  volumePower:BehaviorRelay<Double> =  BehaviorRelay.init(value: 0)
    var  recorder:AVAudioRecorder? = nil
    var  player:AVAudioPlayer? = nil
    var  recorderSettings:[String:Any]? = nil
    var volumeTimer:Timer? = nil
    var  aacPath:String? = nil
    var  fileanme:String = ""
    var  session:AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        setConfig()
    }
    func setConfig()  {
        try? session.setCategory(AVAudioSession.Category.playAndRecord)
        try? session.setActive(true, options: AVAudioSession.SetActiveOptions.init())
        recorderSettings =
            [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2, //录音的声道数，立体声为双声道
                AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey : 320000,
                AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
            ]
    }
    func startRecord(_ fileanme:String, recordSuccess:@escaping RecordAccSuccessBlock) {
        self.clearnSetUp()
        self.recordAccBlock = recordSuccess
        self.setConfig()
        self.aacPath = String.audioSaveDir() + "/\(fileanme).aac"
        SystemPermission.checkMicrophone(alertEnable: true) {[weak self] granted in
            guard let `self` = self  else {return }
            self.milliseconds = 0
            if granted {
                DispatchQueue.main.async {
                    self.enterRecord()
                }
            }
        }
    }
    
    fileprivate func enterRecord(){
        guard let accpath = self.aacPath,let setting = self.recorderSettings else {
            return
        }
        
        let saveUrl = URL.init(fileURLWithPath: accpath)
        try? FileManager.default.removeItem(at: saveUrl)
        self.recorder?.deleteRecording()
        self.recorder?.updateMeters()
        self.recorder = try? AVAudioRecorder.init(url:saveUrl, settings:setting)
        self.recorder?.delegate  = self
        guard let rec = recorder else {
            return
        }
        rec.isMeteringEnabled = true
        rec.prepareToRecord()
        if !(self.recorder?.isRecording ?? false) {
            self.recorder?.record(forDuration: self.maxTimeAllow)
        }
        volumeTimer = Timer.init(timeInterval: 0.1, target: self, selector: #selector(updateTimeLabel(timer:)), userInfo: nil, repeats: true)
        if let vtime = volumeTimer {
            RunLoop.main.add(vtime, forMode: .common)
            //            RunLoop.main.add(vtime, forMode: .tracking)
        }
    }
    
    @objc func updateTimeLabel(timer: Timer) {
        self.milliseconds += 100  //这是个模拟
        self.delegate?.millisecondsRecord(self.milliseconds)
    }
    
    
    func stopRecord(){
        guard let path = aacPath else {
            debugPrint("----- error path")
            return
        }
        let  realDuration = RTVoiceRecordManager.getAudioduration(urlpath: path) //真实的时长
        self.delegate?.millisecondsRecord(realDuration)
        recorder?.stop()
        clearnSetUp()
        
    }
    func clearnSetUp()  {
        volumeTimer?.invalidate()
        volumeTimer = nil
        milliseconds = 0
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            debugPrint("-----\(NSHomeDirectory())")
            guard let path = aacPath else {
                debugPrint("----- error path")
                return
            }
            if RTVoiceRecordManager.getAudioduration(urlpath:path) < Int(RTVoiceRecordManager.shareinstance.minTimeAllow) * 1000  {
                UIViewController.getCurrentViewController()?.toastTip("The duration of the voice cannot be sustained for 1 second".localiz())
                self.recordAccBlock?("")
            } else{
                self.recordAccBlock?(path)
            }
        }else{
            debugPrint("====== record failed")
        }
        clearnSetUp()
        self.recorder = nil //
        
    }
    
}
extension RTVoiceRecordManager :AVAudioPlayerDelegate {
    func startPlayerAudio(audiopath:String,finishBlock:@escaping ((_ finished:Bool)->Void)){
        self.stopPlayerAudio()
        self.audioPlayerFinishBlock = finishBlock
        if !audiopath.isEmpty {
            if audiopath.contains("http") {
                if let neturl =  URL.init(string: audiopath) {
                    DispatchQueue.global().async {
                        let audiodata = try? Data.init(contentsOf: neturl)
                        if let data = audiodata {
                            DispatchQueue.main.async {
                                self.player = try? AVAudioPlayer.init(data: data)
                                self.player?.delegate = self
                                self.player?.prepareToPlay()
                                self.player?.play()
                            }
                            
                        }
                    }
                    
                }
            } else {
                if let  url = URL(string: audiopath) {
                    player = try? AVAudioPlayer(contentsOf: url)
                    player?.prepareToPlay()
                    player?.delegate = self
                    player?.play()
                }
            }
            
        }
        
    }
    
    func  stopPlayerAudio() {
        player?.stop()
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayerFinishBlock?(flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        debugPrint("---- error")
    }
}



extension RTVoiceRecordManager {
    /// 获取本地音频时长 毫秒级别
    /// - Parameter file: <#file description#>
    /// - Returns: <#description#>
    static func getAudioduration(urlpath:String ) -> Int {
        let url = URL.init(fileURLWithPath: urlpath)
        let avaset =  AVAsset.init(url: url)
        return Int(CMTimeGetSeconds(avaset.duration) * 1000)
    }
    
    /// 获取网络音频时长
    /// - Parameter file: <#file description#>
    /// - Returns: <#description#>
    static func getAudiodurationForNetWork(networkUrl:String,_ completed:@escaping((_ duration:Int) -> Void))  {
        DispatchQueue.global().async {
            if let neturl =   URL.init(string:networkUrl){
                let avaset =  AVURLAsset.init(url: neturl, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
                completed(Int(CMTimeGetSeconds( avaset.duration) * 1000))
            }
            else {
                completed(0)
            }
        }
    }
    
}
