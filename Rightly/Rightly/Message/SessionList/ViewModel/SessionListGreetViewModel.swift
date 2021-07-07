//
//  SessionListGreetViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import Foundation
import RxCocoa


class SessionListGreetViewModel:NSObject {
    let unreadCount:BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
}
