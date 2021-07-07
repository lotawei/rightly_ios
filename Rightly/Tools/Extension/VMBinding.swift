//
//  VMBindType.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
protocol VMBinding {
    associatedtype  ViewModelType
    var  viewModel:ViewModelType {get set}
    func bindViewModel(to model:ViewModelType)
}
extension VMBinding  where  Self:UIViewController {
    mutating func bindViewModel(to model:Self.ViewModelType){
        self.viewModel = model
    }
}
