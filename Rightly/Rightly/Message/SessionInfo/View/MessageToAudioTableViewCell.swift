//
//  MessageToAudioTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwift

class MessageToAudioTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var viewModel:MessageAudioViewModel? = nil
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var faileBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playStatusImageView: UIImageView!
    
    @IBOutlet weak var audioDurationLabel: UILabel!
    @IBOutlet weak var audioWidth: NSLayoutConstraint!

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

        // Configure the view for the selected state
    }
    
    func setupViewTag(_ tag:Int) {
        self.faileBtn.tag = tag
        self.playBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageAudioViewModel) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg)
        self.audioWidth.constant = viewModel.audioWidth ?? 0
        self.audioDurationLabel.text = viewModel.durationStr
        
        viewModel.isPlaying.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.playStatusImageView.isHighlighted = status
        }).disposed(by: self.disposeBag)
        
        viewModel.sendStatus.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.faileBtn.isHidden = (status != .failure)
            self.activityIndicator.isHidden = (status != .sending)
            if status == .sending {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }).disposed(by: self.disposeBag)
    }
}
