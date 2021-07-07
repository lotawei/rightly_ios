//
//  DisCoverTopicVoiceCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//
import Foundation
import Reusable
import RxSwift
import RxCocoa
class DisCoverTopicVoiceCell: UITableViewCell,NibReusable {
    var   actionDetailMore:((_ item:DiscoverTopicModel)->Void)?=nil
    var  item:DiscoverTopicModel?=nil
    @IBOutlet weak var userEnjoylbl: UILabel!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMatch: UILabel!
    @IBOutlet weak var detaillbl: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    func updateDisPlay(_ item:DiscoverTopicModel)  {
        self.item = item
        lblName.text = "#"+"\(item.name ?? "")"
        let backPlaceImg = UIImage(named:"images", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        let backURL = URL.init(string: (item.banner?.dominFullPath() ?? ""))
        bannerImg.kf.setImage(with: backURL, placeholder: backPlaceImg)
        lblMatch.isHidden = !(item.isMatch ?? false)
        userEnjoylbl.text = item.peopleNum?.enjoyPeopleDisplay()
        self.detaillbl.text = item.simpleDescription
    }
    @IBAction func moreAction(_ sender: Any) {
        guard let topic = self.item else {
            return
        }
        actionDetailMore?(topic)
    }
}
