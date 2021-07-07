//
//  MessageFromTaskTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import UIKit

class MessageFromTaskTableViewCell: UITableViewCell {
    let titleView = GreetInfoTitleView.loadNibView() ?? GreetInfoTitleView()
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var bodyview: UIView!
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
    
    func setupViewTag(_ tag:Int) {
        self.headBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageTaskViewModel) {
        self.vmmodel = viewModel
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        self.titleView.titleLabel.text = "you_and_other_link_title".localiz().replacingOccurrences(of: "%1$s", with: viewModel.userName ?? "other")
        
        if let taskinfo = viewModel.greetViewModel?.taskInfo {
            self.taskTipView?.setUserTask(taskinfo)
        }
    }
}
