//
//  UIScreen+Ex.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/25.
//

import Foundation
extension UIScreen {
    static func  safeInsetTop() -> CGFloat {
        if #available(iOS 11.0, *) {
            let topInset = keyWindow?.safeAreaInsets.top
            return topInset ??   0
        }
        return 0
    }
}
