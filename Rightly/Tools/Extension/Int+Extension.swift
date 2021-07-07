//
//  Int+Extension.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/23.
//

import Foundation
extension  Int{
    
    /// 根据总个数 列数 返回行数一般用于计算行
    /// - Parameters:
    ///   - totalcount: <#totalcount description#>
    ///   - col: <#col description#>
    /// - Returns: <#description#>
    static  func   getSection(_ totalcount:Int,_ col:Int) -> Int{
        var   row = 0
        
        if totalcount / col > 0 &&  totalcount % col ==  0 {
            row = totalcount / col
            if row > 0 {
                return row
            }
            
        }
        if  totalcount == 0 {
            return  row
        }
        return    (totalcount + col )/col
        
    }
    //MARK:参与人数显示
    internal func  watchPersonDisplay() -> String{
        if self < 10000 {
            return "\(self)"
        }
        else  {
            let  prex = self/10000
            let  subc = self%10000
            let  dbend = Double(subc)/10000
            var endstr = "\(prex)"
            if dbend > 0 {
                let prixr = Double(prex) + Double(String.init(format: "%.2f", dbend).prefix(3))!
                
                endstr = String.init(format: "%.1f", prixr)  + "万"
            }else{
                endstr = endstr + "万"
            }
            return endstr
        }
    }
    //MARK:参与人数
    internal func  enjoyPeopleDisplay() -> String{
        return self.watchPersonDisplay() + "people join".localiz()
    }
    
    //金币翻译文本对应
    static func  coinDisplay(_ coin:Int64) -> String{
        if coin == 0 {
            return "Free".localiz()
        }else{
            if  coin == 1 {
                return   "\(coin)" + "Coin".localiz()
            }
            else{
                return   "\(coin)" + "Coins".localiz()
            }
        }
    }
}
public extension CGFloat {
     
     static func random(lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}
public extension Int {
     static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
           return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
