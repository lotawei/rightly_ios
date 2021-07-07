//
//  MessageToVideoTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/7.
//

import UIKit
import RxSwift
import UICircularProgressRing

class MessageToVideoTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    var viewModel:MessageVideoViewModel? = nil
    
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var faileBtn: UIButton!
    @IBOutlet weak var priviewImageView: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoWidth: NSLayoutConstraint!
    @IBOutlet weak var videoHeight: NSLayoutConstraint!
    
    lazy var progressView:UICircularProgressRing = {
        let resultView = UICircularProgressRing(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        resultView.backgroundColor = .clear
        resultView.style = .ontop
        resultView.maxValue = 100   // 最大值
        resultView.fontColor = .white // 进度值的显示颜色
        resultView.font = .systemFont(ofSize: 10, weight: .medium)
        resultView.innerCapStyle = .round   // 内环圆头
        resultView.innerRingWidth = 5   // 内环宽度
        resultView.innerRingSpacing = 0
        resultView.innerRingColor = .white // 进度条颜色
        resultView.outerRingWidth = 5 // 外环宽度
        resultView.outerRingColor = UIColor.gray
        return resultView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.progressView.superview == nil {
            self.videoView.addSubview(self.progressView)
            self.progressView.isHidden = true
            self.progressView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32))
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupViewTag(_ tag:Int) {
        self.playBtn.tag = tag
        self.faileBtn.tag = tag
    }
    
    func bindingViewModel(_ viewModel:MessageVideoViewModel) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        self.headImageView.kf.setImage(with: viewModel.userHeadURL, placeholder: placeHeadImg)
        self.videoWidth.constant = viewModel.videoSize?.width ?? 150
        self.videoHeight.constant = viewModel.videoSize?.height ?? 150
        
        priviewImageView.kf.setImage(with: viewModel.coverURL, placeholder: nil, options: nil, completionHandler: nil)
        
        viewModel.sendStatus.subscribe(onNext: { [weak self] status in
            guard let `self` = self else {return}
            self.faileBtn.isHidden = (status != .failure)
            self.progressView.isHidden = (status != .sending)
            self.playBtn.isHidden = (status != .sended)
        }).disposed(by: self.disposeBag)
        
        viewModel.progress.subscribe(onNext: { [weak self] newProgress in
            guard let `self` = self else {return}
            self.progressView.value = CGFloat(newProgress)
        }).disposed(by: self.disposeBag)
    }
}
