//
//  SystemNoticeCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//


import Reusable
import RxSwift
import RxCocoa
class SystemNoticeCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var imgicon: UIImageView!
    var  result:UserNotifyModelResult?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        content.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpDoIt))
        content.addGestureRecognizer(tap)
    }
    func updateInfo(_ result:UserNotifyModelResult)  {
        self.result = result
        guard let  tipValue = result.content else {
            return
        }
            
        
        let  mutableStr = NSMutableAttributedString.init(string: "Welcome to the Right.ly community! Finish the chat up task and start chatting with new friends!".localiz(),attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.black])
        let  doit =  NSAttributedString.init(string: "Do it Now",attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.init(hex: "24D3D0")])
        mutableStr.append(doit)
        
        self.content.attributedText = mutableStr
    }
    
    @objc func jumpDoIt(){
        guard let  res = self.result ,let uerid = res.triggerUserId ?? res.triggerUser?.userId ?? res.userId else {
            return
        }
        GlobalRouter.shared.dotaskUser(uerid)
    }
    
}

