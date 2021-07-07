//
//  VoiceRecordView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/10.
//

import Foundation
class VoiceRecordView: UIView,NibLoadable{
    var  filename:String = ""
    var  recordSuccessBlock:RecordAccSuccessBlock?=nil
    var  maxTime:TimeInterval = 30
    @IBOutlet weak var backshapeAnimationView: UIImageView!
    @IBOutlet weak var pressges: UILongPressGestureRecognizer!
    @IBOutlet weak var playimg: UIImageView!
    var  animation = CABasicAnimation.init()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backshapeAnimationView.isHidden = false
        self.pressges.minimumPressDuration = 0.5
        self.pressges.addTarget(self, action: #selector(handelerLongPress(_:)))
    }
    @objc func handelerLongPress(_ ges:UILongPressGestureRecognizer){
        if ges.state == .began {
            RTVoiceRecordManager.shareinstance.startRecord(self.filename, recordSuccess: {[weak self]  path in
                self?.recordSuccessBlock?(path)
                
            })
            startAnimation(maxTime)
        }
        if ges.state == .ended {
            
            RTVoiceRecordManager.shareinstance.stopRecord()
            stopAnimation()
        }
        
    }
    func startAnimation(_ time:TimeInterval){
        self.backshapeAnimationView.isHidden = false
        animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber.init(value: Double.pi*2.0)
        animation.duration = time
        animation.isCumulative = true
        animation.repeatCount = Float(Int.max)
        backshapeAnimationView.layer.add(animation, forKey: "animation")
    }
    func stopAnimation(){
        self.backshapeAnimationView.isHidden = true
        backshapeAnimationView.layer.removeAllAnimations()
    }
}

