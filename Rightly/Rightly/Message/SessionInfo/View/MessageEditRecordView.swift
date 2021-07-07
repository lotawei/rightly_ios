//
//  MessageEditRecordView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/16.
//

import UIKit
import AVFoundation
import NIMSDK
import NVActivityIndicatorView

enum RecordStatus {
    case unknow
    case recording
    case stopRecord
    case cancelRecord
}

class MessageEditRecordView: UIView, NibLoadable {
    var recordDuration:TimeInterval = 0.0
    var userTouched:Bool = false
    @IBOutlet weak var recordInfoView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLeftAnimateView: NVActivityIndicatorView!
    @IBOutlet weak var timeRightAnimateView: NVActivityIndicatorView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordImageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    
    var recordStatus:RecordStatus = .unknow
    
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/imrecord") ?? ""
    var recordPath:String =  "" {
        didSet {
            self.isUserInteractionEnabled = recordPath.isEmpty
            enableRecordImage(recordPath.isEmpty)
            deleteImageView.isHidden = !recordPath.isEmpty
        }
    }
    
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
    }
    
    /// 禁用状态显示
    /// - Parameter enable: <#enable description#>
    func enableRecordImage(_ enable:Bool)  {
        if enable {
            self.recordImageView.image = UIImage.init(named: "message_audio_record_btn")
        }else{
            self.recordImageView.image = UIImage.init(named: "forbiddenvoice")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = "hold_to_speak".localiz()
        
        if self.deleteImageView.image == nil {
            let norImg = UIImage(named: "message_record_will_delete_icon")
            let norImgView = UIImageView.init(image: norImg)
            norImgView.contentMode = .center
            norImgView.backgroundColor = UIColor.init(hex: "FAFAFA", alpha: 1)
            norImgView.frame = CGRect.init(x: 0, y: 0, width: 48, height: 48)
            norImgView.cornerRadius = 24.0
            let norDelImg = norImgView.snapViewImage()
            self.deleteImageView.image = norDelImg
            
            let selImg = UIImage(named: "message_record_delete_icon")
            let selImgView = UIImageView.init(image: selImg)
            selImgView.contentMode = .center
            selImgView.backgroundColor = UIColor.init(hex: "FF6767", alpha: 1)
            selImgView.frame = CGRect.init(x: 0, y: 0, width: 72, height: 72)
            selImgView.cornerRadius = 36.0
            let selDelImg = selImgView.snapViewImage()
            self.deleteImageView.highlightedImage = selDelImg
        }
        
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().mediaManager.recordProgressUpdateTimeInterval = 0.1
    }
}

