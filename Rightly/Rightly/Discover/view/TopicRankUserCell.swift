//
//  TopicRankUserCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/28.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
class TopicRankUserCell: UITableViewCell,NibReusable {
    @IBOutlet weak var usericonImage: UIImageView!
    @IBOutlet weak var indexLbl: UIButton!
    @IBOutlet weak var awaradsLbl: UILabel!
    @IBOutlet weak var userNickLbl: UILabel!
    @IBOutlet weak var rankHotLbl: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    func updateRankInfo(_ rankInfo:TopicRankModel,_ index:Int){
        self.indexLbl.setTitle("No.\(index + 1)", for: .normal)
        self.rankHotLbl.text = "\(rankInfo.hotNum ?? 0)"
        let inbundleimg = UIImage(named:"images")
        if let avatarUrl = rankInfo.user?.avatar?.dominFullPath(), !avatarUrl.isEmpty {
            usericonImage.kf.setImage(with: URL(string:avatarUrl), placeholder: inbundleimg)
        }else{
            usericonImage.image = inbundleimg
        }
        self.userNickLbl.text = rankInfo.user?.nickname
        self.awaradsLbl.text = "awards".localiz() + "\(rankInfo.awarwdsCount ?? 0)"
    }
}

