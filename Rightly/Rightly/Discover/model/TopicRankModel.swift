//
//  TopicRankModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/28.
//

import Foundation
import RxSwift
import RxDataSources
struct TopicRankModel:Convertible {
        var greetingId : Int64? = nil
        var hotNum : Int? = nil
        var isLike : Bool? = nil
        var resourceList : [GreetingResourceList]? = nil
        var taskType : TaskType? = nil
        var user : UserAdditionalInfo? = nil
        var userId : Int64? = nil
        var  awarwdsCount:Int64? = nil
}

///rank
enum TopicRankItem {
    case rankUserItem(_ task:TopicRankModel) //我打招呼的列表
    case emptyItem
}

struct TopicRankListSection {
    var items:[TopicRankItem]
    var header:String = ""
}

extension  TopicRankListSection:SectionModelType{
    typealias Item = TopicRankItem
    init(original: TopicRankListSection, items: [TopicRankItem]) {
        self = original
        self.items = items
    }
}
