//
//  MessageGreetingViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import Foundation
import NIMSDK

class MessageGreetingViewModel: MessageViewModel {
    var greetViewModel:GreetInfoGreetViewModel? = nil

    init(_ message: NIMMessage, greetData:Dictionary<String, Any>) {
        super.init(message)
        
        if self.createType == .me {
            self.cellHeight = 112.0
        } else if self.createType == .other {
            self.cellHeight = 140.0
        }
        
        self.messageType = .greeting
        self.greetViewModel = GreetInfoGreetViewModel.init(jsonData: greetData)
//        self.setupTime((self.greetViewModel?.creatTimestamp ?? 0) - 130000)
    }
}

