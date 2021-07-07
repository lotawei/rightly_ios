//
//  FriendsDBManager.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/30.
//

import UIKit
import RealmSwift
import Realm

class FriendsDBManager: NSObject {
    private static let staticInstance = FriendsDBManager()
    static func shared() -> FriendsDBManager {
        return staticInstance
    }
    
    private override init() {
        super.init()
    }
    
    var currRealm:Realm? = nil
    var currUserId:String? = nil
    
    public func configRealm(_ userId:String) {
        if self.currUserId == userId && self.currRealm != nil {
            return
        }
        
        self.currUserId = userId
        self.currRealm = nil
        
        /// 这个方法主要用于数据模型属性增加或删除时的数据迁移，每次模型属性变化时，将 dbVersion 加 1 即可，Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构，移除属性的数据将会被删除。
        let dbVersion : UInt64 = 2
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/\(userId).realm")
//        try? FileManager.default.removeItem(atPath: dbPath)
        let config = Realm.Configuration(fileURL: URL.init(string: dbPath), inMemoryIdentifier: nil, syncConfiguration: nil, encryptionKey: nil, readOnly: false, schemaVersion: dbVersion, migrationBlock: { (migration, oldSchemaVersion) in
            
        }, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
        
        Realm.Configuration.defaultConfiguration = config
        
        Realm.asyncOpen { (result) in
            switch result {
            case .success(_):
                debugPrint("Realm 服务器配置成功!")
                
                let dbURL = URL.init(fileURLWithPath: dbPath)
                self.currRealm = try? Realm.init(fileURL: dbURL)
                debugPrint("打开数据库:" + (self.currRealm == nil ? "失败" : "成功"))
            case .failure(let error):
                debugPrint("Realm 数据库配置失败:\(error)")
            }
        }
    }
}
