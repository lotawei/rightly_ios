//
//  MessageTimeFooterView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/18.
//

import UIKit

class MessageTimeFooterView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.backgroundView?.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
