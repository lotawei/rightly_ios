//
//  DynamicDetailModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/31.
//

import Foundation
import KakaJSON

class DynamicDetailModel: Convertible {
    let topicId:String = "" //话题id
    let type:TaskType = .noLimit //#类型 0/1/2/3/4 不限/普通文本/语音/图片/视频
    let name:String? = nil
    let simpleDescription:String = "" //简介
    var peopleNum:Int = 0  //参加人数
    var lastMonthHotNum:Int = 0  //最近热度
    var hotNum:Int = 0  //总热度
    var recommendNum:Int = 0  //推荐排序号
    let banner:String = "" //图片URL
    let matchStartAt:TimeInterval = 0 //比赛开始时间
    let matchEndAt:TimeInterval = 0 //比赛结束时间
    let isMatch:Bool = false  //是否为比赛话题
    let createdAt:TimeInterval = 0
    let updatedAt:TimeInterval = 0
    let repeatedly:Bool = false //是否可以多次参加，true：可以 false：不能
    let isJoin:Bool = false //是否已参加活动，true：参加 false：未参加

    required init() {
    }
}
