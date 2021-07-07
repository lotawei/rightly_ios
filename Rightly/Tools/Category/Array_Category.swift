//
//  Array_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/8.
//

import Foundation


extension Array {
    /// 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
