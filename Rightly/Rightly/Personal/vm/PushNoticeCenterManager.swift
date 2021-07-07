//
//  PushNoticeCenterManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/17.
//

import Foundation
import NIMSDK
import RxSwift
import RxCocoa
class PushNoticeCenterManager {
    fileprivate  let ImNoticeOn =  "ImNoticeOn_"
    static var  shared:PushNoticeCenterManager? = nil
    var  imPushOn:BehaviorRelay<Bool> = BehaviorRelay.init(value:false)
    init(_ userId:String) {
        self.imPushOn.accept(self.userEnablePush(userId))
    }
    func userEnablePush(_ userId:String) -> Bool {
       return (UserDefaults.standard.object(forKey: "\(ImNoticeOn)\(userId)") as? Bool ) ?? true
    }
    func updateImPushEnable(_ userId:String,enable:Bool) {
        var setting = NIMSDK.shared().apnsManager.currentSetting()
        setting?.noDisturbing = enable
        if let newSetting = setting {
            NIMSDK.shared().apnsManager.updateApnsSetting(newSetting) {[weak self] (error) in
                guard let `self` = self  else {return }
                  debugPrint("update im ---- \(error)")
                UserDefaults.standard.setValue(enable, forKey:"\(self.ImNoticeOn)\(userId)")
                UserDefaults.standard.synchronize()
                self.imPushOn.accept(self.userEnablePush(userId))
            }
        
        }

    }
}
