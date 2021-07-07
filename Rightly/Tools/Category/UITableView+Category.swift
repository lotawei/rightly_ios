//
//  UITableView+Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/27.
//

import Foundation

extension UITableView {
    func initTableView() {
        self.backgroundColor = .white
        self.separatorStyle = .none
        self.estimatedRowHeight = 88
        self.estimatedSectionHeaderHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.rowHeight = UITableView.automaticDimension
    }
    
    func register(nibName:String, forCellId:String) {
        self.register(.init(nibName: nibName, bundle: nil), forCellReuseIdentifier: forCellId)
    }
    
    func register(nibName:String, headerFooterId:String) {
        self.register(.init(nibName: nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: headerFooterId)
    }
}

