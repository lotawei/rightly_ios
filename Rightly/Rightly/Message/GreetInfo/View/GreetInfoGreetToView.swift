//
//  GreetInfoGreetToView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit

class GreetInfoGreetToView: UIView, NibLoadable {
    var viewModel:GreetInfoGreetViewModel?=nil
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var greetInfoView: UIView!
    @IBOutlet weak var requestBtn: UIButton!
    
    @IBOutlet weak var requestBtnWidth: NSLayoutConstraint!
    
    lazy var greetTypeView:GreetTypeInfoView = {
        let typeView = GreetTypeInfoView.loadNibView() ?? GreetTypeInfoView()
        return typeView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpUserhomePage(_:)))
        self.headImageView.addGestureRecognizer(tap)
        self.headImageView.isUserInteractionEnabled = true
        let requestBtnTitle = "Sent_title".localiz()
        self.requestBtn.setTitle(requestBtnTitle.localiz(), for: .normal)
        if self.greetTypeView.superview == nil {
            self.greetInfoView.addSubview(self.greetTypeView)
            self.greetTypeView.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
        
        let titleW = requestBtnTitle.width(font: .systemFont(ofSize: 12), lineBreakModel: .byWordWrapping, maxWidth: screenWidth, maxHeight: 20)
        self.requestBtnWidth.constant = titleW + 24
    }
    @objc func jumpUserhomePage(_ sender:UITapGestureRecognizer){
        if UserManager.isOwnerMySelf(Int64(self.viewModel?.userId ?? "0")) {
            return
        }
        self.jumpUSer(userid:Int64(self.viewModel?.userId ?? "0") ?? 0)
    }

    func bindViewModel(_ viewModel:GreetInfoGreetViewModel) {
        self.viewModel = viewModel
        let headImageURL = URL(string: UserManager.manager.currentUser?.additionalInfo?.avatar?.dominFullPath() ?? "")
        self.headImageView.kf.setImage(with: headImageURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        self.requestBtn.isEnabled = viewModel.isFriended
        self.greetTypeView.bindGreetingData(viewModel.taskInfo, resources: viewModel.resources ?? [], content: viewModel.greetContent, greetingID: viewModel.greetingId)
    }
}
