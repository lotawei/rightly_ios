//
//  MJRefreshFooter+Rx.swift
//  RxMJ
//
//  Created by lotawei on 2021/2/28.
//

import Foundation
import class MJRefresh.MJRefreshFooter
import RxSwift
import RxCocoa

public enum RxMJRefreshFooterState {
    
    case `default`
    case noMoreData
    case hidden
}

extension RxMJRefreshFooterState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .default: return "default"
        case .noMoreData: return "No content."
        case .hidden: return "hidden"
        }
    }
}

extension RxMJRefreshFooterState: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return description
    }
}

public extension Reactive where Base: MJRefreshFooter {
    
    var refreshFooterState: Binder<RxMJRefreshFooterState> {
        return Binder(base) { footer, state in
            switch state {
            case .default:
                footer.isHidden = false
                footer.resetNoMoreData()
            case .noMoreData:
                footer.isHidden = false
                footer.endRefreshingWithNoMoreData()
            case .hidden:
                footer.isHidden = true
                footer.resetNoMoreData()
            }
        }
    }
}

