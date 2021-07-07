//
//  NetProViderReloadProtocol.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/23.
//

import Foundation
import Alamofire
import CoreTelephony
import RxSwift
/// 扩展网络不好后的加载
protocol NetProViderReloadProtocol {
    func  reloadNetWorkData()
}

enum NetStatus:String {
    case notReachable = "notReachable",
         ethernetOrWiFi = "ethernetOrWiFi",
         g2 = "2g",
         g3 = "3g",
         g4 = "4g",
         g5 = "5g",
         unknown = "unknown"
}

class NetProviderStatusManager {
    static let shared = NetProviderStatusManager.init()
    var  netManager = NetworkReachabilityManager.init(host: "www.baidu.com")
    var  netsatussubject:PublishSubject<NetStatus> = PublishSubject.init()
    let quene = DispatchQueue.init(label: "statuslistner")
    init() {
        listenNetSatatus()
    }
    fileprivate  func  listenNetSatatus() {
        
        self.netManager?.startListening(onQueue: quene, onUpdatePerforming: {[weak self] (st) in
            guard let `self` = self  else {return }
            switch st{
            case .notReachable:
                self.safeThreadUpdate{
                    self.netsatussubject.onNext(.notReachable)
                }
                
                break
            case  .reachable(let type):
                switch type {
                case .ethernetOrWiFi :
                    self.safeThreadUpdate{
                        self.netsatussubject.onNext(.ethernetOrWiFi)
                    }
                    break
                case .cellular:
                    self.safeThreadUpdate {
                        self.netsatussubject.onNext(self.getGNetStatus())
                    }
                    break
                    
                }
            case .unknown:
                self.safeThreadUpdate {
                    self.netsatussubject.onNext(.unknown)
                }
            }
        })
        
    }
    func  safeThreadUpdate(_ block:@escaping()->Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    public  func  getGNetStatus() -> NetStatus{
        let gstatus = CTTelephonyNetworkInfo.init().currentRadioAccessTechnology
        let   tg2Types = [CTRadioAccessTechnologyEdge,CTRadioAccessTechnologyGPRS,CTRadioAccessTechnologyCDMA1x]
        let   tg3Types = [CTRadioAccessTechnologyHSDPA,CTRadioAccessTechnologyWCDMA,CTRadioAccessTechnologyHSUPA,CTRadioAccessTechnologyCDMAEVDORev0,CTRadioAccessTechnologyCDMAEVDORevA,CTRadioAccessTechnologyCDMAEVDORevB,CTRadioAccessTechnologyeHRPD]
        let   tg4Types = [CTRadioAccessTechnologyLTE]
        guard let  status = gstatus else {
            return .unknown
        }
        if tg2Types.contains(status) {
            return  .g2
        }
        if tg3Types.contains(status) {
            return  .g3
        }
        if tg4Types.contains(status) {
            return  .g4
        }
        return .g5
    }
}
