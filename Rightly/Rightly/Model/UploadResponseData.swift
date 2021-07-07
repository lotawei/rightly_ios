//
//  UploadResponseData.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/24.
//

import Foundation
struct UploadResponseData:Convertible {
    var url:String? = nil
    var previewUrl:String? = nil
    var duration:Double?  = nil
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case previewUrl = "previewUrl"
        case duration = "duration"
    }
}
