//
//  DynamicVideoTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/27.
//

import UIKit

class DynamicVideoTableViewCell: DynamicBaseTableViewCell {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoWidth: NSLayoutConstraint!
    
    @IBAction func playBtnAction(_ sender: UIButton) {
        if let resourceViewModel = self.viewModel?.resourceViewModel, let contentURL = resourceViewModel.contentURL {
            self.preViewVideo(url: contentURL, cover: resourceViewModel.previewURL)
        } else {
            #warning("弹出视频无法播放警告")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func bindingViewModel(_ viewModel:DynamicDataViewModel, _ listType:DynamicListType, _ isLastCell:Bool) {
        super.bindingViewModel(viewModel, listType, isLastCell)
        self.customContentViewHeight.constant = viewModel.customViewSize.height
        self.videoWidth.constant = viewModel.customViewSize.width
        
        if let imgPreViewurl = viewModel.resourceViewModel?.previewURL {
            self.previewImageView.kf.setImage(with:imgPreViewurl,placeholder: placehodlerImg,options: webpOptional)
        }
    }
}
