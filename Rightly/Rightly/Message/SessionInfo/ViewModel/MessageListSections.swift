//
//  MessageListSections.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/24.
//

import Foundation
import RxDataSources
enum MessageItem {
    case taskItem(_ task:MatchGreeting)
    case messageItem(_ message:MessageViewModel)
}
struct MessageListSections {
    var items:[MessageItem]
    var header:TimeInterval = 0
}
extension MessageListSections:SectionModelType{
    typealias Item = MessageItem
    init(original: MessageListSections, items: [MessageItem]) {
        self = original
        self.items = items
    }
}
