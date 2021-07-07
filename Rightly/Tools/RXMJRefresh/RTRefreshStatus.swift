//
//  RTRefreshStatus.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/16.
//

import Foundation
public enum RTRefreshStatus {
    case idleNone
    case beingHeaderRefresh
    case endHeaderRefresh
    case beingFooterRefresh
    case endFooterRefresh
    case noMoreData
}

public enum RTRequestStatus {
    case freeRequest
    case requesting
    case noMoreData
}

