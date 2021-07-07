//
//  UserSwitchSettingCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/15.
//

import Foundation
import Foundation
import Reusable
import RxSwift
import RxCocoa
import NIMSDK

class UserSwitchSettingCell: UITableViewCell,NibReusable {
    var  disposeBag = DisposeBag.init()
    @IBOutlet weak var lbltxt: UILabel!
    @IBOutlet weak var notifyswitch: UISwitch!
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag.init()
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        PushNoticeCenterManager.shared?.imPushOn.asObservable().subscribe(onNext: { [weak self] (ison) in
            guard let `self` = self  else {return }
            DispatchQueue.main.async {
                self.notifyswitch.isOn = ison
            }
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func valueChange(_ sender: UISwitch) {
        if let userid =  UserManager.manager.currentUser?.additionalInfo?.userId {
            if sender.isOn == false {
                UIViewController.getCurrentViewController()?.alterClosePush({(ok) in
                    if ok {
                        PushNoticeCenterManager.shared?.updateImPushEnable("\(userid)", enable:sender.isOn)
                    }else{
                        sender.isOn = true
                    }
                })
            }else {
                PushNoticeCenterManager.shared?.updateImPushEnable("\(userid)", enable:sender.isOn)
            }
            
        }
    }
    
    
}

