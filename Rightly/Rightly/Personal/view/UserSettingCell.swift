//
//  SettingCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
class UserSettingCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var lbltxt: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    
}

