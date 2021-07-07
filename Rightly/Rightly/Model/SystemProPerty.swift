//
//  systemoroperty.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/18.
//

import Foundation
import KakaJSON
class SystemProPerty:Convertible {
    var storageBaseUrl:String? = nil //资源存储地址
    required init() {
        
    }
}
fileprivate let  systemstorage:String = "systemstorage"
class  SystemManager: NSObject {
    static let shared:SystemManager = SystemManager.init()
    var  storage:SystemProPerty? {
        get {
            return self.loadLocalStorage()
        }
    }
    override init() {
        super.init()
        let provider = UserProVider.init()
        if self.storage == nil {
            provider.systemProperty(self.rx.disposeBag)
                .subscribe(onNext: { [weak self] (res) in
                    guard let `self` = self  else {return }
                    if let dicData = res.data as? [String:Any]
                    {
                        let propersystem = dicData.kj.model(SystemProPerty.self)
                        self.saveStorage(propersystem)
                    }
                    
            }).disposed(by: self.rx.disposeBag)
        }
       
    }
    
    func loadLocalStorage() -> SystemProPerty?{
        let  value = UserDefaults.standard.object(forKey: systemstorage) as? [String:Any]
        let storage:SystemProPerty? = value?.kj.model(SystemProPerty.self)
        return storage
    }
    func saveStorage(_ storage:SystemProPerty?)
    {
        UserDefaults.standard.setValue(storage?.kj.JSONObject(), forKey: systemstorage)
        UserDefaults.standard.synchronize()
    }
}
