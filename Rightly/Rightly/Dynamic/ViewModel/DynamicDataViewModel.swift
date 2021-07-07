//
//  DynamicDataViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import Foundation
import RxSwift
import RxCocoa

class ResourceViewModel: NSObject {
    private let model:GreetingResourceList
    
    var duration:Int //毫秒
    var duration_f:Float    //秒
    var previewURL:URL?
    var contentURL:URL?
    var videoSize:CGSize
    
    init(_ model:GreetingResourceList) {
        self.model = model
        self.duration = Int(model.duration ?? 0)
        self.duration_f = Float(model.duration ?? 0) / 1000.0
        self.previewURL = URL.init(string: model.previewUrl?.dominFullPath() ?? "")
        self.contentURL = URL.init(string: model.url?.dominFullPath() ?? "")
        
        if let videoW = model.width, let videoH = model.height, videoW > 0, videoH > 0 {
            self.videoSize = CGSize.init(width: videoW, height: videoH)
        } else {
            self.videoSize = CGSize.init(width: 168.0, height: 94.0)
        }
        super.init()
    }
}

class TopicsDataViewModel {
    private let model:TopicsDataModel
    
    var topicId:String
    var topicStr:String? = nil
    var topicStrSize:CGSize = .zero
    var isMatch:Bool = false    //是否为比赛话题
    
    required init(_ model:TopicsDataModel) {
        self.model = model
        
        self.topicId = model.topicId
        self.isMatch = model.isMatch
        if let topicName = model.name, topicName.count > 0 {
            self.topicStr = topicName
            if topicName.first != "#" {
                self.topicStr = "#" + topicName
            }
            
            let topicWidth = (self.topicStr?.width(font: UIFont.systemFont(ofSize: 12), lineBreakModel: .byWordWrapping, maxWidth: screenWidth, maxHeight: 30) ?? 0.0) + 20.0
            self.topicStrSize = CGSize.init(width: topicWidth, height: 34.0)
        }
    }
}

class DynamicDataViewModel {
    let disposeBag = DisposeBag()
    private let model:DynamicDataModel
    
    var customType:TaskType = .noLimit
    
    //用户
    var greetingId:String?
    var userId:String? = nil
    var toUserId:String? = nil
    var userAccId:String?
    var contentUserId:String?   //内容动态作者的userId
    var headURL:URL?
    var placeHeadImageName:String
    var nickName:String?
    var pushDate:String?
    var isMyself:Bool
    var isFollow:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var isFriend:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    //内容相关
    var contentDesc:String?
    var address:String?  //发布动态的地址
    
