//
//  MessageTaskViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import Foundation
import NIMSDK

class MessageTaskViewModel: MessageViewModel {
    var greetViewModel:GreetInfoGreetViewModel?

    init(_ message: NIMMessage, greetData:Dictionary<String, Any>) {
        super.init(message)
        
        if self.createType == .me {
            self.cellHeight = 168.0
        } else if self.createType == .other {
            self.cellHeight = 168.0
        }
        
        self.messageType = .task
        self.greetViewModel = GreetInfoGreetViewModel.init(jsonData: greetData)
//        self.setupTime((self.greetViewModel?.creatTimestamp ?? 0) - 130000)
    }
}

