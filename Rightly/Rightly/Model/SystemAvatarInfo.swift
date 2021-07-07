//
//  UserAvatarInfo.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/18.
//

import Foundation

/// 系统头像
struct SystemAvatarInfos : Convertible {
    var id : String? = nil
    var key : String? = nil
    var values : [SysAvatarInfo]? = nil
}

/// 
struct SysAvatarInfo : Convertible {
    var backgroundUrl : String? = nil
    var id : Int64? = nil
    var url : String? = nil
    var gender:Gender? = nil
}
