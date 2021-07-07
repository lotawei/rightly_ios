//
//  MessageToGreetingTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import UIKit

class MessageToGreetingTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var greetInfoView: UIView!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var requestBtnWidth: NSLayoutConstraint!
    var  vmmodel:MessageGreetingViewModel?=nil
    lazy var greetTypeView:GreetTypeInfoView = {
        let typeView = GreetTypeInfoView.loadNibView() ?? GreetTypeInfoView()
        return typeView
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let requestBtnTitle = "Adopted_btn".localiz()
        self.requestBtn.setTitle(requestBtnTitle, for: .normal)
        if self.greetTypeView.superview == nil {
            self.greetInfoView.addSubview(self.greetTypeView)
            self.greetTypeView.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
        
        let titleW = requestBtnTitle.width(font: .systemFont(ofSize: 12), lineBreakModel: .byWordWrapping, maxWidth: screenWidth, maxHeight: 20)
        self.requestBtnWidth.constant = titleW + 24
        let greettap = UITapGestureRecognizer.init(target: self, action: #selector(jumpGreetingDetail(_:)))
        self.greetTypeView.addGestureRecognizer(greettap)
        self.greetTypeView.isUserInteractionEnabled = true
    }
    
    @objc func jumpGreetingDetail(_ sender: Any) {
        guard let greetingid = Int64(self.vmmodel?.greetViewModel?.greetingId ?? "0"), greetingid > 0 else {
            self.getCurrentViewController()?.toastTip("Greeting Delete")
            return
        }
            
        self.jumpGreetingDetail(greetingid: greetingid)
    }
    
    func bindingViewModel(_ viewModel:MessageGreetingViewModel) {
        self.vmmodel = viewModel
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        
        guard let greetViewModel = viewModel.greetViewModel else {
            self.greetTypeView.isHidden = true
            return
        }
        self.greetTypeView.isHidden = false
        self.greetTypeView.bindGreetingData(greetViewModel.taskInfo, resources: greetViewModel.resources ?? [], content: greetViewModel.greetContent, greetingID: viewModel.greetViewModel?.greetingId)
    }
}
