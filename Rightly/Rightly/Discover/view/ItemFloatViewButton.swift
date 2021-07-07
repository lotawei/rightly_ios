//
//  ItemFloatViewButton.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/22.
//

import Foundation
import UIKit
enum FloatStyle {
    case joinVote,
         joinMatch
         
}
class ItemFloatViewButton:UIButton{
    var bgLayer1 = CALayer()
    var  style:FloatStyle = .joinMatch
    fileprivate   var iconTagV:UIImageView = UIImageView.init()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    func setConfigStyle(_ style:FloatStyle){
        self.style = style
        var title = ""
        var  iconImage:UIImage? = nil
        switch style {
        case .joinVote:
            title = "Join vote".localiz()
            iconImage = UIImage.init(named: "discover_join_vote_new")
        case .joinMatch:
            title = "Join topic".localiz()
            iconImage = UIImage.init(named: "discover_join_topic_new")
        }
        self.clipsToBounds = true
        self.adjustsImageWhenHighlighted = false
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .selected)
        self.setTitle(title, for: [.selected,.highlighted ])
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(.white, for: [.selected,.highlighted])
        self.setImage(iconImage, for: .normal)
        self.setImage(iconImage, for: .selected)
        self.setImage(iconImage, for: [.selected,.highlighted])
    }
    
    func imageTag(_ img:UIImage)  {
        iconTagV.removeFromSuperview()
        self.imageView?.addSubview(iconTagV)
        iconTagV.image = img
        iconTagV.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(12)
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 16
        self.layoutButton(style: .Left, imageTitleSpace: 4)
        self.layoutLayerEffect(style: self.style)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func layoutLayerEffect(style:FloatStyle)  {
        // shadowCode
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        if style == .joinMatch {
            self.backgroundColor = UIColor(red: 1, green: 0.35, blue: 0.75, alpha: 1)
            self.layer.shadowColor = UIColor(red: 0.98, green: 0, blue: 0.56, alpha: 0.28).cgColor
        }else{
            self.backgroundColor =  UIColor(red: 0.14, green: 0.83, blue: 0.82, alpha: 1)
            self.layer.shadowColor = UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.5).cgColor
        }
    }
   
}
