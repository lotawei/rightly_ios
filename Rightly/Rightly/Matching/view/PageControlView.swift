//
//  PageControlView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/7.
//

import Foundation
import UIKit

enum PageControlResourceImg:String {
    case unlockimg = "unlockimg",
         current  = "current",
         lock  = "lock",
         lockselected = "lockselected"
}


class PageControlView: UIView {
    
    var  selectType:PageControlResourceImg = .unlockimg {
        didSet {
            self.configImage()
        }
        
    }
    lazy var  itemButton:UIButton = {
        let btn = UIButton.init(type: .custom)
        
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setsubView()
    }
    func  setsubView(){
        self.addSubview(self.itemButton)
        self.itemButton.cornerRadius = 4
        self.itemButton.snp.makeConstraints { (maker) in
            maker.left.right.bottom.top.equalToSuperview()
        }
        
    }
    func configImage() {
        
        self.itemButton.setImage(UIImage.init(named: self.selectType.rawValue), for: .normal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
