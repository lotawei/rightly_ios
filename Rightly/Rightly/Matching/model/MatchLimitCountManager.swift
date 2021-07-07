//
//  MatchLimitCountManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//

import Foundation
import RxSwift
import RxCocoa
enum ReduceMatchResult:Int{
    case reducesuccess = 1,//扣除成功
         reducefailed = 0, //扣除失败 网络不好等
         reducenomatch = -1 //没有次数了
    
}
class MatchLimitCountManager: NSObject {
    static let shared:MatchLimitCountManager =  MatchLimitCountManager.init()
    let matchLimitAlterview:MatchCountLimitAlterView?=MatchCountLimitAlterView.loadNibView()
    fileprivate var limitinfo:PublishSubject<MatchLimitInfo> = PublishSubject.init()
    var viewModel: MatchGreetingVMModel  = MatchGreetingVMModel()
    var  unlockUser:PublishRelay<Int64> = PublishRelay.init()
    var currentGreeting:BehaviorRelay<MatchGreeting?> =  BehaviorRelay.init(value: nil)
    var  shoudldCheck:Bool = true
    var  reduceCount:BehaviorRelay<(Int64,Int64)> = BehaviorRelay.init(value: (0,0))
    func firstRefreshLimit(_ andMatch:Bool = true)  {
        self.viewModel.output.startAniation.accept(true)
        MatchTaskGreetingProvider.init().matchLimitCount(self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            //            GuideCheckTaskProcess.shared.resumeGuideCheck()
            guard let `self` = self  else {return }
            self.viewModel.output.startAniation.accept(false)
            if let info = res.modeDataKJTypeSelf(typeSelf: MatchLimitInfo.self) {
                if info.surplusNum <= 0  {
                    self.limitinfo.onNext(info)
                    self.reduceCount.accept((info.surplusNum < 0 ? 0:info.surplusNum,info.sumNum))
                    self.viewModel.input.requestCommand.onNext({}())
                    self.showRunoutTimesView()
                } else{
                    if andMatch {
                        self.viewModel.input.requestCommand.onNext({}())
                    }
                    self.limitinfo.onNext(info)
                    self.reduceCount.accept((info.surplusNum < 0 ? 0:info.surplusNum,info.sumNum))
                }
            }
        },onError: { (err) in
            self.getCurrentViewController()?.toastTip("NetWork Failed".localiz())
            self.viewModel.output.emptyDataShow.onNext(true)
        }).disposed(by: self.rx.disposeBag)
    }
    //
    /// 扣除匹配次数
    func reduceMatchCount(_ reduceSuccess:@escaping((_ success:ReduceMatchResult) -> Void)) {
        guard let uid = UserManager.manager.currentUser?.additionalInfo?.userId else {
            reduceSuccess(.reducefailed)
            return
        }
        if self.reduceCount.value.0 > 0 {
            MatchTaskGreetingProvider.init().matchReduceCount(matchingUerId: uid, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let lastCount = res.data as? Int {
                                        var  newinfo = self.reduceCount.value
                                        newinfo.0 =   Int64((lastCount ?? 0))
                                        self.reduceCount.accept(newinfo)
                                        reduceSuccess(.reducesuccess)
                }
//                switch res {
//                case .success(let lastCount):
//                    var  newinfo = self.reduceCount.value
//                    newinfo.0 =   Int64((lastCount ?? 0))
//                    self.reduceCount.accept(newinfo)
//                    reduceSuccess(.reducesuccess)
//                case .failed(_):
//                    reduceSuccess(.reducefailed)
//                }
            },onError: { (err) in
                reduceSuccess(.reducefailed)
            }).disposed(by: self.rx.disposeBag)
        }
        else{
            reduceSuccess(.reducenomatch) //没次数了
            showRunoutTimesView()
        }
    }
    
    
    func showRunoutTimesView()  {
        //        GuideCheckTaskProcess.shared.pauseGuideCheck()
        matchLimitAlterview?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        matchLimitAlterview?.showOnWindow(direction:.center,enableclose: false)
    }
    func updateCurrentIndex(_ index:Int) ->  MatchGreeting? {
        let ousideData =  self.viewModel.output.outsideGreetingDatas.value
        if index <= ousideData.count - 1{
            self.currentGreeting.accept(ousideData[index])
            return ousideData[index]
        }
        return nil
    }
    func updateFilterMatch(_ andmatch:Bool = true)  {
        let config =  MatchTaskFilterViewModel.loadDefaultConfig()
        let genders = config.gender.sorted { (t1, t2) -> Bool in
            return t1.rawValue > t2.rawValue
        }
        let  genderselected = genders.reduce("") { (id, value) -> String in
            if  value == genders.first {
                return "\(value.rawValue)"
            }
            return "\(id),\(value.rawValue)"
        }
        let types = config.taskType.sorted { (t1, t2) -> Bool in
            return t1.rawValue > t2.rawValue
        }
        let  tasktypeselected = types.reduce("") { (id, value) -> String in
            if  value == types.first {
                return "\(value.rawValue)"
            }
            return "\(id),\(value.rawValue)"
        }
        MatchLimitCountManager.shared.viewModel.input.genderMatch.accept(genderselected)
        MatchLimitCountManager.shared.viewModel.input.taskTypeMatch.accept(tasktypeselected)
        MatchLimitCountManager.shared.firstRefreshLimit(andmatch)
        
    }
}



