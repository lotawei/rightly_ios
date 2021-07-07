//
//  UserLikeViewControlelr.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class UserLikeViewControlelr: BaseViewController {
    var userid:Int64?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func  setupViews() {
        self.title = "Likes".localiz()
        var userId = self.userid?.description
        if userId == nil {
            userId = UserManager.manager.currentUser?.additionalInfo?.userId?.description
        }
        
        let listCtrl = DynamicListViewController.init(.likes, userId)
        listCtrl.addParents(self, self.view)
        listCtrl.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