extension MessageEditRecordView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("touchesBegan")
        SystemPermission.checkMicrophone(alertEnable: true) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.userTouched = true
                    if !self.recordImageView.isHighlighted {
                        for touch in touches {
                            let startPoin:CGPoint = touch.location(in: self)
                            let tempHalf:CGFloat = CGFloat(startPoin.x - self.recordImageView.center.x) * CGFloat(startPoin.x - self.recordImageView.center.x) + CGFloat(startPoin.y - self.recordImageView.center.y) * CGFloat(startPoin.y - self.recordImageView.center.y)
                            let halfLin = sqrt(tempHalf)
                            if halfLin <= 50 {
                                debugPrint("在录制按钮范围内，开始录音")
                                NIMSDK.shared().mediaManager.record(.AAC, duration: RTVoiceRecordManager.shareinstance.maxTimeAllow)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("touchesMoved")
        if self.recordImageView.isHighlighted {
            for touch in touches {
                let currentPoin:CGPoint = touch.location(in: self)
                let tempHalf:CGFloat = CGFloat(currentPoin.x - self.deleteImageView.center.x) * CGFloat(currentPoin.x - self.deleteImageView.center.x) + CGFloat(currentPoin.y - self.deleteImageView.center.y) * CGFloat(currentPoin.y - self.deleteImageView.center.y)
                let halfLin = sqrt(tempHalf)
                if halfLin <= 36 {
                    debugPrint("在录删除钮范围内")
                    self.deleteImageView.isHighlighted = true
                    
                } else {
                    debugPrint("在录删除钮范围外")
                    self.deleteImageView.isHighlighted = false
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("touchesEnded")
        self.userTouched = false
        if self.recordImageView.isHighlighted {
            if NIMSDK.shared().mediaManager.isRecording() && !self.deleteImageView.isHighlighted {
                if self.recordDuration >= 1 {
                    self.recordStatus = .stopRecord
                    NIMSDK.shared().mediaManager.stopRecord()
                } else {
                    MBProgressHUD.showError("The recording is too short".localiz())
                    self.recordStatus = .cancelRecord
                    NIMSDK.shared().mediaManager.cancelRecord()
                }
            } else {
                self.recordStatus = .cancelRecord
                NIMSDK.shared().mediaManager.cancelRecord()
            }
            
            self.recordImageView.isHighlighted = false
            self.deleteImageView.isHighlighted = false
            self.deleteImageView.isHidden = true
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("touchesCancelled")
        self.userTouched = false
    }
    
    func updateRecordUI(_ begin:Bool) {
        if begin {
            self.timeLeftAnimateView.startAnimating()
            self.timeRightAnimateView.startAnimating()
            self.timeLabel.text = "0.0"
            self.titleView.isHidden = true
            self.recordInfoView.isHidden = false
            self.recordImageView.isHighlighted = true
            self.deleteImageView.isHidden = false
        } else {
            self.timeLeftAnimateView.stopAnimating()
            self.timeRightAnimateView.stopAnimating()
            self.titleView.isHidden = false
            self.recordInfoView.isHidden = true
            self.recordImageView.isHighlighted = false
            self.deleteImageView.isHidden = true
        }
    }
}

extension MessageEditRecordView : NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        debugPrint("开始播放音频的回调")
    }
    
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        debugPrint("播放完音频的回调")
    }
    
    func playAudio(_ filePath: String, progress value: Float) {
//        debugPrint("播放完音频的进度回调")
    }
    
    func stopPlayAudio(_ filePath: String, didCompletedWithError error: Error?) {
        debugPrint("停止播放音频的回调")
    }

    func playAudioInterruptionBegin() {
        debugPrint("播放音频开始被打断回调")
    }
    
    func playAudioInterruptionEnd() {
        debugPrint("播放音频结束被打断回调")
    }
    
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        debugPrint("开始录制音频的回调 如果录音失败，filePath 有可能为 nil")
        self.recordDuration = 0.0
        if (error != nil || filePath == nil) {
            debugPrint("录音失败!!!!!!!!!!!!")
            MBProgressHUD.showError("record error!".localiz())
            NIMSDK.shared().mediaManager.cancelRecord()
            return
        }
        
        if self.userTouched == false {
            NIMSDK.shared().mediaManager.cancelRecord()
            return
        }
        self.updateRecordUI(true)
    }
    
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?) {
        debugPrint("录制音频完成 \(filePath)")
        
        self.updateRecordUI(false)
    }
    
    func recordAudioDidCancelled() {
        debugPrint("录音被取消的回调")
        self.updateRecordUI(false)
    }
    
    func recordAudioProgress(_ currentTime: TimeInterval) {
        debugPrint("音频录制进度更新回调")
        self.recordDuration = currentTime
        if self.recordImageView.isHighlighted {
            if self.deleteImageView.isHighlighted {
                self.timeLabel.text = "cancel_sending".localiz()
            } else {
                if currentTime < 10 {
                    self.timeLabel.text = String.init(format: "%.1lf", currentTime)
                } else {
                    self.timeLabel.text = String.init(format: "%.0lf", currentTime)
                }
            }
        }
    }

    func recordAudioInterruptionBegin() {
        debugPrint("录音开始被打断回调")
        self.updateRecordUI(false)
    }
    
    func recordAudioInterruptionEnd() {
        debugPrint("录音结束被打断回调")
        self.updateRecordUI(false)
    }
}

