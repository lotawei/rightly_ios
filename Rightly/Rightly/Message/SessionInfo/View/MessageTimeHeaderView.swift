//
//  MessageTimeHeaderView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/18.
//

import UIKit

class MessageTimeHeaderView: UITableViewHeaderFooterView {
    let timeLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 22))
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.timeLabel.textAlignment = .center
        self.timeLabel.textColor = .init(hex: "ACACB5")
        self.timeLabel.font = .systemFont(ofSize: 12)
        self.timeLabel.backgroundColor = .white
        self.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
