//
//  CommentTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import UIKit
import RxSwift

class CommentTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var viewModel:CommentDataViewModel? = nil
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var userNickName: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var replyBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindingViewModel(_ viewModel:CommentDataViewModel) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg)
        self.userNickName.text = viewModel.userName
        self.contentLabel.text = viewModel.content
        self.timeLabel.text = viewModel.timeDesc
    }
    
}
