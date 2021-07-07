//
//  UITableView+EmptyDisplay.swift
//  LiveKit
//
//  Created by 伟龙 on 2020/6/3.
//  Copyright © 2020 dfsx6. All rights reserved.
//

import Foundation
import UIKit

//主要用于显示空列表

private let EMPTYTAG = 989899;

protocol EmptyViewProtocol: NSObjectProtocol {

    ///用以判断是会否显示空视图
    var showEmtpy: Bool {get}

    ///配置空数据提示图用于展示
    func configEmptyView() -> UIView?
}

extension EmptyViewProtocol {

    func configEmptyView() -> UIView? {
        return nil
    }
}


extension UIView {
    func setEmtpyViewDelegate(target: EmptyViewProtocol) {
        self.emptyDelegate = target
        DispatchQueue.once(token:"empty.tableview.quene") {
            let originalSelctor = #selector(self.layoutSubviews)
            let swizzledSelector = #selector(self.re_layoutSubviews)
            NSObject.swizzleMethod(for: self.classForCoder, originalSelector: originalSelctor, swizzledSelector: swizzledSelector)
        }
    }

    @objc func re_layoutSubviews() {
        self.re_layoutSubviews()
        guard let emptydeletage = self.emptyDelegate else {
            return
        }
        if emptydeletage.showEmtpy {

            guard let view = self.emptyDelegate?.configEmptyView() else {
                return;
            }

            if let subView = self.viewWithTag(EMPTYTAG) {
                subView.removeFromSuperview()
            }

            view.tag = EMPTYTAG;
            self.addSubview(view)

        } else {

            guard let view = self.viewWithTag(EMPTYTAG) else {
                return;
            }
            view .removeFromSuperview()
        }
    }

    //MARK:- ***** Associated Object *****
    private struct AssociatedKeys {
        static var emptyViewDelegate = "emptyViewDelegate"
    }

    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.emptyViewDelegate) as? EmptyViewProtocol)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.emptyViewDelegate, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }



}
