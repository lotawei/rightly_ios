//
//  VoteResultModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/29.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher
/// 投票模型
class VoteResultModel: Convertible {
    var address : String? = nil
    var content : String? = nil
    var greetingId : Int64 = 0
    var isLike : Bool? = nil
    var lat : Float? = 0
    var lng : Float? =  0
    var resourceList : [GreetingResourceList]? = nil
    var taskType : TaskType = .photo
    var user : UserAdditionalInfo? = nil
    var userId : Int64? = nil
    var hotNum:Int64?  = nil
    var  preBackImageProcess:BehaviorRelay<UIImage?>=BehaviorRelay.init(value:nil)//本地维护
    required init(){
        
    }
}
extension VoteResultModel {
    func  backImageDecodeProcess( targetSize:CGSize? = nil) {
        var backUrl:String?=nil
        switch self.taskType {
        case .voice:
            backUrl =  self.user?.backgroundUrl?.dominFullPath()
        case .photo:
            backUrl =  self.resourceList?.first?.url?.dominFullPath()
        case .video:
            backUrl =  self.resourceList?.first?.previewUrl?.dominFullPath()
        default:
            backUrl =  self.user?.backgroundUrl?.dominFullPath()
        }
        guard let url = backUrl ,let netWorkUrl = URL.init(string: url) else {
           self.preBackImageProcess.accept(nil)
           return
       }
        KingfisherManager.shared.loadCacheOrNetWorkByCache(netWorkUrl,targetSize: targetSize) {[weak self] (image) in
           guard let `self` = self  else {return }
           self.preBackImageProcess.accept(image)
       }
   }
}
