//
//  SignCountdownManager.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/14.
//

import Foundation
//DispatchSourceTimer 放主线程会有阻塞的情况
class SignCountdownManager: NSObject {
    var cdTime:Double = -1
    let dispatchQuene = DispatchQueue.init(label: "sign manager") //
    private static let staticInstance = SignCountdownManager()
    static func shared() -> SignCountdownManager {
        return staticInstance
    }
    
    private override init() {
        super.init()
    }
    
    /// 开启倒计时
    func dispatchTimer(timeInterval: Double, repeatCount: Int, handler: @escaping (DispatchSourceTimer?, Int) -> Void) {
        if repeatCount <= 0 {
            return
        }
        let timer = DispatchSource.makeTimerSource(flags: [], queue:dispatchQuene)
        var count = repeatCount
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            
            if count <= 0 {
                timer.cancel()
            }
        }
        timer.resume()
    }
}




