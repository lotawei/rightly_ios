//
//  NSDate_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/15.
//

import Foundation

extension Date {
    
    /// 转换时间 yyyy-MM-dd HH:mm:ss
    /// - Parameter dateFormat
    /// - Returns: 转换时间戳
    func conversion(_ dateFormat:String) -> String {
        let dateFormatte = DateFormatter()
        dateFormatte.dateFormat = dateFormat
        dateFormatte.timeStyle = .short
        dateFormatte.dateFormat = dateFormat
        dateFormatte.locale = Locale.init(identifier: "en_US")
        return dateFormatte.string(from: self)
    }
    /// 转换时间 yyyy-MM-dd HH:mm:ss am
    /// - Parameter dateFormat
    /// - Returns: 转换时间戳
    func conversionAmPm(_ dateFormat:String) -> String {
        let dateFormatte = DateFormatter()
        dateFormatte.timeStyle = .short
        dateFormatte.dateFormat = dateFormat
        dateFormatte.locale = Locale.init(identifier: "en_US")
        dateFormatte.amSymbol = "AM".localiz()
        dateFormatte.pmSymbol = "PM".localiz()
        return dateFormatte.string(from: self)
    }
    
    /// 时间格式化
    /// - Parameters:
    ///   - time: <#time description#>
    ///   - format: <#format description#>
    /// - Returns: <#description#>
    static public func formatTimeStamp(time:Int64 ,format:String) -> String {
        var timeInterval = TimeInterval(time)
        timeInterval = timeInterval > maxTimeStamp ? timeInterval / 1000 : timeInterval
        let date = Date.init(timeIntervalSince1970: timeInterval)
        let dateFormatte = DateFormatter()
        dateFormatte.dateFormat = format
        dateFormatte.locale = Locale.init(identifier: "en_US")
        return dateFormatte.string(from: date)
    }
    /// 时间格式化
    /// - Parameters:
    ///   - time: <#time description#>
    ///   - format: <#format description#>
    /// - Returns: <#description#>
    static public func formatdateTimeStamp(time:Int64 ,format:String) -> Date? {
        let dateFormatte = DateFormatter()
        dateFormatte.dateFormat = format
        dateFormatte.locale = Locale.init(identifier: "en_US")
        return dateFormatte.date(from: formatTimeStamp(time: time,format: format))
    }
    
    
    static func  convertTimeSecond(_ timesecond:Int) -> String{
        var    result:String = ""
        var  second = timesecond
        if second < 60 {
            result = String.init(format: "00:%02zd", second)
        }
        else if second >= 60 && timesecond < 3600{
            result = String.init(format: "%02zd:%02zd", second/60,second%60)
        }
        else if second >= 3600 {
            result = String.init(format: "%02zd:%02zd:%02zd", second/3600,second%3600/60,second%60)
        }
        return result
    }
}


