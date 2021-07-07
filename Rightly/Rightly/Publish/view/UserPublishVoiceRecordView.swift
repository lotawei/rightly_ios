//
//  UserPublishVoiceRecordView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/23.
//

import Foundation
import MBProgressHUD
import RxSwift
import NVActivityIndicatorView

class UserPublishVoiceRecordView: UIView ,NibLoadable {
    var  filename:String = ""
    var  deleTeActionBlock:(()->Void)?=nil
    var  isrecord:Bool = false
    @IBOutlet weak var btnremove: UIButton!
    
    fileprivate var  audioPath:String = "" {
        didSet {
            if !audioPath.isEmpty {
                self.playimg.isUserInteractionEnabled = false
                self.playimg.image = UIImage.init(named: "forbiddenvoice")
                self.btnremove.isHidden = true
                self.isrecord = false
            } else {
                self.isrecord = false
                RTVoiceRecordManager.shareinstance.clearnSetUp()
                self.playimg.isUserInteractionEnabled = true
                self.playimg.image = UIImage.init(named: "highlightvoice")
                self.btnremove.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var toptipView: UIView!
    @IBOutlet weak var lblsecond: UILabel!
    @IBOutlet weak var leftview: NVActivityIndicatorView!
    @IBOutlet weak var rightview: NVActivityIndicatorView!
    @IBOutlet weak var lbltip: UILabel!
    @IBOutlet weak var pressges: UILongPressGestureRecognizer!
    @IBOutlet weak var playimg: UIImageView!
    var recordSuccessBlock:RecordAccSuccessBlock?=nil
    var animation = CABasicAnimation.init()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pressges.addTarget(self, action: #selector(handelerLongPress(_:)))
        self.lbltip.isHidden = false
        self.toptipView.isHidden = true
        self.audioPath = ""
        self.lbltip.text = "hold_to_speak".localiz()
        
        let norImg = UIImage(named: "message_record_will_delete_icon")
        let norImgView = UIImageView.init(image: norImg)
        norImgView.contentMode = .center
        norImgView.backgroundColor = UIColor.init(hex: "FAFAFA", alpha: 1)
        norImgView.frame = CGRect.init(x: 0, y: 0, width: 48, height: 48)
        norImgView.cornerRadius = 24.0
        let norDelImg = norImgView.snapViewImage()
        self.btnremove.setImage(norDelImg, for: .normal)
        
        let selImg = UIImage(named: "message_record_delete_icon")
        let selImgView = UIImageView.init(image: selImg)
        selImgView.contentMode = .center
        selImgView.backgroundColor = UIColor.init(hex: "FF6767", alpha: 1)
        selImgView.frame = CGRect.init(x: 0, y: 0, width: 72, height: 72)
        selImgView.cornerRadius = 36.0
        let selDelImg = selImgView.snapViewImage()
        self.btnremove.setImage(selDelImg, for: .highlighted)
    }
    
    @IBAction func cancelRecord(_ sender: Any) {
        RTVoiceRecordManager.shareinstance.clearnSetUp()
        deleTeActionBlock?()
    }
    
    
    //
    fileprivate func dealEndRecord() {
        RTVoiceRecordManager.shareinstance.stopRecord()
        stopAnimation()
    }
    
    @objc func handelerLongPress(_ ges:UILongPressGestureRecognizer){
        
        if ges.state == .began {
            self.isrecord = true
            RTVoiceRecordManager.shareinstance.delegate = self
            RTVoiceRecordManager.shareinstance.startRecord(self.filename, recordSuccess: {[weak self]  path in
                self?.stopAnimation()
                self?.audioPath = path
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.recordSuccessBlock?(path)
                }
            })
            startAnimation()
        }
        if ges.state == .changed {
            let location = ges.location(in: self)
            self.showCancelRecordView(self.btnremove.frame.contains(location))
        }
        if ges.state == .ended {
            self.isrecord = false
            let location = ges.location(in: self)
            if self.btnremove.frame.contains(location) {
                self.cancelRecord()
            }else{
                dealEndRecord()
            }
            
        }
        
    }
    func showCancelRecordView(_ indeleteHighligt:Bool)  {
        if indeleteHighligt {
            self.toptipView.alpha = 0
            self.lbltip.isHidden = false
            self.lbltip.text = "cancel_record".localiz()
            self.btnremove.isHighlighted = true
        } else{
            self.toptipView.alpha = 1
            self.lbltip.isHidden = true
            self.lbltip.text = "hold_to_speak".localiz()
            self.btnremove.isHighlighted = false
        }
    }
    func  cancelRecord() {
        RTVoiceRecordManager.shareinstance.delegate = nil
        RTVoiceRecordManager.shareinstance.recordAccBlock = nil
        RTVoiceRecordManager.shareinstance.stopRecord()
        stopAnimation()
        audioPath = ""
        self.showCancelRecordView(false)
    }
    
    func startAnimation() {
        lblsecond.text = "0s"
        self.btnremove.isHidden = false
        self.btnremove.isHighlighted = false
        self.toptipView.isHidden = false
        self.lbltip.isHidden = true
        animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = 0.2
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.repeatCount = Float(Int.max)
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        playimg.layer.add(animation, forKey: "fade")
        let  sizeanimation = CABasicAnimation(keyPath: "bounds.size")
        sizeanimation.fromValue = NSValue(cgSize: CGSize(width: 80, height: 80))
        sizeanimation.toValue = NSValue(cgSize: self.playimg.frame.size)
        sizeanimation.duration = 1.0
        sizeanimation.repeatCount = 1
        playimg.layer.add(sizeanimation, forKey: "Image-expend")
        self.leftview.startAnimating()
        self.rightview.startAnimating()
    }
    
    func stopAnimation() {
        self.lblsecond.text = ""
        self.btnremove.isHighlighted = false
        self.lbltip.isHidden = false
        self.toptipView.isHidden = true
        playimg.layer.removeAllAnimations()
        self.leftview.stopAnimating()
        self.rightview.stopAnimating()
    }
    
    func clearSetting() {
        self.audioPath = ""
        self.isrecord = false
    }
}
extension  UserPublishVoiceRecordView:RTVoiceRecordManagerDelegate {
    //毫秒的
    func millisecondsRecord(_ milliseconds: Int) {
        let secondDurationCount = Double(milliseconds) / 1000.0
        if secondDurationCount < 10 {
            self.lblsecond.text = String.init(format: "%.1fs", secondDurationCount)
        } else {
            self.lblsecond.text = String.init(format: "%.0fs", secondDurationCount)
        }
    }
}
