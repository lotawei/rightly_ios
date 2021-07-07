//
//  MessageToTextTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import RxSwift
import RxSwift

class MessageToTextTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var viewModel:MessageTextViewModel? = nil
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var faileBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var tempBubbleImage = UIImage.init(named: "message_me_bubble")
        let tb:CGFloat = (tempBubbleImage?.size.height)! * 3.0 / 8.0
        let lr:CGFloat = (tempBubbleImage?.size.width)! * 29.0 / 68.0
        tempBubbleImage = tempBubbleImage?.resizableImage(withCapInsets: UIEdgeInsets(top: tb, left: lr, bottom: tb, right: lr), resizingMode: .stretch)
        self.bubbleImageView.image = tempBubbleImage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupViewTag(_ tag:Int) {
        self.faileBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageTextViewModel) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg)
        self.contentLabel.attributedText = viewModel.content
        
        viewModel.sendStatus.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.faileBtn.isHidden = (status != .failure)
            if status == .sending {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }).disposed(by: self.disposeBag)
    }
}
