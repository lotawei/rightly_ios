//
//  PersonalOtherUnlockMoreView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/22.
//

import Foundation
import Reusable

class PersonalOtherUnlockMoreCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var lblemtpty: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        lblemtpty.text = "Unlock homepage see more dynamic".localiz()
    }
    
    
}
