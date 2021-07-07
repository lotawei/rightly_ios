//
//  ScrollerView+Bottom.swift
//  LiveKit
//
//  Created by 伟龙 on 2020/7/8.
//  Copyright © 2020 dfsx6. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height > self.frame.size.height {
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
            self.setContentOffset(bottomOffset, animated: animated)
        }
    }
}
