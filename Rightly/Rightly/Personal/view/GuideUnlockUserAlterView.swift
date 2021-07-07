//
//  GuideUnlockUserAlterView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/20.
//
import Foundation
import Kingfisher
import Reusable

class GuideUnlockUserAlterView: UIView,NibLoadable{
    @IBOutlet weak var tiplbl: UITextView!
    fileprivate  var  info:UserAdditionalInfo?=nil
    @IBOutlet weak var backimg: UIImageView!
    @IBOutlet weak var displayLbl: UILabel!
    @IBOutlet weak var usernickname: UILabel!
    @IBOutlet weak var visualView: UIView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.shadow(type: .all, color: UIColor.black, opactiy: 0.2, shadowSize: 3,radius: 32)

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpUserhomePage(_:)))
        self.visualView.addGestureRecognizer(tap)
        self.visualView.isUserInteractionEnabled = true
    }
    func  updateInfo(_ info:UserAdditionalInfo) {
        self.info = info
        if let vtype =  info.bgViewType{
            switch vtype {
            case .Private:
                self.visualView.alpha = 0.97
            default:
                self.visualView.alpha = 0.1
            }
        }
        if  (info.isUnlock ?? false) {
            self.visualView.alpha = 0.1
        }
        self.usernickname.text = info.nickname
//        if let birth = info.birthday {
//            self.displayLbl.text = Date.formatTimeStamp(time:birth , format: "DD-MM/YYYY")
//        }
        let headPlaceImg = UIImage(named: info.gender?.defHeadName ?? "default_head_image")
        let headURL = URL.init(string: (info.avatar?.dominFullPath() ?? ""))
        let backPlaceImg = UIImage(named:"meizi", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        let backURL = URL.init(string: (info.backgroundUrl?.dominFullPath() ?? ""))
        backimg.kf.setImage(with: backURL, placeholder: backPlaceImg)
        if let gender = info.gender {
            self.displayLbl.text = "\(gender.desGender)"
        }
        if let age = info.age {
            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + "\(age)"
        }
        if let city = info.address ,!city.isEmpty{
            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + city
        }
        self.tiplbl.text  = "Unlock Success!,enjoy seeing his homepage".localiz()
        
    }
    @objc func jumpUserhomePage(_ sender:UITapGestureRecognizer){
        guard let usid = info?.userId else {
            return
        }
        if !UserManager.isOwnerMySelf(usid) {
            self.jumpUSer(userid: usid)
        }    }
   
    @IBAction func seeHomepage(_ sender: Any) {
       
        guard let usid = info?.userId else {
            return
        }
        
        if !UserManager.isOwnerMySelf(usid) {
            GlobalRouter.shared.jumpUserHomePage(userid: usid)
        }
        self.removeFromWindow()
    }
    
    
}
