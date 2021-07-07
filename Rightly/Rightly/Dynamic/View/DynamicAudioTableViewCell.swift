//
//  DynamicAudioTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/27.
//

import UIKit

class DynamicAudioTableViewCell: DynamicBaseTableViewCell {

    @IBOutlet weak var audioWidth: NSLayoutConstraint!
    
    @IBOutlet weak var audioTimeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func bindingViewModel(_ viewModel:DynamicDataViewModel, _ listType:DynamicListType, _ isLastCell:Bool) {
        super.bindingViewModel(viewModel, listType, isLastCell)
        self.customContentViewHeight.constant = viewModel.customViewSize.height
        self.audioWidth.constant = viewModel.customViewSize.width
        self.audioTimeLabel.text = String(lroundf(viewModel.resourceViewModel?.duration_f ?? 0)) + "''"
        
        viewModel.isPlaying.subscribe { (playing) in
            self.playBtn.isSelected = playing
        }.disposed(by: self.disposeBag)
    }
}
