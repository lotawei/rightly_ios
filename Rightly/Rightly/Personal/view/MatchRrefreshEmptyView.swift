//
//  File.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/22.
//

import Foundation
class MatchRrefreshEmptyView:UIView,NibLoadable {
    @IBOutlet weak var placeimage: UIImageView!
    @IBOutlet weak var btncontent: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btncontent.setTitle("NO_More_Data".localiz(), for: .normal)
    }
}
