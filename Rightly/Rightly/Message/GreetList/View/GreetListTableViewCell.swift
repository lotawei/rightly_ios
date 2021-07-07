//
//  GreetListTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit

class GreetListTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var greetInfoView: UIView!
    
    lazy var greetTypeView:GreetTypeInfoView = {
        let typeView = GreetTypeInfoView.loadNibView() ?? GreetTypeInfoView()
        return typeView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentLabel.text = "finished_your_chat_up_task".localiz()
        
        if self.greetTypeView.superview == nil {
            self.greetInfoView.addSubview(self.greetTypeView)
            self.greetTypeView.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindViewModel(_ viewModel:FriendViewModel) {
        self.headImageView.kf.setImage(with: URL.init(string: viewModel.userInfo?.avatar?.dominFullPath() ?? ""), placeholder: placeHeadImg, options: nil, completionHandler: nil)
        self.userNameLabel.text = viewModel.userInfo?.nickname
        
        self.timeLabel.text = viewModel.updateDate?.conversionAmPm("yyyy-MM-dd hh:mm:ss a")
        
        self.greetTypeView.bindGreetingData(viewModel.taskInfo, resources: viewModel.resources ?? [], content: viewModel.greetContent, greetingID: viewModel.greetingId)
    }
}
