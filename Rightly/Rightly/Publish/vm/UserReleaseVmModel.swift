//
//  UserReleaseVmModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/9.
//

import Foundation
import RxSwift
import UIKit
import RxDataSources
import RxCocoa
import Moya
import MBProgressHUD
import Photos


class UserReleaseVmModel:NSObject, RTViewModelType {
    var input: UserPublishInput
    
    var output: UserPublishOutput
    
    typealias Input = UserPublishInput
    
    typealias Output = UserPublishOutput
    struct InputData {
        var  taskId:Int64? = nil //对应用户的taskid
        var  toUserId:Int64? = nil //和哪个人打招呼
        var  type:ReleaseType? = .greeting //打招呼入口，1/2 打招呼/积分任务 3 /标签任务  *******必传
        var  viewType:ViewType?=ViewType.Public //访问类型，1/2 只能自己看/公开
        var  content:String?=nil //打招呼内容
        var  resourcelists:[GreetingResourceList]?=nil //如果是视频需要首图
        var address:String?=nil //详细地址
        var   taskType:Int?=nil //****必传
        var  lng:Double?=nil //经度
        var  lat:Double?=nil //维度
        var  tagids:[Int64]?=nil //点亮的标签 ****type 3
        var topicIds:[Int64]?=nil //参与话题  ****type 4
    }
    struct UserPublishInput {
        var  releastType:PublishSubject<TaskType> = PublishSubject.init()
        var  data:InputData = InputData.init()
    }
     
    struct UserPublishOutput {
        var  displayTitle:BehaviorRelay<String> = BehaviorRelay.init(value: "")
    }
    override init() {
        input = UserPublishInput.init()
        output = UserPublishOutput.init()
        super.init()
        self.input.releastType.asObserver().subscribe(onNext: { [weak self] (tasktype) in
            guard let `self` = self  else {return }
            self.output.displayTitle.accept(tasktype.typeTitle())
        }).disposed(by: self.rx.disposeBag)
        
    }
    
    
}

