//
//  GreetInfoGreetFromView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/24.
//

import UIKit

class GreetInfoGreetFromView: UIView, NibLoadable {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var greetInfoView: UIView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var headBtn: UIButton!
    var vmmodel:GreetInfoGreetViewModel?=nil
    lazy var greetTypeView:GreetTypeInfoView = {
        let typeView = GreetTypeInfoView.loadNibView() ?? GreetTypeInfoView()
        return typeView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.acceptBtn.setTitle("Accpet_Message_btn".localiz(), for: .normal)
        if self.greetTypeView.superview == nil {
            self.greetInfoView.addSubview(self.greetTypeView)
            self.greetTypeView.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpGreetingDetail(_:)))
        self.greetTypeView.addGestureRecognizer(tap)
        self.greetTypeView.isUserInteractionEnabled = true
    }
    @objc func jumpGreetingDetail(_ sender: Any) {
        guard let greetingid = self.vmmodel?.greetingId else {
            self.getCurrentViewController()?.toastTip("Greeting Delete".localiz())
            return
        }
    
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        
        let ctrl = DynamicDetailsViewController.init(greetingid)
        currentvc.navigationController?.pushViewController(ctrl, animated: true)
    }
    func bindViewModel(_ viewModel:GreetInfoGreetViewModel, userInfo:UserAdditionalInfo) {
        vmmodel = viewModel
        let headImageURL = URL(string: userInfo.avatar?.dominFullPath() ?? "")
        self.headImageView.kf.setImage(with: headImageURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        self.greetTypeView.bindGreetingData(viewModel.taskInfo, resources: viewModel.resources ?? [], content: viewModel.greetContent, greetingID: viewModel.greetingId)
    }
}