    var decodeLocationCity:BehaviorRelay<String> = BehaviorRelay.init(value: "")
    var commentNum:BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)   //评论数
    var likeNum:BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)  //喜欢数
    var giftNum:BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)  //收到的礼物数
    var isLike:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)  //是否喜欢
    var isRead:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)   //是否已读
    var isTop:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)   //是否置顶(个人的动态列表展示)
    var viewType:BehaviorRelay<ViewType> = BehaviorRelay<ViewType>(value: .Private) //公开状态
    var cellHeight:CGFloat = 0
    
    //资源相关
    var imageURLList:[URL] = []
    var imageIndexOfSession:[[Int]] = []
    var resourceViewModel:ResourceViewModel? = nil
    var isPlaying:BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)   //是否正在播放(目前专只音频)
    
    //任务相关
    var taskId:String? = nil
    var task:TaskBrief? = nil
    var allowContent:String? = nil
    
    //保持强引用定位
    var  locamanager:LocationManager = LocationManager.init()
    //标签/话题
    var topicList:[TopicsDataViewModel] = []  //话题列表
    
    ///当customType == .photo 时 customViewSize 为 collectionView的size
    ///当customType == .voice 时 customViewSize.width 为音频指示条的宽度
    ///当customType == .video 时 customViewSize.width 为视频的宽度
    var customViewSize:CGSize = .zero
    var imageItemSize:CGSize = .zero
    required init(_ jsonData:[String:Any]) {
        self.model = jsonData.kj.model(DynamicDataModel.self)
        
        self.isMyself = UserManager.isOwnerMySelf(self.model.user != nil ? self.model.user?.userId : Int64(self.model.userId))
        let userInfo = self.isMyself ? UserManager.manager.currentUser?.additionalInfo : self.model.user
        self.greetingId = self.model.greetingId
        self.userId = self.model.userId
        self.userAccId = userInfo?.imAccId
        self.contentUserId = userInfo?.userId?.description
        self.headURL = URL.init(string: userInfo?.avatar?.dominFullPath() ?? "")
        self.placeHeadImageName = userInfo?.gender?.defHeadName ?? "default_head_image"
        self.nickName = userInfo?.nickname
        let createTime = TimeInterval(self.model.createdAt)
        let pushTime = createTime > maxTimeStamp ? (createTime / 1000.0) : createTime
        self.pushDate = String.updateTimeToCurrennTime(timeStamp: pushTime)
        self.isFollow.accept(userInfo?.relationType != UserRelationType.relationnone)
        self.contentDesc = self.model.content
        self.address = self.model.address
        self.likeNum.accept(self.model.likeNum)
        self.commentNum.accept(self.model.commentNum)
        self.giftNum.accept(0)
        self.isLike.accept(self.model.isLike)
        
        //话题
        for tempModel in self.model.topics {
            let tempViewModel = TopicsDataViewModel.init(tempModel)
            if tempViewModel.topicStr != nil {
                self.topicList.append(tempViewModel)
            }
        }
        
        // 处理greeting
        self.toUserId = self.model.toUserId
        self.isFriend.accept(self.model.status == 1 ? true : false)
        self.allowContent = self.model.allowContent
        self.isRead.accept(self.model.isRead)
        self.taskId = self.task?.taskId == nil ? self.model.taskId : self.task?.taskId?.description
        self.task = self.model.task
        self.isTop.accept(self.model.isTop)
        self.viewType.accept(self.model.viewType)
        
        // 处理资源
        self.customType = self.model.task?.type ?? self.model.taskType
        if self.customType == .photo {
            //图片样式单独处理
            var rowInSecCount = 1
            let imageCount = self.model.resourceList.count
            if imageCount == 2 || imageCount == 4 {
                rowInSecCount = 2
            } else if imageCount >= 3 {
                rowInSecCount = 3
            }
            
            let secNum = Int(imageCount / rowInSecCount) + (imageCount % rowInSecCount == 0 ? 0 : 1)
            for i in 0..<secNum {
                var imageIndexs = [Int]()
                let baseCount = i * rowInSecCount
                let count = min((imageCount - baseCount), rowInSecCount)
                for j in 0..<count {
                    let resourceModel = self.model.resourceList[(baseCount + j)]
                    let imageURL = URL.init(string: resourceModel.url?.dominFullPath() ?? "") ?? URL.init(fileURLWithPath: "")
                    imageIndexs.append(baseCount + j)
                    self.imageURLList.append(imageURL)
                }
                
                self.imageIndexOfSession.append(imageIndexs)
            }
            
            let customW = screenWidth - 64.0 - 16.0
            if imageCount == 1 {
                self.customViewSize = CGSize.init(width: customW, height: customW * 9.0 / 16.0)
                self.imageItemSize = CGSize.init(width: customW, height: self.customViewSize.height)
            } else {
                let secNumf = CGFloat(secNum)
                let itemWH = CGFloat((screenWidth - 64.0 - 55.0 - 8.0 * 2) / 3.0)
                self.customViewSize = CGSize.init(width: customW, height: CGFloat(itemWH * secNumf + (8.0 * (secNumf - 1))))
                self.imageItemSize = CGSize.init(width: itemWH, height: itemWH)
            }
        } else {
            if self.customType == .voice {
                let customH = 40.0
                let audioMaxW = Double(screenWidth - 64.0 - 55.0 - 80.0)
                self.customViewSize = CGSize.init(width: audioMaxW, height: customH)
                if let resourceModel = self.model.resourceList.first {
                    self.resourceViewModel = ResourceViewModel.init(resourceModel)
                    let voiceW = fmin(1.0, (Double(self.resourceViewModel?.duration_f ?? 0) / RTVoiceRecordManager.shareinstance.maxTimeAllow)) * audioMaxW
                    self.customViewSize = CGSize.init(width: voiceW, height: customH)
                }
            } else if self.customType == .video {
                let videoMaxH = CGFloat(168.0)
                let videoMaxW = screenWidth - 64.0 - 16.0
                self.customViewSize = CGSize.init(width: videoMaxW, height: videoMaxH)
                
                if let resourceModel = self.model.resourceList.first {
                    self.resourceViewModel = ResourceViewModel.init(resourceModel)
                    
                    if let videoSize = self.resourceViewModel?.videoSize {
                        let currW = videoMaxH * videoSize.width / videoSize.height
                        
                        if currW > videoMaxW {
                            let currH = videoMaxW * videoSize.height / videoSize.width
                            self.customViewSize = CGSize.init(width: videoMaxW, height: currH)
                        } else {
                            self.customViewSize = CGSize.init(width: currW, height: videoMaxH)
                        }
                    }
                }
            }
        }
        
        // 以下是计算cell高度
        var contentH:CGFloat = 0
        if let desc = self.contentDesc, !desc.isEmpty {
            let descH = desc.height(font: .systemFont(ofSize: 18), lineBreakModel: .byWordWrapping, maxWidth: (screenWidth - 82))
            contentH = 8.0 + descH
        }
        
        var taskH:CGFloat = 0
        if let tempTask = self.task, let taskDesc = tempTask.descriptionField {
            let taskDescH = taskDesc.height(font: .systemFont(ofSize: 14), lineBreakModel: .byWordWrapping, maxWidth: screenWidth - 118) + 16.0
            taskH = 8.0 + max(34.0, taskDescH)
        }
        
        var topicH:CGFloat = 0
        if self.topicList.count > 0 {
            topicH = 8.0 + 34.0
        }
        
        let dataH:CGFloat = 8 + 32
        
        self.cellHeight = 64.0 + self.customViewSize.height + contentH + taskH + topicH + dataH + 8
    }
}

