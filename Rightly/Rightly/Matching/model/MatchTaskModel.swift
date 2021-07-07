//
//  MatchTaskModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
class MatchTaskModel : Codable {

    var matchid : Int64?
    var taskid : Int64?
    var userbirth : String?
    var userbrief : String?
    var usericon : String?
    var userstate : Int?
    enum CodingKeys: String, CodingKey {
        case matchid = "matchid"
        case taskid = "taskid"
        case userbirth = "userbirth"
        case userbrief = "userbrief"
        case usericon = "usericon"
        case userstate = "userstate"
    }
    init() {
        
    }
}



extension  MatchTaskModel {
    
    static func randomSectionModel() -> MatchTaskModel {
        let matchmodel = MatchTaskModel.init()
        matchmodel.userbirth = "Apr,4"
        matchmodel.userstate = 1
        matchmodel.usericon = "https://preview.qiantucdn.com/paixin/91/56/40/87258PICBhemyrRuGC6EG_PIC2018.jpg!qt324new_nowater"
        matchmodel.userbrief = "hi baby dont be shy"
        return matchmodel
    }
    
    
}
