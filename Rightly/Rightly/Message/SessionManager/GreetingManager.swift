//
//  GreetingManager.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/7.
//

import UIKit
import RxSwift
import RxCocoa

class GreetingManager {
    let disposeBag = DisposeBag()
    
    var greetingUnreadCount:BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
    
    private static let staticInstance = GreetingManager()
    static func shared() -> GreetingManager {
        return staticInstance
    }
    
    init() {
        guard let userId = UserManager.manager.currentUser?.additionalInfo?.userId else {
            return
        }
        
        let unreadKey = "unread_greeting_" + String(userId)
        self.greetingUnreadCount.accept(UserDefaults.standard.integer(forKey: unreadKey))
    }
    
    func resetGreetingCount() {
        guard let userId = UserManager.manager.currentUser?.additionalInfo?.userId else {
            return
        }
        
        let unreadKey = "unread_greeting_" + String(userId)
        MessageTaskGreetProvider().greetingUnreadNum(disposeBag)
            .subscribe(onNext:{[weak self] (resultData) in
                guard let `self` = self else {return}
                let unCount = resultData.data as? Int ?? 0
                self.greetingUnreadCount.accept(unCount)
                UserDefaults.standard.setValue(unCount, forKey: unreadKey)
            }, onError: { (error) in
                debugPrint(error)
            }).disposed(by: disposeBag)
    }
    
    func updateNumber(_ number:Int) {
        var resultCount = self.greetingUnreadCount.value + number
        if resultCount < 0 {
            resultCount = 0
        }
        
        self.greetingUnreadCount.accept(resultCount)
    }
}
