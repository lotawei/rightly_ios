//
//  MatchTaskViewModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
let  matchRequestCacheCount = 4
class MatchGreetingVMModel:NSObject,RTViewModelType {
    let disposebag = DisposeBag()
    typealias Input = MatchGreetingInput
    typealias Output = MatchGreetingOutPut
    var input: MatchGreetingInput
    var output: MatchGreetingOutPut
    struct MatchGreetingInput {
        let requestCommand:PublishSubject<Void>
        let size:BehaviorRelay<Int> = BehaviorRelay.init(value: matchRequestCacheCount)
        let genderMatch:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
        let taskTypeMatch:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)
    }
    struct MatchGreetingOutPut:OutputRefreshProtocol {
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: .idleNone)
        var startAniation: BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
        var outsideGreetingDatas:BehaviorRelay<[MatchGreeting]> =  BehaviorRelay.init(value: [])
        var emptyDataShow:PublishSubject<Bool> = PublishSubject.init()
    }
    
    override init() {
        let requestCommand = PublishSubject<Void>.init()
        self.input = MatchGreetingInput.init(requestCommand: requestCommand)
        self.output = MatchGreetingOutPut()
        super.init()
        self.input.requestCommand.asObservable().subscribe(onNext: { [weak self] in
            guard let `self` = self  else {return }
            let page = self.input.size.value
            let gender = self.input.`genderMatch`.value
            let tasktype = self.input.taskTypeMatch.value
            MatchTaskGreetingProvider.init().gainmatchGreeting(page, gender: gender, taskType: tasktype,self.disposebag).subscribe(onNext: { (liveres) in
                self.output.startAniation.accept(false)
//                switch liveres {
                if let datas = liveres.modeDataKJTypeSelf(typeSelf: MatchDtata.self)?.matchData{
                    if datas.count > 0  {
                   
                                           self.output.outsideGreetingDatas.accept(datas)
                                           self.output.emptyDataShow.onNext(false)
                                       }
                                       else{
                                           self.output.emptyDataShow.onNext(true)
                                           UIViewController.current()?.toastTip("没有匹配任务了".localiz())
                                       }
                }
//                case .success(let res):
//                    guard let data  = res else {
//                        return
//                    }
//                    if data.count > 0  {
//
//                        self.output.outsideGreetingDatas.accept(data)
//                        self.output.emptyDataShow.onNext(false)
//                    }
//                    else{
//                        self.output.emptyDataShow.onNext(true)
//                        UIViewController.current()?.toastTip("没有匹配任务了".localiz())
//                    }
//                case .failed(let _):
//                    self.output.outsideGreetingDatas.accept([])
//                    self.output.refreshStatus.accept(.endHeaderRefresh)
//                    self.output.emptyDataShow.onNext(true)
//                }
            },onError: { (err) in
                self.output.outsideGreetingDatas.accept([])
                self.output.refreshStatus.accept(.endHeaderRefresh)
                self.output.emptyDataShow.onNext(true)
            }).disposed(by: self.disposebag)
        }).disposed(by: disposebag)
    }
    
}
