//
//  RightlyTabBar.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/3.
//

import UIKit

class RightlyTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.init(width: screenWidth, height: (68 + safeBottomH))
    }
}
