//
//  RTViewModelType.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/16.
//

import Foundation
protocol RTViewModelType {
    associatedtype Input
    associatedtype Output
    var input:Input {get set}
    var output:Output {get set}
}
