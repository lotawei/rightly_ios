//
//  NoticeMetionCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//

import Foundation
import Reusable
import RxSwift
import KingfisherWebP
import RxCocoa
class NoticeMetionCell: UITableViewCell,NibReusable {
    var disposebag = DisposeBag.init()
    var  actionFocusBlock:((_ userid:Int64,_ isfocus:Bool)->Void)?=nil
    @IBOutlet weak var iconbtn: UIButton!
    @IBOutlet weak var extenddataView: UIImageView!
    @IBOutlet weak var typedes: UILabel!
    @IBOutlet weak var typeimage: UIImageView!
    @IBOutlet weak var senddtime: UILabel!
    @IBOutlet weak var useriocn: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followbtn: FollowUIButton!
    fileprivate var notifyResult:UserNotifyModelResult?=nil
    override func prepareForReuse() {
        super.prepareForReuse()
        disposebag = DisposeBag.init()
        extenddataView.image = nil
        extenddataView.backgroundColor = .clear
        extenddataView.isHidden = true
        followbtn.isHidden = true
        iconbtn.isHidden = true
        
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpUserhomePage(_:)))
        self.useriocn.addGestureRecognizer(tap)

        let norBgView = UIView.init(frame: CGRect(x: 0, y: 0, width: 86, height: 30))
        norBgView.backgroundColor = .init(hex: "27D3CF")
        norBgView.cornerRadius = 15
        
        let selBgView = UIView.init(frame: CGRect(x: 0, y: 0, width: 86, height: 30))
        selBgView.backgroundColor = .white
        selBgView.borderWidth = 1
        selBgView.borderColor = .init(hex: "24D3D0")
        selBgView.cornerRadius = 15
        
        let norBgImage = norBgView.snapViewImage()
        let selBgImage = selBgView.snapViewImage()
        
//        followbtn.setBackgroundImage(norBgImage, for: .normal)
//        followbtn.setBackgroundImage(norBgImage, for: .highlighted)
//        followbtn.setBackgroundImage(selBgImage, for: .selected)
//        followbtn.setTitle("follow_btn".localiz(), for: .normal)
//        followbtn.setTitle("follow_btn".localiz(), for: .highlighted)
//        followbtn.setTitle("following_btn".localiz(), for: .selected)
//        followbtn.setTitleColor(.white, for: .normal)
//        followbtn.setTitleColor(.white, for: .highlighted)
//        followbtn.setTitleColor(.init(hex: "24D3D0"), for: .selected)
//        followbtn.setImage(UIImage.init(named: "message_follow_add_icon"), for: .normal)
//        followbtn.setImage(UIImage.init(named: "message_follow_add_icon"), for: .highlighted)
//        followbtn.setImage(UIImage.init(), for: .selected)
//        followbtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        followbtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -4, bottom: 0, right: 0)
    }
    func updateInfo(_ result:UserNotifyModelResult)  {
        self.notifyResult = result
        let inbundleimg = UIImage(named:"userpersonal", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        if let ownerAvatarUrl = result.triggerUser?.avatar?.dominFullPath(), !ownerAvatarUrl.isEmpty {
            useriocn.kf.setImage(with: URL(string:ownerAvatarUrl), placeholder: inbundleimg)
        }else{
            useriocn.image = inbundleimg
        }
        username.text = result.triggerUser?.nickname
        senddtime.text = String.updateTimeToCurrennTime(timeStamp: Double(result.createdAt ?? 0))
        if  result.notificationType == .focus {
            typeimage.image = UIImage.init(named: "关注")
            followbtn.isHidden = false
            followbtn.isSelected = result.triggerUser?.isfocused ?? false
        }
        else if result.notificationType == .like{
           
            typeimage.image = UIImage.init(named: "like_selected")
            followbtn.isHidden = true
        }
        typedes.text =  result.content
        
        resourceView(extradata:result.extraData)
    }
    @objc func jumpUserhomePage(_ sender: Any) {
        
        guard let userid = self.notifyResult?.triggerUser?.userId else {
            self.getCurrentViewController()?.toastTip("This account is deleted".localiz())
            return
        }
        self.jumpUSer(userid: userid)
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        guard let userid = notifyResult?.triggerUser?.userId else {
            return
        }
        self.actionFocusBlock?(userid,sender.isSelected)
    }
    fileprivate  func resourceView(extradata:UserNotifyModelExtraData?){
        
            if let tasktype = extradata?.taskType  {
                extenddataView.clipsToBounds = true
                extenddataView.layer.cornerRadius = 6
                
                switch tasktype {
                case  .photo:
                    extenddataView.isHidden = false
                    extenddataView.backgroundColor = UIColor.clear
                    if let url = extradata?.resources?.first?.url {
                        extenddataView.kf.setImage(
                                   with:URL(string:url.dominFullPath()),
                                   placeholder: placehodlerImg)
                    }
                    iconbtn.isHidden = true
                case .video:
                    extenddataView.isHidden = false
                    extenddataView.backgroundColor = UIColor.clear
                    if let url = extradata?.resources?.first?.previewUrl {
                        extenddataView.kf.setImage(
                                        with:URL(string:url.dominFullPath()),
                                        placeholder: placehodlerImg,options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)])
                    }
                    iconbtn.isHidden = false
                    iconbtn.setImage(UIImage.init(named: "playVideo"), for: .normal)
                    
                case .voice:
                    extenddataView.isHidden = false
                    iconbtn.isHidden = false
                    extenddataView.image = nil
                    extenddataView.backgroundColor = TaskType.voice.taskNewVersionColor()
                    iconbtn.setImage(UIImage.init(named: "notice_white_voice")?.withRenderingMode(.alwaysOriginal), for: .normal)
                default:
                    break
                }
            }
    }
    
}
