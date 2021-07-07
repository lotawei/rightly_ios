//
//  FollowUIButton.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/2.
//

import Foundation
import UIKit
@IBDesignable
class FollowUIButton:UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
        setConfigStyle()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfigStyle()
    }
    func setConfigStyle(){
        let norImage = UIImage.createSolidImage(color: themeBarColor, size: CGSize(width: 56, height: 28))
        let selImage = UIImage.createSolidImage(color: UIColor.white, size: CGSize(width: 56, height: 28))
        // 选中后高亮 会变成个普通
        //解决方案
        self.adjustsImageWhenHighlighted = false
        self.setBackgroundImage(norImage, for: .normal)
        self.setBackgroundImage(selImage, for: .selected)
        self.setBackgroundImage(selImage, for: [.selected,.highlighted ])
        self.setTitle("Follow".localiz(), for: .normal)
        self.setTitle("UnFollow".localiz(), for: .selected)
        self.setTitle("UnFollow".localiz(), for: [.selected,.highlighted ])
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(themeBarColor, for: .selected)
        self.setTitleColor(themeBarColor, for:[.selected,.highlighted ])
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.borderColor = themeBarColor.cgColor
        self.layer.borderWidth = 1
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
}
