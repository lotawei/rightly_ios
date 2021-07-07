//
//  MessageFromAudioTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import UICircularProgressRing
import RxSwift

class MessageFromAudioTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var faileBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    var  vmmodel:MessageAudioViewModel?=nil
    @IBOutlet weak var playStatusImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var audioDurationLabel: UILabel!
    @IBOutlet weak var audioWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var tempBubbleImage = UIImage.init(named: "message_other_bubble")
        let tb:CGFloat = (tempBubbleImage?.size.height)! * 3.0 / 8.0
        let lr:CGFloat = (tempBubbleImage?.size.width)! * 29.0 / 68.0
        tempBubbleImage = tempBubbleImage?.resizableImage(withCapInsets: UIEdgeInsets(top: tb, left: lr, bottom: tb, right: lr), resizingMode: .stretch)
        self.bubbleImageView.image = tempBubbleImage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupViewTag(_ tag:Int) {
        self.playBtn.tag = tag
        self.headBtn.tag = tag
        self.faileBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageAudioViewModel) {
        self.vmmodel = viewModel
        self.disposeBag = DisposeBag()
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: UIImage(named: "default_head_image"), options: nil, completionHandler: nil)
        self.audioWidth.constant = viewModel.audioWidth ?? 0
        self.audioDurationLabel.text = viewModel.durationStr
        
        viewModel.receiveStatus.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.faileBtn.isHidden = (status != .failure)
            self.activityIndicator.isHidden = (status != .receiving)
            self.playBtn.isUserInteractionEnabled = (status == .received)
            if status == .receiving {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.isPlaying.subscribe(onNext : { playing in
            self.playStatusImageView.isHighlighted = playing
        }).disposed(by: self.disposeBag)
    }
}
