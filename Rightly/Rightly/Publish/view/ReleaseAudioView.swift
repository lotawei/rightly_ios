//
//  ReleaseAudioView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/24.
//

import Foundation
import AVFoundation
import MBProgressHUD
class ReleaseAudioView: UIView,NibLoadable {
    var audiopath:String = "" {
        didSet {
        }
    }
    @IBOutlet weak var audiomaxwidth: NSLayoutConstraint!
    @IBOutlet weak var widthline: UIImageView!
    @IBOutlet weak var lblduration: UILabel!
    @IBOutlet weak var btnplayer: UIButton!
    override  func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    @IBAction func playAction(_ sender: UIButton) {
        if (RTVoiceRecordManager.shareinstance.player?.isPlaying   ?? false ) {
            sender.isSelected = false
            RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        }else{
            sender.isSelected = true
            RTVoiceRecordManager.shareinstance.startPlayerAudio(audiopath: self.audiopath, finishBlock: { _ in
                sender.isSelected = false
            })
                
        }
    }
 
    
    /// <#Description#>
    /// - Returns: 返回 -----的长度，和时长
    func layoutReleaseAudioView(_ duration:Int? = nil) -> (CGFloat,Int) {
        var  alignDuration:Int = 0
        if  let dra = duration {
            alignDuration = dra
        }else{
            let  localduration = RTVoiceRecordManager.getAudioduration(urlpath: audiopath)
            alignDuration = localduration
        }
        let  diplayDuration:Double = Double(alignDuration) / 1000.0
        self.lblduration.text = String.init(format: "%.0f`", diplayDuration)
        let  maxduration = RTVoiceRecordManager.shareinstance.maxTimeAllow
        let  minwidth:Double = 20
        let  maxwidth:Double = 215
        var scaleprogress = 1.0
        var  lenth:Double = 0
        if diplayDuration > 0  {
            scaleprogress = Double(diplayDuration) / maxduration
            scaleprogress =  scaleprogress >= 1 ? 1.0:scaleprogress
        }else{
            scaleprogress = 0.1
        }
        lenth = (maxwidth * scaleprogress )
        lenth = lenth > minwidth ?  lenth:minwidth
        self.audiomaxwidth.constant = CGFloat(lenth)
        
        return (CGFloat(lenth),alignDuration)
    }
}
