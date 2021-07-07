//
//  NibLoadable.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
import UIKit
public protocol NibLoadable:AnyObject {
    static var myNib:UINib? {get}
    
}
public extension  NibLoadable {
    static var  myNib:UINib? {
        let bundle = Bundle.init(for: self)
        let nibName = String.init(describing: self)
        guard let _ = bundle.path(forResource: nibName, ofType: "nib") else {
            debugPrint("can not found nib resource")
            return nil
            
        }
        return  UINib.init(nibName: nibName, bundle: bundle)
    }
}

extension  NibLoadable where Self:UIView{
    static func  loadNibView() -> Self? {
        guard let nib = myNib else {
            return nil
        }
        guard let firstview = nib.instantiate(withOwner: nil, options: nil).first else {
            debugPrint("-- nib can not found")
            return nil
        }
        guard  let nibview = firstview as? Self else {
            debugPrint("--- file associate error")
            return nil
        }
        return nibview
    }
    
}
extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: .main)
        }
        return instantiateFromNib()
    }
}
