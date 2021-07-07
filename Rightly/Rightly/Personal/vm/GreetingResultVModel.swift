
import Foundation
import Reusable
import RxSwift
import RxCocoa


/// 打招呼结果
class GreetingResultVModel:RTViewModelType {
    let disposebag = DisposeBag.init()
    typealias Input = GreetingResultInput
    
    typealias Output = GreetingResultOutPut
    var input:Input
    var output:Output
    let locationManager = LocationManager.init()
    struct GreetingResultInput {
        var  likeaction:PublishSubject<Bool> = PublishSubject.init() //喜欢不咯
    }
    struct GreetingResultOutPut {
        var  likeatTime:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)//喜欢的时间
        var  greetingCreateTime:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)//=创建时间
        var  greetingUpdateTime:BehaviorRelay<String?> = BehaviorRelay.init(value: nil)//最后更新
        var  greetingContent:BehaviorRelay<NSAttributedString?> = BehaviorRelay.init(value: nil) //内容
        //        var  greetingcity:BehaviorRelay<String?> =  BehaviorRelay.init(value: nil) //城市
        var  greetingLocationdecode:BehaviorRelay<String?> =  BehaviorRelay.init(value: nil) //城市反编码信息
        var  greetingviewType:BehaviorRelay<ViewType?> =  BehaviorRelay.init(value: nil) //私密性
        var  itemSelected:BehaviorRelay<Bool> = BehaviorRelay.init(value: false) //是否选中
        var  likeNumber:BehaviorRelay<String> =  BehaviorRelay.init(value: "") //喜欢个数
        var  likestate:BehaviorRelay<Bool> = BehaviorRelay.init(value: true) //喜欢不咯
        var  userInfo:BehaviorRelay<UserAdditionalInfo?> =  BehaviorRelay.init(value: nil) //用户信息
        var  resultData:BehaviorRelay< (tasktype:TaskBrief,[GreetingResourceList])?> =  BehaviorRelay.init(value: nil) //返回资源结果和打招呼任务信息
        var  greetingReultData:BehaviorRelay<GreetingResult>
    }
    
    
    
    var  greetingresult:GreetingResult
    init(_ greetingresult:GreetingResult) {
        self.input = GreetingResultInput.init()
        let greetingData = BehaviorRelay<GreetingResult>.init(value: greetingresult)
        self.output = GreetingResultOutPut.init(greetingReultData: greetingData)
        self.greetingresult  = greetingresult
        self.input.likeaction.asObservable().subscribe(onNext: { [weak self] (islike) in
            guard let `self` = self  else {return }
            self.output.likestate.accept(islike)
            if   var newlikenumber = Int(self.output.likeNumber.value) {
                if islike {
                    newlikenumber = newlikenumber + 1
                } else{
                    newlikenumber = newlikenumber - 1
                }
                self.output.likeNumber.accept("\(newlikenumber)")
            }
            
        }).disposed(by: self.disposebag)
        
        updateInfo()
        
    }
    func updateInfo()  {
        if let task  =  greetingresult.task  ,let  resourcelist = greetingresult.resourceList {
            self.output.resultData.accept((task, resourcelist))
        }
        self.output.greetingUpdateTime.accept(String.updateTimeToCurrennTime(timeStamp: Double(greetingresult.updatedAt ?? 0)))
        self.output.likeatTime.accept(String.updateTimeToCurrennTime(timeStamp: Double(greetingresult.likeAt ?? 0)))
        self.output.greetingContent.accept(greetingresult.content?.exportEmojiTransForm())
        //        self.output.greetingcity.accept(greetingresult.city)
        self.output.greetingviewType.accept(greetingresult.viewType)
        self.output.likeNumber.accept("\(greetingresult.likeNum ?? 0)")
        self.output.userInfo.accept(greetingresult.user)
        self.output.likestate.accept(greetingresult.isLike ?? false)
        self.output.greetingCreateTime.accept(String.updateTimeToCurrennTime(timeStamp: Double(greetingresult.createdAt ?? 0)))
        guard var  lat = greetingresult.lat, var lng = greetingresult.lng else {
            return
        }
        locationManager.reverseCityGeocode(lat, lng) {[weak self] (city) in
            guard let `self` = self  else {return }
            DispatchQueue.main.async {
                self.output.greetingLocationdecode.accept(city)
            }
        }
        //        LocationManager.shareinstance.reverseGeocode(lat, lng) {[weak self] (info) in
        //            guard let `self` = self  else {return }
        //            let  splitinfos = info.components(separatedBy: "-")
        //            if  splitinfos.count > 2 {
        //                var   city = splitinfos[2]
        //                if city.isEmpty {
        //                    city = splitinfos[1]
        //                }
        //                DispatchQueue.main.async {
        //                    self.output.greetingLocationdecode.accept(city)
        //                }
        //            }
        //        }
    }
    
}
