//
//  URLSession+Ex.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/3.
//

import Foundation
import RxSwift
extension HTTPURLResponse {
    //获取服务器时间head里面的时间 国内外可能不一样目前是国内服务器的结果
    func getServerDate() -> Date {
        var  date:Date?=nil
        let dateFormatter = DateFormatter.init()
        if let datestr = self.allHeaderFields["Date"] as? String {
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
            dateFormatter.locale = Locale.init(identifier: "en_US")
            date = dateFormatter.date(from: datestr)
            debugPrint("....")
        }
        return date ?? Date.init()
    }
}
