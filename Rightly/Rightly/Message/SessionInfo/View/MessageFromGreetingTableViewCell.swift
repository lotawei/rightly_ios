//
//  MessageFromGreetingTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/6.
//

import UIKit

class MessageFromGreetingTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var greetInfoView: UIView!
    @IBOutlet weak var acceptBtn: UIButton!
    var  vmmodel:MessageGreetingViewModel?=nil
    lazy var greetTypeView:GreetTypeInfoView = {
        let typeView = GreetTypeInfoView.loadNibView() ?? GreetTypeInfoView()
        return typeView
    }()
    var  userid:String? = nil{
        didSet {
            debugPrint("------llllllll\(userid)")
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.acceptBtn.setTitle("Adopted_btn".localiz(), for: .normal)
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
    
    func setupViewTag(_ tag:Int) {
        self.headBtn.tag = tag
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
