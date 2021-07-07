//
//  SessionNewGreetTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/25.
//

import UIKit

class SessionNewGreetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var unreadNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.text = "new_greeting_cell".localiz()
        self.contentLabel.text = "no_new_greeting".localiz()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindViewModel(_ viewModel:SessionListGreetViewModel) {
        viewModel.unreadCount.subscribe(onNext:{ (newValue) in
            self.unreadView.isHidden = newValue <= 0
            self.unreadNumLabel.text = newValue >= 100 ? "99+" : newValue.description
            
            if newValue <= 0 {
                self.contentLabel.text = "no_new_greeting".localiz()
            } else {
                self.contentLabel.text = "there_are_new_greeting".localiz().replacingOccurrences(of: "%1$s", with: "\(newValue)")
            }
        }).disposed(by: self.rx.disposeBag)
    }
}