extension DynamicDataViewModel {
    func requestFollow() {
        guard let otherId = Int64(self.model.userId) else {
            return
        }
        
        UserProVider.focusUser(self.isFollow.value, userid: otherId, self.disposeBag) { [weak self] (isFollow) in
            guard let `self` = self else {return}
            self.isFollow.accept(isFollow)
        }
    }
    
    func requestLike() {
        guard let greetingId = Int64(self.model.greetingId) else {
            return
        }
        
        self.isLike.accept(!self.isLike.value)
        let likeResultNum = self.isLike.value ? (self.likeNum.value + 1) : (self.likeNum.value - 1)
        self.likeNum.accept((likeResultNum >= 0 ? likeResultNum : 0))
        MatchTaskGreetingProvider.init().greetingLike(greetingId, self.disposeBag).subscribe().disposed(by: self.disposeBag)
    }
    
    //改变状态 return: -1:当前选择viewType无变化， 0:改变失败  1.更改成功
    func requestChangeViewType(_ toViewType:ViewType, block: @escaping (Int) -> Void) {
        if self.viewType.value == toViewType {
            block(-1)
            return
        }
        
        guard let greetingId = self.greetingId, let greetI64Id = Int64(greetingId) else {
            block(0)
            return
        }
        
        UserProVider.init().userEditGreeting(greetingId: greetI64Id, viewType: toViewType.rawValue, self.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self else {return}
                self.viewType.accept(toViewType)
                block(1)
            },onError: { (err) in
                block(0)
            }).disposed(by: self.disposeBag)
    }
    
    /// 删除打招呼动态
    func requestDelete(block: @escaping (Bool) -> Void) {
        DynamicProvider().deleteDynamic(self.greetingId ?? "", self.disposeBag)
            .subscribe(onNext:{ (resultData) in
                block(true)
            }, onError: { (_) in
                block(false)
            }).disposed(by: self.disposeBag)
    }
    
    /// 置顶打招呼动态 return: -1:取消置顶， 0:置顶失败  1.置顶成功
    func requestTop(block: @escaping (Int) -> Void) {
        let isTop = self.isTop.value
        DynamicProvider().topDynamic(self.greetingId ?? "", (isTop ? 0 : 1), self.disposeBag)
            .subscribe(onNext:{ [weak self] (resultData) in
                guard let `self` = self else {return}
                self.isTop.accept(!isTop)
                block(isTop ? -1 : 1)
            }, onError: { (_) in
                block(0)
            }).disposed(by: self.disposeBag)
    }
    
    /// 举报打招呼
    func requestReport(_ reportType:Int, content:String? = nil, block: @escaping (Bool) -> Void) {
        guard let greetingId = self.greetingId, let greetI64Id = Int64(greetingId) else {
            block(false)
            return
        }
        
        UserProVider.init().reportTarget(2, targetId: greetI64Id, reportType, content: content, self.disposeBag)
            .subscribe(onNext: {  (res) in
                block(true)
            },onError: { (err) in
                block(false)
            }).disposed(by: self.disposeBag)
    }
    
    /// 反编码
    func requestLocation()  {
        let  lat = Double(self.model.lat)
        let  lng = Double(self.model.lng)
        if lat != 0 && lng != 0 {
                locamanager.reverseCityGeocode(lat, lng) {[weak self] (city) in
                guard let `self` = self  else {return }
                self.decodeLocationCity.accept(city)
            }
        }
    }
}

