//
//  CustomScrollerView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/23.
//

import Foundation

typealias TouchesCallBack = (_ point: CGPoint, _ event: UIEvent?) -> Void
class CustomScrollerView: UIScrollView {

    var callback: TouchesCallBack?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delaysContentTouches = false
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        self.delaysContentTouches = false
    }
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: MessageEditRecordView.self) {
            return false
        }
        return true
    }

}
//MARK: - 手势操作
extension CustomScrollerView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
}
extension CustomScrollerView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        callback?(point, event)
        return self
    }
   }
