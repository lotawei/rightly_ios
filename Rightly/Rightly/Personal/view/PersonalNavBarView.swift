//
//  PersonalNavBarView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/12.
//

import Foundation
import UIKit
class PersonalNavBarView:UIView,NibLoadable{
    @IBOutlet weak var btnnotice: UIButton!
    @IBOutlet weak var btnsetting: UIButton!
    @IBOutlet weak var btnfollwed: UIButton!
    @IBOutlet weak var bgypeView: UIView!
    @IBOutlet weak var btnfollower: UIButton!
    @IBOutlet weak var lblbgviewtype: UILabel!
    var settingClickBlock:(()-> Void)?=nil
    var messageClickBlock:(()-> Void)?=nil
    var followedClickBlock:(()-> Void)?=nil
    var followerClickBlock:(()-> Void)?=nil
    var bgViewTypeClickBlock:(()-> Void)?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.shadow(.all)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickBgViewtype(_:)))
        self.bgypeView.addGestureRecognizer(tap)
    }
    func updateUser(userid:Int64?=nil)  {
        btnsetting.setImage(UIImage.init(named: "white_back"), for: .normal)
        if !UserManager.isOwnerMySelf(userid) {
            btnnotice.isHidden = false
            bgypeView.isHidden = true
            btnnotice.setImage(UIImage.init(named: "other..."), for: .normal)
        } else {
            btnnotice.isHidden = true
            bgypeView.isHidden = false
        }
    }
    func updateBgViewType(_ viewtype:ViewType)  {
        self.lblbgviewtype.text = viewtype.descShow()
        
    }
    func updateRenderColor(color:UIColor)  {
        btnsetting.setImage(btnsetting.imageView?.image?.imageWithColor(color: color), for: .normal)
        btnnotice.setImage(btnnotice.imageView?.image?.imageWithColor(color: color), for: .normal)
        btnfollwed.setImage(btnfollwed.imageView?.image?.imageWithColor(color: color), for: .normal)
        btnfollower.setImage(btnfollower.imageView?.image?.imageWithColor(color: color), for: .normal)
    }
   
    
    @objc func clickBgViewtype(_ sender:UITapGestureRecognizer) {
        self.bgViewTypeClickBlock?()
    }
    
    @IBAction func settingaction(_ sender: Any) {
        self.settingClickBlock?()
    }
    
    @IBAction func messageeaction(_ sender: Any) {
        self.messageClickBlock?()
    }
    
    @IBAction func followedaction(_ sender: Any) {
        self.followedClickBlock?()
    }
    
    @IBAction func followeraction(_ sender: Any) {
        self.followerClickBlock?()
    }
}
