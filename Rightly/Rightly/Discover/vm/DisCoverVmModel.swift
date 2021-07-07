//
//  TopicVmModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
enum DisCoverType:Int{
    case  topic = 0, //话题
          recommend = 1 //推荐 目前没用过
}
/// 话题界面模型
enum DiscoverItem {
    case topic(_ item:DiscoverTopicModel)
    case recommend(_ item:DiscoverRecommendModel)
}

struct DiscoverItemListSection {
    var items:[DiscoverItem]
    var header:String = ""
}
extension  DiscoverItemListSection:SectionModelType{
    typealias Item = DiscoverItem
    init(original: DiscoverItemListSection, items: [DiscoverItem]) {
        self = original
        self.items = items
    }
}

class DisCoverVmModel:RTViewModelType {
    let  disposeBag = DisposeBag.init()
    typealias Input = TopicVmInput
    typealias Output = TopicVmOutPut
    var input:Input
    var output:Output
    struct TopicVmInput {
        let disCoverType:BehaviorRelay<DisCoverType> = BehaviorRelay.init(value: DisCoverType.topic)
        let requestCommand:PublishSubject<Void> = PublishSubject.init()
        let requestFoot:PublishSubject<Void> = PublishSubject.init()
        let pagesize:BehaviorRelay<Int> = BehaviorRelay.init(value: 3)
        let pagenumber:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
    }
    
    struct TopicVmOutPut:OutputRefreshProtocol {
        var refreshStatus: BehaviorRelay<RTRefreshStatus>
        var  disCoverDatas:BehaviorRelay<[DiscoverItemListSection]>
        var emptyDataShow:PublishSubject<Bool> = PublishSubject.init()
    }
    init() {
        input = TopicVmInput.init()
        let  refreshState = BehaviorRelay.init(value: RTRefreshStatus.idleNone)
        let  itemdatas = BehaviorRelay<[DiscoverItemListSection]>.init(value: [])
        output = TopicVmOutPut.init(refreshStatus: refreshState, disCoverDatas:itemdatas)
        self.input.requestCommand.subscribe(onNext: { [weak self] in
            guard let `self` = self  else {return }
            self.refreshData()
        }).disposed(by: self.disposeBag)
        self.input.requestFoot.subscribe(onNext: { [weak self] in
            guard let `self` = self  else {return }
            self.loadMore()
        }).disposed(by: self.disposeBag)
        
    }
    fileprivate func refreshData(){
        self.input.pagenumber.accept(1)
        let  page = self.input.pagenumber.value
        let  size = self.input.pagesize.value
        DiscoverProvider.init().disCoverPageData(page, size, type: self.input.disCoverType.value, self.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.output.refreshStatus.accept(.endHeaderRefresh)
            if  self.input.disCoverType.value == .topic {
                if let dicData = res.data as? [String:Any] {
                    let   topicDataresults  = dicData.kj.model(DisCoverResetApiDataModel.self).results ??    []
                    let  discoverItems =  topicDataresults.map { (disCoverModel) -> DiscoverItem in
                        return DiscoverItem.topic(disCoverModel)
                    }
                    let sections = DiscoverItemListSection.init(items: discoverItems)
                    self.output.disCoverDatas.accept([sections])
                    self.output.emptyDataShow.onNext(discoverItems.count == 0)
                }
            }
//
//            switch res {
//            case .success(let sections):
//                guard let secti = sections else {
//                    return
//                }
//                let sections = DiscoverItemListSection.init(items: secti)
//                self.output.disCoverDatas.accept([sections])
//                self.output.emptyDataShow.onNext(secti.count == 0)
//                break
//            case .failed(let err):
//                self.output.disCoverDatas.accept([])
//            }
            
//
        },onError: { (err) in
            self.output.disCoverDatas.accept([])
        }).disposed(by: self.disposeBag)
    }
    fileprivate func loadMore(){
        var discoverItems =  self.output.disCoverDatas.value
        let  pagesize = self.input.pagesize.value
        let  pagenumber  = self.input.pagenumber.value
        let  morenumber = pagenumber + 1
        DiscoverProvider.init().disCoverPageData(morenumber, pagesize, type: self.input.disCoverType.value, self.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.output.refreshStatus.accept(.endFooterRefresh)
            if  self.input.disCoverType.value == .topic {
                if let dicData = res.data as? [String:Any] {
                    let   topicDataresults  = dicData.kj.model(DisCoverResetApiDataModel.self).results ??    []
                    if topicDataresults.count == 0 {
                        return
                    }
                    let  moreItems =  topicDataresults.map { (disCoverModel) -> DiscoverItem in
                        return DiscoverItem.topic(disCoverModel)
                    }
                    let sections = DiscoverItemListSection.init(items: moreItems)
                    discoverItems.append(sections)
                    self.input.pagenumber.accept(morenumber)
                    self.output.disCoverDatas.accept(discoverItems)
                }
            }
//            switch res {
//            case .success(let sections):
//                guard let secti = sections else {
//                    return
//                }
//                if secti.count == 0 {
//                    return
//                }else{
//                    discoverItems.append( DiscoverItemListSection.init(items: secti))
//                    self.output.disCoverDatas.accept(discoverItems)
//                    self.input.pagenumber.accept(morenumber)
//                }
//                break
//            case .failed(let err):
//                break
//            }
        }).disposed(by: self.disposeBag)
    }
}
