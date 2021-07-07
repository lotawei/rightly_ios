//
//  MessageFromImageTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import UICircularProgressRing
import RxSwift

class MessageFromImageTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var faileBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    var  vmmodel:MessageImageViewModel?=nil
    @IBOutlet weak var photoWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupViewTag(_ tag:Int) {
        self.imageBtn.tag = tag
        self.headBtn.tag = tag
        self.faileBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageImageViewModel) {
        self.vmmodel = viewModel
        self.disposeBag = DisposeBag()
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        self.photoImageView.kf.setImage(with: viewModel.thumbURL, placeholder: UIImage(named: "message_placeholder_image"), options: nil) { (result) in
            switch result {
            case .success(_):
                debugPrint("获取图片成功")
            case .failure(_):
                self.photoImageView.image = UIImage.init(named: "message_im_image_failure_icon")
            }
        }
        
        self.photoWidth.constant = viewModel.imageSize?.width ?? 150.0
        
        viewModel.receiveStatus.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.faileBtn.isHidden = (status != .failure)
        }).disposed(by: self.disposeBag)
    }
}
