//
//  ResourceContainerView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/26.
//

import Foundation
enum ContaineerStyle:Int{
    case oneBig  = 0,
         twoDoubleLine = 1, //四宫格
         threeStyle = 2 //九宫格
         
}
class ResourcePhotoAndPictureContainerView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
