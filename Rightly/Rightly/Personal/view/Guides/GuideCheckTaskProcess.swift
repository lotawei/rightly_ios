////
////  GuideCheckTaskProcess.swift
////  Rightly
////
////  Created by lejing_lotawei on 2021/5/6.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
///// 引导任务检查
//class  GuideCheckTaskProcess:NSObject{
//    static var shared:GuideCheckTaskProcess =  GuideCheckTaskProcess.init()
//    var  maxcount = 5
//    var  timeCount:Int = 0
//    var  timer:Timer?
//    var  enterGuideBlock:((_ step:Int)->Void)?=nil
//  
//    /// 5秒未收到相应的事件 则进入引导流程
//    /// - Parameter : <# description#>
//    func enterGuideCheckProcess(_ enterlastGuide:@escaping ((_ step:Int)->Void))  {
//        self.invalidCheck()
//        self.enterGuideBlock = enterlastGuide
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(guideCheckProcess), userInfo: nil, repeats: true)
//    }
//    @objc func guideCheckProcess(){
////        if GuideCheckTaskProcess.shared.timeCount == maxcount {
////            guard let currentvc = UIViewController.getCurrentViewController() as? MatchingViewController else  {
////                self.invalidCheck()
////                return
////            }
////            self.enterGuideBlock?(GuideConfig.checkStep())
////            self.invalidCheck()
////            return
////        }
////        else{
////            
////            GuideCheckTaskProcess.shared.timeCount = GuideCheckTaskProcess.shared.timeCount + 1
////            debugPrint("---------- pppp  \(self.timeCount)")
////        }
//    }
//   public func invalidCheck(){
//        timer?.invalidate()
//        timeCount = 0
//        enterGuideBlock = nil
//    }
//    public func pauseGuideCheck(){
//        timer?.fireDate = Date.distantFuture
//        timeCount = 0
//    }
//    public func resumeGuideCheck(){
//        timer?.fireDate = Date.init()
//        timeCount = 0
//    }
//    
//}
