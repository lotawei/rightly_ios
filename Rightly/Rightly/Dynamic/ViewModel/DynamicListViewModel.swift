//
//  DynamicListViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class DynamicListViewModel:RTViewModelType {
    let disposebag = DisposeBag()
    let dynamicProvider = DynamicProvider()
//    typealias Input = UserInterfaceInput
//    typealias Output = UserInterfaceOutput
    var input: UserInterfaceInput
    var output: UserInterfaceOutput
    var pageNum:Int = 1
    var listType:DynamicListType
    struct UserInterfaceInput {
        let headerCommand = PublishSubject<String?>.init()
        let footerCommand = PublishSubject<String?>.init()
        let pageSize:Int = 3
    }
    
    struct UserInterfaceOutput:OutputRefreshProtocol {
        var refreshStatus: BehaviorRelay<RTRefreshStatus> = BehaviorRelay<RTRefreshStatus>(value: RTRefreshStatus.idleNone)
        var requestStatus: BehaviorRelay<RTRequestStatus> = BehaviorRelay<RTRequestStatus>(value: RTRequestStatus.freeRequest)
        var dynamicDatas: BehaviorRelay<[DynamicDataViewModel]> = BehaviorRelay<[DynamicDataViewModel]>(value: [])
        var emptyData:PublishSubject<Bool> = PublishSubject.init()
    }
    
    init(_ listType:DynamicListType) {
        self.listType = listType
        self.input = UserInterfaceInput()
        self.output = UserInterfaceOutput()
        
        self.input.headerCommand.asObservable().subscribe(onNext: { [weak self] (parameter) in
            guard let `self` = self  else {return }
            if self.output.requestStatus.value != .requesting {
                self.output.requestStatus.accept(.requesting)
                self.requestDynamicList(true, parameter)
            }
        }).disposed(by: disposebag)
        
        self.input.footerCommand.asObservable().subscribe(onNext: { [weak self] (parameter) in
            guard let `self` = self  else {return }
            if self.output.requestStatus.value != .requesting {
                self.output.requestStatus.accept(.requesting)
                self.requestDynamicList(false, parameter)
            }
        }).disposed(by: disposebag)
    }
    
    // 请求列表
    func requestDynamicList(_ refresh:Bool,  _ parameter:String?) {
        var tempDynamicDatas = self.output.dynamicDatas.value
        
        var requestPageNum = self.pageNum
        if refresh {
            requestPageNum = 1
        }
        
        self.dynamicProvider.requestDynamicList(self.listType, parameter: parameter ?? "", requestPageNum,pageSize: self.input.pageSize, self.disposebag)
            .subscribe(onNext:{ (resultData) in
                if refresh {
                    RTVoiceRecordManager.shareinstance.stopPlayerAudio()
                    tempDynamicDatas.removeAll()
                }
                else{
                    self.pageNum = requestPageNum + 1
                }
                var hasMore = false
                let resData = resultData.data as? [String: Any]
                if let results = resData?["results"] as? [[String: Any]] {
                    for tempJsonData in results {
                        let tempViewModel = DynamicDataViewModel.init(tempJsonData)
                        tempDynamicDatas.append(tempViewModel)
                    }
                    
                    hasMore = results.count >= self.input.pageSize
                }
                self.output.emptyData.onNext( tempDynamicDatas.count == 0)
                self.output.requestStatus.accept((hasMore ? .freeRequest : .noMoreData))
                self.output.dynamicDatas.accept(tempDynamicDatas)
            }, onError: { (_) in
                self.pageNum = requestPageNum
                self.output.requestStatus.accept(.freeRequest)
            }).disposed(by: self.disposebag)
    }
    
    //删除打招呼动态
    func deleteData(_ index:Int) {
        if index >= self.output.dynamicDatas.value.count {
            return
        }
        
        var tempDynamicDatas = self.output.dynamicDatas.value
        tempDynamicDatas.remove(at: index)
        self.output.dynamicDatas.accept(tempDynamicDatas)
    }
    
    //置顶打招呼动态 return: -1:取消置顶， 0:置顶失败  1.置顶成功
    func topData(_ index:Int) {
        if index >= self.output.dynamicDatas.value.count {
            return
        }
        
        var tempDynamicDatas = self.output.dynamicDatas.value
        let tempDynamic = tempDynamicDatas[index]
        tempDynamicDatas.remove(at: index)
        tempDynamicDatas.insert(tempDynamic, at: 0)
        self.output.dynamicDatas.accept(tempDynamicDatas)
    }
}

extension DynamicListViewModel {
    func playAudio(_ index:Int) {
        for i in 0..<self.output.dynamicDatas.value.count {
            let tempViewModel = self.output.dynamicDatas.value[i]
            if tempViewModel.customType != .voice {
                continue
            }
            
            tempViewModel.isPlaying.accept((i == index ? !tempViewModel.isPlaying.value : false))
        }
        
        if index >= self.output.dynamicDatas.value.count {
            return
        }
        
        let tempViewModel = self.output.dynamicDatas.value[index]
        if tempViewModel.customType != .voice {
            return
        }
        
        if tempViewModel.isPlaying.value {
            guard let playPath = tempViewModel.resourceViewModel?.contentURL?.absoluteString else {
                return
            }
            
            RTVoiceRecordManager.shareinstance.startPlayerAudio(audiopath: playPath) { [weak self] (finish) in
                guard let `self` = self else {return}
                self.stopAllAudio()
            }
        } else {
            RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        }
    }
    
    func stopAllAudio() {
        for i in 0..<self.output.dynamicDatas.value.count {
            let tempViewModel = self.output.dynamicDatas.value[i]
            if tempViewModel.customType != .voice {
                continue
            }
            
            tempViewModel.isPlaying.accept(false)
        }
        
        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
    }
}

