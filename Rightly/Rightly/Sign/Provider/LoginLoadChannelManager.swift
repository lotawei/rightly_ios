//
//  LoginLoadChannelManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/10.
//

import Foundation
class  LoginLoadChannelManager {
    static func loadByChannelLoginVC() -> UIViewController {
        LanguageManager.shared.defaultLanguage = .zhHans
        let startViewCtrl: ChinaStartViewController = ChinaStartViewController.init(nibName: "ChinaStartViewController", bundle: nil)
        return startViewCtrl
    }
}
