//
//  LanuageSwitchView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/19.
//

import Foundation

class LanuageSwitchView: UIView,NibLoadable {
    var   changeLanguage:((_ tag:Int) -> Void)?=nil
    @IBOutlet var itemsbtn: [UIButton]!
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        for i in 0..<itemsbtn.count {
            itemsbtn[i].tag = i
        }
        
    }
    @IBAction func changeAction(_ sender: UIButton) {
        
        self.changeLanguage?(sender.tag)
        self.removeFromWindow()
    }
    
}
