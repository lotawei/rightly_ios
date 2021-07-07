//
//  CountryCategoryView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/28.
//

import UIKit

class CountryCategoryView: UITableViewHeaderFooterView {
    let categoryLabel:UILabel = UILabel()
    
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
        self.categoryLabel.font = .systemFont(ofSize: 14)
        self.categoryLabel.textColor = .init(white: 0, alpha: 0.2)
        
        self.contentView.addSubview(self.categoryLabel)
        self.categoryLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.left.equalTo(24)
        }
    }
}
