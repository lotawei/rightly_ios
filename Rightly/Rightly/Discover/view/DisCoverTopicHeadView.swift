//
//  DisCoverTopicHeadView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//

import Foundation
import UIKit
import Kingfisher
class DisCoverTopicHeadView:UIView,NibLoadable{
   
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backImgView: UIImageView!
    
    
    @IBOutlet weak var joinMatchBtn: UIButton!
    @IBOutlet weak var isjoinedImage: UIImageView!
    @IBOutlet weak var matchBodyView: UIView!
    
    
    @IBOutlet weak var matchRankBtn: UIButton!
    @IBOutlet weak var matchVoteBtn: UIButton!
    @IBOutlet weak var matchDetailIconBtn: UIButton!
    @IBOutlet weak var lblmatch: UILabel!
    @IBOutlet weak var lblmatchbrief: UILabel!
    var  info:DiscoverTopicModel?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    func updateTopicInfo(_ info:DiscoverTopicModel){
        self.info = info
        let inbundleimg = UIImage(named:"images")
        if let topicbackImg = info.banner?.dominFullPath(), !topicbackImg.isEmpty {
            backImgView.kf.setImage(with: URL(string:topicbackImg), placeholder: inbundleimg)
        }else{
            backImgView.image = inbundleimg
        }
        if let infodesc =  info.infodescription, !infodesc.isEmpty{
            self.matchDetailIconBtn.isHidden = false
        }else{
            self.matchDetailIconBtn.isHidden = true
        }
        if let  matchName = info.name {
            self.lblmatch.text = "#\(matchName)"
        }
        self.lblmatchbrief.text = info.simpleDescription
        self.isjoinedImage.isHidden = !(info.isJoin ?? false)
        if (info.isMatch ?? false) {
//            self.matchVoteBtn.isHidden = false
            self.matchRankBtn.isHidden = false
//            if info.isMatchEnd ?? false {
//                self.matchVoteBtn.isHidden = true
//            }else{
//                self.matchVoteBtn.isHidden = false
//            }
        }else{
//            self.matchVoteBtn.isHidden = true
            self.matchRankBtn.isHidden = true
        }
    }
    @IBAction func jumpTopicInfoDetail(_ sender: Any) {
        if let topicDes = info?.infodescription, !topicDes.isEmpty {
            let  des = topicDes.replacingOccurrences(of: "#{storageBaseUrl}", with: "\(SystemManager.shared.storage?.storageBaseUrl ?? DominUrl)")
            GlobalRouter.shared.jumpByUrl(html: des, title: info?.name ?? "")
        }
    }
}
