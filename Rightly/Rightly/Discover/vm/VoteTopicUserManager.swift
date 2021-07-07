//
//  VoteUserManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/28.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
enum VoteResult:Int {
    case unSupport = 2, //不支持
         likeSupport = 1, //支持票
         operatorFailed = 0 //操作失败
}
enum VoteType:Int,Codable {
    case likeSupport =  1,
        unSupport = 2
}
class VoteTopicUserManager {
    
    
    fileprivate var disposebag = DisposeBag()
    fileprivate var topicId:Int64
    var  startAnimation:BehaviorRelay<Bool> = BehaviorRelay<Bool>.init(value: false)
    var  shouldRefresh:PublishSubject<Void> = PublishSubject.init()
    var  itemVoteresults:PublishSubject<[VoteResultModel]> = PublishSubject.init()
    var  novoteMatchData:PublishSubject<Bool> = PublishSubject.init()
    var  currentVoteDisplayItem:BehaviorRelay<VoteResultModel?> = BehaviorRelay.init(value: nil)
    var  originalResult:[VoteResultModel] = []
    var  player:ZFPlayerController!
    
    init(_ topicId:Int64) {
        self.topicId = topicId
        self.shouldRefresh.startWith({}()).asObservable().subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.requestVote()
        }).disposed(by: self.disposebag)
    }
    /// 请求数据
   fileprivate func requestVote()  {
        self.startAnimation.accept(true)
        DiscoverProvider.init().gainVoteUserTopic(topicId: self.topicId, size: 5, self.disposebag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.startAnimation.accept(false)
            if let voteinfos = res.modelArrType(VoteResultModel.self) {
                self.originalResult = voteinfos
                self.itemVoteresults.onNext(voteinfos)
            }
//            switch res {
//            case .success(let votes):
//                guard let  voteinfos = votes else {
//                    return
//                }
//                self.originalResult = voteinfos
//                self.itemVoteresults.onNext(voteinfos)
//                break
//            case .failed(let err):
//                UIViewController.getCurrentViewController()?.toastTip("Network failed".localiz())
//            }
        },onError: { (err) in
            UIViewController.getCurrentViewController()?.toastTip("Network failed".localiz())
        }).disposed(by: self.disposebag)
    }
    
    /// 投票
    /// - Parameters:
    ///   - vote:
    ///   - votetype: 1 支持 2 不支持
    ///   - voteResult: <#voteResult description#>
    func voteTopicUser(vote:VoteResultModel, votetype:VoteType, _ voteResult:@escaping((_ success:VoteResult) -> Void))  {
        DiscoverProvider.init().voteTopic(greetingId: vote.greetingId, votetype:votetype, self.disposebag).subscribe(onNext: { [weak self] (res) in
            voteResult(votetype == .likeSupport ? VoteResult.likeSupport:VoteResult.unSupport)
//            switch res {
//            case .success(let info):
//                voteResult(votetype == .likeSupport ? VoteResult.likeSupport:VoteResult.unSupport)
//            case .failed(let err):
//                voteResult(VoteResult.operatorFailed)
//            }
        },onError: { (err) in
            voteResult(VoteResult.operatorFailed)
        }).disposed(by: self.disposebag)
    }
    func updateCurrentItem(_ index:Int)  {
        if index <= originalResult.count - 1 {
                self.currentVoteDisplayItem.accept(originalResult[index])
        }
    }
    
    func createPlayer(containerView:UIView,_ videourl:String,_ cover:URL? = nil)  {
        let playermanager = ZFAVPlayerManager.init()
        playermanager.shouldAutoPlay = true
        self.player = ZFPlayerController.init(playerManager: playermanager, containerView: containerView)
        self.player.pauseWhenAppResignActive = false
        self.player.resumePlayRecord = true
        self.player.isWWANAutoPlay = true;
        self.player.assetURL = URL.init(string: videourl)!
        self.player.playTheIndex(0)
        self.player.playerDidToEnd = {
            [weak self] asset in
            guard let `self` = self  else {return }
            self.player.currentPlayerManager.replay()
        }
    }
    func stopCurrent()  {
        if self.player != nil {
            self.player.stop()
        }
    }
}
