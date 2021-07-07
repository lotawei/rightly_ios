//
//  DynamicDetailsViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/9.
//

import Foundation
import RxSwift
import RxCocoa

class DynamicDetailsViewModel {
    var disposeBag = DisposeBag()
    
    var dynamicViewModel:DynamicDataViewModel? = nil
    var commentDatas: BehaviorRelay<[CommentDataViewModel]> = BehaviorRelay<[CommentDataViewModel]>(value: [])
    var isOver: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var pageNum:Int = 1
    
    init(_ dynamicViewModel:DynamicDataViewModel?) {
        self.dynamicViewModel = dynamicViewModel
    }
    
    init() {
    }
    
    func requestDynamic(_ greetingId:String, block: @escaping (Bool) -> Void) {
        self.disposeBag = DisposeBag()
        DynamicProvider.init().requestDynamicDetail(greetingId, self.disposeBag)
            .subscribe(onNext:{ [weak self] (requestData) in
                guard let `self` = self else {return}
                if let tempJson = requestData.dicData {
                    self.dynamicViewModel = DynamicDataViewModel.init(tempJson)
                }
                block(true)
            }, onError: { error in
                block(false)
            }).disposed(by: self.disposeBag)
        
    }
    
    /// 请求1级评论列表
    func requestCommentList(block: @escaping (Bool) -> Void) {
        self.disposeBag = DisposeBag()
        if self.dynamicViewModel == nil {
            block(false)
            return
        }
        
        CommentProvider.init().requestCommentList(self.dynamicViewModel?.greetingId ?? "", self.pageNum, disposebag: self.disposeBag).subscribe(onNext:{ [weak self] (requestData) in
            guard let `self` = self else {return}
            self.pageNum += 1
            if let results = requestData.results {
                var tempCommentDatas = self.commentDatas.value
                for jsonData in results {
                    let commentViewModel = CommentDataViewModel.init(jsonData)
                    
                    if !tempCommentDatas.contains(where: { (tempViewModel) in
                        return tempViewModel.commentId == commentViewModel.commentId
                    }) {
                        tempCommentDatas.append(commentViewModel)
                        self.setupBindViewModel(commentViewModel)
                    }
                }
                
                self.commentDatas.accept(tempCommentDatas)
            }
            
            if requestData.pageNum >= requestData.totalPage {
                self.isOver.accept(true)
            } else {
                self.isOver.accept(false)
            }

            block(true)
        }, onError: { error in
            block(false)
        }).disposed(by: self.disposeBag)
    }
    
    
    /// 提交评论
    func postComment(_ content:NSAttributedString, indexPath:IndexPath?, block: @escaping (Bool) -> Void) {
        guard let targetId = self.dynamicViewModel?.greetingId else {
            block(false)
            return
        }
        
        let postContent = content.string
        if let selectIndexPath = indexPath {
            //回复 2/3级评论
            if selectIndexPath.row == 0 {
                let commentViewModel = self.commentDatas.value[selectIndexPath.section - 1]
                commentViewModel.postComment(postContent, replyCommentId: commentViewModel.commentId, level: 2) { (ok) in
                    block(ok)
                }
            } else {
                let commentViewModel = self.commentDatas.value[selectIndexPath.section - 1]
                let replyViewModel = commentViewModel.replyDatas.value[selectIndexPath.row - 1]
                commentViewModel.postComment(postContent, replyCommentId: replyViewModel.commentId, level: 3) { (ok) in
                    block(ok)
                }
            }
        } else {
            //评论 1级评论
            CommentProvider.init().postComment(targetId, 1, postContent, self.disposeBag)
                .subscribe(onNext:{ [weak self] (requestData) in
                    guard let `self` = self else {return}
                    
                    if let jsonData = requestData.data as? [String : Any] {
                        let commentViewModel = CommentDataViewModel.init(jsonData)
                        var resultDatas = self.commentDatas.value
                        
                        if !resultDatas.contains(where: { (tempViewModel) in
                            return tempViewModel.commentId == commentViewModel.commentId
                        }) {
                            if self.isOver.value {
                                resultDatas.append(commentViewModel)
                            } else {
                                resultDatas.insert(commentViewModel, at: 0)
                            }
                            
                            self.setupBindViewModel(commentViewModel)
                        }
                        
                        self.commentDatas.accept(resultDatas)
                        self.dynamicViewModel?.commentNum.accept(max(self.dynamicViewModel?.commentNum.value ?? 0, 0) + 1)
                    }
                    
                    block(true)
                }, onError: { (error) in
                    block(false)
                }).disposed(by: self.disposeBag)
        }
    }
    
    func setupBindViewModel(_ viewModel:CommentDataViewModel) {
        var tempReplyNum = viewModel.replyNum.value
        viewModel.replyNum.subscribe(onNext:{ [weak self] (num) in
            guard let `self` = self else {return}
            self.dynamicViewModel?.commentNum.accept(max(self.dynamicViewModel?.commentNum.value ?? 0, 0) + (num - tempReplyNum))
            tempReplyNum = num
        }).disposed(by: self.disposeBag)
        
        viewModel.replyDatas.subscribe(onNext:{ [weak self] (datas) in
            guard let `self` = self else {return}
            self.commentDatas.accept(self.commentDatas.value)
        }).disposed(by: self.disposeBag)
    }
    
    func getNickname(_ indexPath:IndexPath) -> String {
        let commentViewModel = self.commentDatas.value[indexPath.section - 1]
        if indexPath.row <= 0 {
            return commentViewModel.userName
        }
        
        let replyViewModel = commentViewModel.replyDatas.value[indexPath.row - 1]
        return replyViewModel.userName
    }
}
