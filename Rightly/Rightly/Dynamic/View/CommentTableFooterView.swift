//
//  CommentTableFooterView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import UIKit
import RxSwift
import RxCocoa

class CommentTableFooterView: UITableViewHeaderFooterView {
    var disposeBag = DisposeBag()
    var viewModel:CommentDataViewModel? = nil
    
    lazy var moreBtn: UIButton = {
        let resultBtn = UIButton.init(type: .custom)
        resultBtn.setTitle("—— 点击查看更多评论 ——".localiz(), for: .normal)
        resultBtn.setTitle("—— 没有更多评论了 ——".localiz(), for: .disabled)
        resultBtn.setTitleColor(.init(hex: "ACACB5"), for: .normal)
        resultBtn.titleLabel?.font = .systemFont(ofSize: 12)
        resultBtn.addTarget(self, action: #selector(moreBtnAction(_:)), for: .touchUpInside)
        return resultBtn
    }()
    
    lazy var loadingActivity: UIActivityIndicatorView = {
        let resultActivity = UIActivityIndicatorView.init(style: .gray)
        resultActivity.isHidden = true
        return resultActivity
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moreBtnAction(_ sender: UIButton) {
        self.viewModel?.requestReply(block: { (ok) in
        })
    }
    
    func setupView() {
        self.contentView.addSubview(self.moreBtn)
        self.contentView.addSubview(self.loadingActivity)
        
        self.moreBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.loadingActivity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bindingViewModel(_ viewModel:CommentDataViewModel?) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        guard let vm = viewModel else {
            return
        }
        
        if vm.replyNum.value <= 0 {
            self.moreBtn.isHidden = true
            self.loadingActivity.isHidden = true
        }
        
        vm.loading.subscribe(onNext:{[weak self] (state) in
            guard let `self` = self else {return}
            if self.viewModel?.replyNum.value ?? 0 <= 0 {
                self.moreBtn.isHidden = true
                self.loadingActivity.isHidden = true
                return
            }
            
            if !state {
                self.loadingActivity.stopAnimating()
                self.loadingActivity.isHidden = true
                self.moreBtn.isHidden = false
            } else {
                self.loadingActivity.isHidden = false
                self.loadingActivity.startAnimating()
                self.moreBtn.isHidden = true
            }
        }).disposed(by: self.disposeBag)
        
        vm.replyIsOver.subscribe(onNext:{[weak self] (state) in
            guard let `self` = self else {return}
            self.moreBtn.isEnabled = !state
        }).disposed(by: self.disposeBag)
    }
}
