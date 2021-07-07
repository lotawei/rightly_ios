//
//  YHDragCardCell.swift
//  Pods
//
//  Created by apple on 2020/4/21.
//

import UIKit

@objc open class YHDragCardCell: UIView {
    @objc public var reuseIdentifier: String = ""
    @objc public init(reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: .zero)
        self.yh_reuseIdentifier = reuseIdentifier
        self.yh_internalIdentifier = UUID().uuidString
        self.yh_is_reuse = false
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
