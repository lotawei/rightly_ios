//
//  EmptyPagePlaceHolderView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/22.
//

import Foundation
import UIKit
class EmptyPagePlaceHolderView:UIView{
    fileprivate lazy var backimgview:UIImageView = {
        let  imageview = UIImageView.init(frame:.zero)
        imageview.contentMode = .scaleToFill
        imageview.image =   UIImage(named:"empty_page_placehodler", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        return imageview
    }()
    lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "notif_empt".localiz()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backimgview)
        self.backimgview.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(140)
            maker.top.equalToSuperview().offset(35)
            maker.centerX.equalToSuperview()
        }
        self.addSubview(self.mainLabel)
        self.mainLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.width.equalTo(120)
            maker.height.equalTo(40)
            maker.top.equalTo(self.backimgview.snp.bottom).offset(16)
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
