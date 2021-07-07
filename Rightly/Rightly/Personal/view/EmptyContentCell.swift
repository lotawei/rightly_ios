//
//  EmptyOtherCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/14.
//

import Foundation
import Foundation
import Reusable
import RxSwift
import RxCocoa
class EmptyContentCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var lblemtpty: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        lblemtpty.text = "No content.".localiz()
        
    }
    
    
}

