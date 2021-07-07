//
//  GreetInfoTaskToView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit

class GreetInfoTaskToView: UIView, NibLoadable {
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var bodyview: UIView!
    var taskTipView:NewMessageTaskTipView? = NewMessageTaskTipView.loadNibView()
    override func awakeFromNib() {
        super.awakeFromNib()
        if let tasktipv = self.taskTipView {
            self.bodyview.addSubview(tasktipv)
            tasktipv.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
    }
    
    func bindViewModel(_ viewModel:GreetInfoGreetViewModel) {
        let headImageURL = URL(string: UserManager.manager.currentUser?.additionalInfo?.avatar?.dominFullPath() ?? "")
        self.headImageView.kf.setImage(with: headImageURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        
        if let taskinfo = viewModel.taskInfo {
            self.taskTipView?.setUserTask(taskinfo)
        }
    }
}
