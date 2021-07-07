//
//  GreetInfoTaskFromView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit

class GreetInfoTaskFromView: UIView, NibLoadable {
    var vmmodel:GreetInfoGreetViewModel?=nil
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var typeIconImageView: UIImageView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskContentLabel: UILabel!
    @IBOutlet weak var bodyview: UIView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var doTaskBtnsView: UIView!
    @IBOutlet weak var doItNowBtn: UIButton!
    @IBOutlet weak var choosePostBtn: UIButton!
    
    @IBOutlet weak var taskViewBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doItNowBtn.setTitle("Do it now".localiz(), for: .normal)
        self.choosePostBtn.setTitle("Choose from post".localiz(), for: .normal)
    }
    func bindViewModel(_ viewModel:GreetInfoGreetViewModel, friendStatus:FriendType, userInfo:UserAdditionalInfo) {
        self.vmmodel = viewModel
        let headImageURL = URL(string: userInfo.avatar?.dominFullPath() ?? "")
        self.headImageView.kf.setImage(with: headImageURL, placeholder: UIImage(named: userInfo.gender?.defHeadName ?? ""), options: nil, completionHandler: nil)
        
        self.bgImageView.image = viewModel.taskInfo?.type.typeCenterTaskIconImage()
        self.bodyview.backgroundColor = viewModel.taskInfo?.type.taskNewVersionColor()
        self.taskTitleLabel.text = viewModel.taskInfo?.type.typeTitle()
        self.typeIconImageView.image = UIImage(named: viewModel.taskInfo?.type.typeTitleIconName() ?? "")
        self.taskContentLabel.text = viewModel.taskInfo?.descriptionField
        
        if friendStatus == .irrelevant {
            self.taskViewBottom.constant = 104
            self.doTaskBtnsView.isHidden = false
        } else {
            self.taskViewBottom.constant = 8
            self.doTaskBtnsView.isHidden = true
        }
    }
    
}
