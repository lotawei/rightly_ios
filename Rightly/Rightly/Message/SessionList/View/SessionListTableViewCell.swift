//
//  SessionListTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/5.
//

import UIKit
import NIMSDK
import Kingfisher
import RxSwift
import RxCocoa

class SessionListTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var unreadNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindViewModel(_ viewModel:SessionListCellViewModel) {
        self.disposeBag = DisposeBag()
        
        contentLabel.attributedText = viewModel.contentAttri
        viewModel.userName.subscribe(onNext:{ [weak self] name in
            guard let `self` = self else {return}
            self.nickNameLabel.text = name
        }).disposed(by: self.disposeBag)
        
        viewModel.userHeadURL.subscribe(onNext:{ [weak self] headURL in
            guard let `self` = self else {return}
            self.headImageView.kf.setImage(with: headURL, placeholder: UIImage(named: "default_head_image"), options: nil, progressBlock: nil, completionHandler: nil)
        }).disposed(by: self.disposeBag)
        
        let tempTime = viewModel.timeStamp > maxTimeStamp ? (viewModel.timeStamp / 1000.0) : viewModel.timeStamp
        let tempDate = Date.init(timeIntervalSince1970:tempTime)
        let nowTime = Date.init().timeIntervalSince1970
        if Int(tempTime / (24.0 * 3600.0)) == Int(nowTime / (24.0 * 3600.0)) {
            timeLabel.text = tempDate.conversionAmPm("a hh:mm")
        } else {
            timeLabel.text = tempDate.conversionAmPm("yyyy-MM-dd hh:mm a")
        }
        
        viewModel.unreadCount.subscribe(onNext : { (unreadCount) in
            self.unreadView.isHidden = unreadCount <= 0
            self.unreadNumLabel.text = unreadCount.description
        }).disposed(by: self.rx.disposeBag)
    }
}
