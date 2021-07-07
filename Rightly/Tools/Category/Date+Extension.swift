//
//  Date+Extension.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/17.
//

import Foundation
extension Formatter {
    static let date = DateFormatter()
}
extension Date {
    var europeanFormattedEn_US : String {
        Formatter.date.calendar = Calendar(identifier: .iso8601)
        Formatter.date.locale   = Locale(identifier: "en_US_POSIX")
        Formatter.date.timeZone = .current
        Formatter.date.dateFormat = "dd/M/yyyy, H:mm"
        return Formatter.date.string(from: self)
    }
}
extension String {
   var date: Date? {
       return Formatter.date.date(from: self)
   }
   func dateFormatted(with dateFormat: String = "dd/M/yyyy, H:mm", calendar: Calendar = Calendar(identifier: .iso8601), defaultDate: Date? = nil, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = .current) -> Date? {
       Formatter.date.calendar = calendar
       Formatter.date.defaultDate = defaultDate ?? calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
       Formatter.date.locale = locale
       Formatter.date.timeZone = timeZone
       Formatter.date.dateFormat = dateFormat
       return Formatter.date.date(from: self)
   }
}
