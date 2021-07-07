//
//  OwerTaskData.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/8.
//

import Foundation



class ResetApiData<T>: Codable where T:Codable {
    let code : Int?
    let data : T?
    let message : String?
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
    init() {
        code = 0
        data = nil
        message = nil
    }
}
