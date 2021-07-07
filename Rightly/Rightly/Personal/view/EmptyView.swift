//
//  EmptyView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import UIKit
class EmptyView:UIView,NibLoadable {
    @IBOutlet weak var placeimage: UIImageView!
    @IBOutlet weak var lblcontent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblcontent.text = "No content.".localiz()
    }
}
