//
//  HDPrint.swift
//  
//
//  Created by 伟龙 on 2020/3/12.
//  Copyright © 2020 lotawei. All rights reserved.
//

import Foundation
func RTPrint<N>(message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
    
    #if DEBUG // 若是Debug模式下，则打印
    
    print("\(fileName as NSString)\n方法:\(methodName)\n行号:\(lineNumber)\n打印信息\(message)");
    #endif
}
