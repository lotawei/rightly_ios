//
//  RankHeadView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/28.
//

import Foundation
import Foundation
import UIKit
import Kingfisher
import MZTimerLabel
class RankHeadView:UIView,NibLoadable{
    var topicDetail:DiscoverTopicModel?=nil
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var matchDetailIconBtn: UIButton!
    @IBOutlet weak var deadLineLbl: UILabel!
    @IBOutlet weak var cutDownTipLabel: UILabel!
    private var countDownHourTimerLabel: MZTimerLabel?
    var isaddShadow:Bool = false
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.lblRank.text = "Rank".localiz()
        
    }
    func configDetail(_ topicDetail:DiscoverTopicModel){
        self.topicDetail = topicDetail
        let inbundleimg = UIImage(named:"images")
        if let topicbackImg = topicDetail.banner?.dominFullPath(), !topicbackImg.isEmpty {
            backImgView.kf.setImage(with: URL(string:topicbackImg), placeholder: inbundleimg)
        }else{
            backImgView.image = inbundleimg
        }
        if ( topicDetail.infodescription?.isEmpty  ?? true) {
            matchDetailIconBtn.isHidden = true
        }else{
            matchDetailIconBtn.isHidden = false
        }
    }
    func configTimerCutDown(_ serverCurrentDate:Date)  {
        guard let detail = self.topicDetail else {
            return
        }
        let futureTime = (detail.matchEndAt ?? 0) / 1000
        if futureTime > 0{
            let  plandate =  Date.init(timeIntervalSince1970: TimeInterval( futureTime) )
            let  nowdata = serverCurrentDate
            let  res = plandate.compare(nowdata)
            switch res {
            //已结束了
            case .orderedAscending:
                self.stopCountdown()
                self.deadLineLbl.text = "已结束".localiz()
                self.cutDownTipLabel.text = ""
                break
            case .orderedSame:
                self.deadLineLbl.text = "已结束".localiz()
                break
            case .orderedDescending:
                self.startCountdown(withPlanStartTime:plandate)
                self.cutDownTipLabel.text = "Countdown to the end of the event".localiz()
                break
            }
            
        }else{
            self.deadLineLbl.text = "已结束".localiz()
        }
    }
    
}

extension RankHeadView:MZTimerLabelDelegate{
    // MARK: - 比赛开始倒计时
    fileprivate  func startCountdown(withPlanStartTime planStartTime: Date) {
        stopCountdown()
        countDownHourTimerLabel = MZTimerLabel(label: deadLineLbl, andTimerType: MZTimerLabelTypeTimer)
        countDownHourTimerLabel?.shouldCountBeyondHHLimit = true
        countDownHourTimerLabel?.timeFormat = "HH:mm:ss"
        countDownHourTimerLabel?.delegate = self
        countDownHourTimerLabel?.setCountDownTo(planStartTime)
        countDownHourTimerLabel?.start()
    }
    func stopCountdown() {
        countDownHourTimerLabel?.pause()
        countDownHourTimerLabel?.removeFromSuperview()
        countDownHourTimerLabel?.delegate = nil
        countDownHourTimerLabel = nil
    }
    // MARK: - MZTimerLabelDelegate
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        if timerLabel.tag != 99 {
            stopCountdown()
        }
    }
    
}
