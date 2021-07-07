//
//  CountryInfoModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/26.
//

import Foundation
import KakaJSON

class CountryInfoModel : NSObject, Convertible {
    required override init() {
        super.init()
    }
    
    var ID : String?
    var Name : String?  //中文名称
    var AreaCode : String?
    var EnglishName : String?   //英文名称
    
    var areaCodeStr : String {
        get {
            return "+" + (self.AreaCode ?? "")
        }
    }
}


