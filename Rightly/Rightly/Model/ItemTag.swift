//
//  ItemTag.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
import KakaJSON
class ItemTag:Convertible {
    var isLight : Bool? = false //是否点亮
    var name : String? = "" //标签名称
    var tagId : Int64 = 0 //标签id
    var viewType : ViewType? = .Private
    var isSystem:Bool? = false
    var categoryId:Int? = 0
    var isselected:Bool = false
    var  relationTopic:DiscoverTopicModel?=nil //关联的话题 本地维护的 有个需求 是标签需要关联到话题用于判断点亮标签 的类型限定
    required init() {
    }
}

extension ItemTag:Equatable,Hashable {
    static func == (lhs: ItemTag, rhs: ItemTag) -> Bool {
        return   lhs.tagId == rhs.tagId
    }
    var hashValue: Int {return self.tagId.hashValue}
    func hash(into hasher: inout Hasher) {
        hasher.combine(tagId)
    }
}
struct ItemTagCategory:Convertible {
    var  categoryId:Int64 = 0
    var  name:String? = nil
}
