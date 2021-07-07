//
//  DynamicUnlockFooterView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/8.
//

import UIKit

class DynamicUnlockFooterView: UIView, NibLoadable {
    var gradientLayer:CAGradientLayer!
    @IBOutlet weak var lockTitleBtn: UIButton!
    var  userId:String?=nil
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lockTitleBtn.setTitle("Unlock homepage see more dynamic".localiz(), for: .normal)
        self.lockTitleBtn.setTitle("Unlock homepage see more dynamic".localiz(), for: .selected)
        self.lockTitleBtn.setTitle("Unlock homepage see more dynamic".localiz(), for: .highlighted)
        self.lockTitleBtn.setImage(UIImage.init(named: "iconlock"), for: .normal)
        self.lockTitleBtn.setImage(UIImage.init(named: "iconlock"), for: .selected)
        self.lockTitleBtn.setImage(UIImage.init(named: "iconlock"), for: .highlighted)
        self.lockTitleBtn.layer.cornerRadius = 24
        self.lockTitleBtn.layer.backgroundColor = themeBarColor.cgColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.lockTitleBtn.layoutButton(style: .Left, imageTitleSpace: 5)
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [themeBarColor.cgColor,
                                UIColor.init(hex: "00E5FF").cgColor]
        gradientLayer.frame = self.lockTitleBtn.bounds;
        gradientLayer.locations = [0, 0.15, 1]
        self.lockTitleBtn.layer.mask = gradientLayer
    }
    @IBAction func jumpTabar(_ sender:Any){
        guard let uid = userId else {
            return
        }
        GlobalRouter.shared.dotaskUser(Int64(uid) ?? 0)
    }
}
