//
//  NSObject+ExMethod.swift
//  LiveKit
//
//  Created by 伟龙 on 2020/6/3.
//  Copyright © 2020 dfsx6. All rights reserved.
//

import Foundation
extension NSObject {
    static  func swizzleMethod(for aClass: AnyClass, originalSelector: Selector,swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}
