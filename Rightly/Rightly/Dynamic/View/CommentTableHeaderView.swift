//
//  CommentTableHeaderView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/15.
//

import UIKit

class CommentTableHeaderView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.backgroundView?.backgroundColor = .white
    }

}
