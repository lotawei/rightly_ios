//
//  MessageToTaskTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import UIKit

class MessageToTaskTableViewCell: UITableViewCell {
    let titleView = GreetInfoTitleView.loadNibView() ?? GreetInfoTitleView()
    @IBOutlet weak var bodyview: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    var  vmmodel:MessageTaskViewModel?=nil
    var taskTipView:NewMessageTaskTipView? = NewMessageTaskTipView.loadNibView()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.titleView.superview == nil {
            self.contentView.addSubview(self.titleView)
            
            self.titleView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(0)
                make.height.equalTo(60)
            })
        }
        if let tasktipv = self.taskTipView {
            self.bodyview.addSubview(tasktipv)
            tasktipv.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindingViewModel(_ viewModel:MessageTaskViewModel) {
        self.vmmodel = viewModel
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg, options: nil, completionHandler: nil)
        
        self.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: viewModel.userName ?? "other")
        
        if let taskinfo = viewModel.greetViewModel?.taskInfo {
            self.taskTipView?.setUserTask(taskinfo)
        }
    }
}
