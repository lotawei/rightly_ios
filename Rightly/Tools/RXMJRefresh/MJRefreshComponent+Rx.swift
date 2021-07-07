//
//  MJRefreshComponent+Rx.swift
//  RxMJ
//
//  Created by lotawei on 2021/2/28.
//

import Foundation
import class MJRefresh.MJRefreshComponent
import RxSwift
import RxCocoa

public extension Reactive where Base: MJRefreshComponent {
    
    var refreshing: ControlEvent<Void> {
        let source = Observable<Void>.create { [weak control = self.base] observer in
            if let control = control {
                control.refreshingBlock = {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
}
