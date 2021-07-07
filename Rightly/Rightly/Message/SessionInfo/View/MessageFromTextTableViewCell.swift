//
//  MessageFromTextTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit

class MessageFromTextTableViewCell: UITableViewCell {
    var viewModel:MessageTextViewModel? = nil

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    lazy var bubbleImg: UIImage? = {
        var tempBubbleImage = UIImage.init(named: "message_other_bubble")
        let tb:CGFloat = (tempBubbleImage?.size.height)! * 3.0 / 8.0
        let lr:CGFloat = (tempBubbleImage?.size.width)! * 29.0 / 68.0
        tempBubbleImage?.resizableImage(withCapInsets: UIEdgeInsets(top: tb, left: lr, bottom: tb, right: lr), resizingMode: .stretch)
        return tempBubbleImage
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bubbleImageView.image = self.bubbleImg
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupViewTag(_ tag:Int) {
        self.headBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageTextViewModel) {
        self.viewModel = viewModel
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg, options: nil, completionHandler: nil)
        self.contentLabel.attributedText = viewModel.content
    }
}
