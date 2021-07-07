//
//  GreetingDetailVModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/30.
//

import Foundation
import MBProgressHUD
import Reusable
import RxSwift
import RxCocoa


/// 打招呼结果
class GreetingDetailVModel:RTViewModelType {
    let disposebag = DisposeBag.init()
    typealias Input = GreetingDetailInput

    typealias Output = GreetingDetailOutPut
    var input:Input
    var output:Output
    let locationManager = LocationManager.init()
    struct GreetingDetailInput {
        var greetingId:BehaviorSubject<Int64?> = BehaviorSubject.init(value: nil)
        
    }
    struct GreetingDetailOutPut {
        var  resultData:BehaviorRelay<GreetingDetail?> =  BehaviorRelay.init(value: nil) //招呼详情
        var  greetingLocationdecode:BehaviorRelay<String?> =  BehaviorRelay.init(value: nil) //城市反编码信息
        var  emptydetail:PublishSubject<Void> = PublishSubject.init()
    }
    init() {
        
        self.input = GreetingDetailInput.init()
        self.output = GreetingDetailOutPut.init()
        
        self.input.greetingId.asObserver().subscribe(onNext: { [weak self] (greetid) in
            guard let `self` = self  else {return }
            if let greid = greetid {
                self.requestDetail(greid)
            }
           
            
        }).disposed(by:disposebag)
//        self.input.likeaction.asObserver().subscribe(onNext: { [weak self] (greetid) in
//            guard let `self` = self  else {return }
//            
//           
//            
//        }).disposed(by:disposebag)
//        self.input.requestUserInfo.asObserver().subscribe(onNext: { [weak self] (userid) in
//            guard let `self` = self  else {return }
//            self.requestUserInfo(userid)
//        }).disposed(by:disposebag)
    }
    func requestDetail(_ greetingid:Int64)  {
        MatchTaskGreetingProvider.init().greetingDetail(greetingId: greetingid, self.disposebag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let detail = res.modeDataKJTypeSelf(typeSelf: GreetingDetail.self) {
                    self.output.resultData.accept(detail)
                    self.checkCity(greetingresult: detail)
                }
//                switch res {
//                case .success(let adetail):
//                    guard let detail = adetail else {
//                        return
//                    }
//                    self.output.resultData.accept(detail)
//                    self.checkCity(greetingresult: detail)
//                case .failed(let err):
//                    if ((err as? NSError)?.code ?? 0 ) == -44{
//                        self.output.emptydetail.onNext({}())
//                    }else{
//                        MBProgressHUD.showError("Network failed".localiz())
//                    }
//                    break
//                }
//
            },onError: { (err) in
                MBProgressHUD.showError("Network failed".localiz())
            }).disposed(by: self.disposebag)
        
    }
    
    func  checkCity(greetingresult:GreetingDetail?){
        guard var  lat = greetingresult?.lat, var lng = greetingresult?.lng else {
              return
        }
        locationManager.reverseCityGeocode(lat, lng) {[weak self] (city) in
            guard let `self` = self  else {return }
            self.output.greetingLocationdecode.accept(city)
        }
//        LocationManager.init().reverseCityGeocode(lat, lng) {[weak self] (city) in
//            guard let `self` = self  else {return }
//            self.output.greetingLocationdecode.accept(city)
//        }
//        LocationManager.shareinstance.reverseGeocode(lat, lng,address:  {[weak self] (info) in
//            guard let `self` = self  else {return }
//            let  splitinfos = info.components(separatedBy: "-")
//            if  splitinfos.count > 2 {
//                var   city = splitinfos[2]
//                if city.isEmpty {
//                    city = splitinfos[1]
//                }
//                self.output.greetingLocationdecode.accept(city)
//            }
//        })
    }
    

}
