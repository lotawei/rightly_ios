//
//  File.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/25.
//

import Foundation
/// 将encoder 转为字典 则 实现codable协议的
/// - Throws: <#description#>
/// - Returns: <#description#>
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
