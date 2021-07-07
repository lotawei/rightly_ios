//
//  File.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/7.
//

import Foundation
import  SnapKit
import  RxSwift
import RxCocoa
//let  reddotLocalData = "reddotLocalData"
////红点入口类型
//enum  TipMessageEnter:String,Codable {
//    case tabbarIndex0 = "tabbarIndex0", //第一个tabbar的
//         tabbarIndex1 = "tabbarIndex1", //第二个首页的
//         tabbarIndex2 = "tabbarIndex2", //第三个个人的
//         messageRightIcon = "messageRightIcon", //第四个右上角消息的 系统消息 点赞 关注
//         greetingAction = "greetingAction" //招呼的
//}
//fileprivate let  saveredInfoPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/reddotmanageer/reddotInfoDatas")
//struct  TipMessageData:Codable {
//    var  enterType:TipMessageEnter
//    var  caculatorCount:Int
//    enum CodingKeys: String, CodingKey {
//        case enterType
//        case caculatorCount
//    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(enterType, forKey: .enterType)
//        try container.encode(caculatorCount, forKey: .caculatorCount)
//
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        enterType = try container.decode(TipMessageEnter.self, forKey: .enterType)
//        caculatorCount = try container.decode(Int.self, forKey: .caculatorCount)
//    }
//}
//struct RedDotInfo:Codable {
//    var redDotdatas: [TipMessageData] = []
//    var  userid:Int64
//    enum CodingKeys: String, CodingKey {
//        case redDotdatas
//        case userid
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(redDotdatas, forKey: .redDotdatas)
//        try container.encode(userid, forKey: .userid)
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        userid = try container.decode(Int64.self, forKey: .userid)
//        redDotdatas = try container.decode([TipMessageData].self, forKey: .redDotdatas)
//    }
//}
//struct UserDotInfoData:Codable {
//    var  relationInfos:[RedDotInfo]
//    enum CodingKeys: String, CodingKey {
//        case relationInfos
//    }
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(relationInfos, forKey: .relationInfos)
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        relationInfos = try container.decode([RedDotInfo].self, forKey: .relationInfos)
//    }
//}
let systemKey = "systemNotice_"
class UserRedDotRecordManager:NSObject{
    @objc  static  var shared = UserRedDotRecordManager()
    //    @objc var newmessagedeleteAction:((_ enter:TipMessageEnter) -> Void)?=nil
    var  systemPageUnreadCount:BehaviorRelay<Int> =  BehaviorRelay<Int>.init(value: 0)
    override init() {
        super.init()
        guard let userId = UserManager.manager.currentUser?.additionalInfo?.userId else {
            return
        }
        let unreadKey = systemKey + String(userId)
        self.systemPageUnreadCount.accept(UserDefaults.standard.integer(forKey: unreadKey))
    }
    
    func checksystemUnread() {
        guard let userid = UserManager.manager.currentUser?.additionalInfo?.userId else {
            return
        }
        let key = systemKey + "\(userid)"
        UserProVider.init().userUnreadNum(self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let rednumber = res.modeDataKJTypeSelf(typeSelf: UnreadModel.self)?.total {
                UserDefaults.standard.setValue(rednumber, forKey: key)
                if let rednumber = UserDefaults.standard.object(forKey: key) as? Int {
                    self.systemPageUnreadCount.accept(rednumber)
                }
            }
        },onError: { (err) in
            debugPrint("-----")
        }).disposed(by: self.rx.disposeBag)
    }
    
}
extension  UIView{
    
    @objc func showTipForCount(_ count:Int) {
        
        let  aview = self.viewWithTag(101)
        if  aview != nil{
            aview?.removeFromSuperview()
        }
        
        let  radiuview =  UILabel.init()
        radiuview.text = String.init(format: "%d", count)
        radiuview.textColor = UIColor.white
        radiuview.textAlignment = .center
        radiuview.tag = 101
        radiuview.font = UIFont.systemFont(ofSize: 8)
        radiuview.backgroundColor = UIColor.red
        radiuview.layer.cornerRadius = 8
        
        radiuview.clipsToBounds = true
        self.addSubview(radiuview)
        radiuview.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.top.equalTo(self)
            make.right.equalTo(self).offset(16)
        }
    }
    
    
    
    @objc func  removeTip(){
        let  aview = self.viewWithTag(101)
        if  aview != nil{
            aview?.removeFromSuperview()
        }
    }
    @objc func worknewTip() {
        let  aview = self.viewWithTag(102)
        if  aview != nil{
            aview?.removeFromSuperview()
        }
        let  radiuview =  UILabel.init()
        radiuview.tag = 102
        radiuview.text = ""
        radiuview.textColor = UIColor.white
        radiuview.textAlignment = .center
        radiuview.backgroundColor = UIColor.red
        radiuview.layer.cornerRadius = 5
        radiuview.clipsToBounds = true
        self.addSubview(radiuview)
        radiuview.snp.makeConstraints { (make) in
            make.width.height.equalTo(10)
            make.top.equalTo(self)
            make.right.equalTo(self).offset(10)
        }
    }
    @objc func removeworknewTip(){
        let  aview = self.viewWithTag(102)
        if  aview != nil{
            aview?.removeFromSuperview()
        }
    }
}
