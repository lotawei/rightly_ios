//
//  UIColor_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/3.
//

import Foundation

extension UIColor {
    struct ColorStruct {
        var red:CGFloat = 1
        var green:CGFloat = 1
        var blue:CGFloat = 1
        var alpha:CGFloat = 1
    }
    
    convenience init(hex: String, alpha:CGFloat) {
        
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: alpha)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        self.init(r: r, g: g, b: b, a: 1)
    }
    
    convenience init(rgb:CGFloat, a:CGFloat) {
        self.init(r: rgb, g: rgb, b: rgb, a: a)
    }
    
    convenience init(rgb:CGFloat) {
        self.init(r: rgb, g: rgb, b: rgb, a: 1)
    }
}


extension UIColor {
    //返回随机颜色
    open class var randomColor:UIColor{
        get
        {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
