//
//  MatchTaskCollectionView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
import Kingfisher
import Reusable

class MatchTaskCollectionViewCell: UICollectionViewCell,NibReusable{
    @IBOutlet weak var userimg: UIImageView!
    @IBOutlet weak var backimg: UIImageView!
    @IBOutlet weak var userbirth: UILabel!
    @IBOutlet weak var usernickname: UILabel!
    @IBOutlet weak var userstate: UIView!
    @IBOutlet weak var genderview: UIView!
    @IBOutlet weak var genderimg: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lbldetail: UITextView!
    @IBOutlet weak var taskimage: UIImageView!
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.shadow(type: .all, color: UIColor.black, opactiy: 0.2, shadowSize: 3,radius: 32)
    }
    
    func  updateInfo(_ info:MatchGreeting) {
        self.usernickname.text = info.nickname
        self.genderimg.image = (info.gender == .female)  ? UIImage.init(named: "femaleolayer"):UIImage.init(named: "maleolayer")
        if let birth = info.birthday {
            self.userbirth.text = Date.formatTimeStamp(time:birth , format: "DD-MM/YYYY")
        }
        
        let headPlaceImg = UIImage(named: info.gender?.defHeadName ?? "default_head_image")
        let headURL = URL.init(string: (info.avatar?.dominFullPath() ?? ""))
        userimg.kf.setImage(with: headURL, placeholder: headPlaceImg)
        
        let backPlaceImg = UIImage(named:"images", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        let backURL = URL.init(string: (info.backgroundUrl?.dominFullPath() ?? ""))
        backimg.kf.setImage(with: backURL, placeholder: backPlaceImg)
        
        if let age = info.age {
            self.userbirth.text = "\(age)"
        }
        
        if let city = info.location?.city ,!city.isEmpty{
            self.userbirth.text = (self.userbirth.text ?? "") + "," + city
        }
        self.userstate.isHidden = !(info.isOnline ??  false)
        self.lbldetail.attributedText = info.task?.getTaskDesc()
        self.bottomView.backgroundColor = info.task?.type.tasktypeColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backimg.setRoundCorners([.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 16)
        bottomView.clipsToBounds = true
        self.bottomView.setRoundCorners([.topLeft,.topRight,.bottomRight,.bottomLeft], radius: 16)
    }
}
