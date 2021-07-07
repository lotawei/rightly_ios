//
//  EmptyPublicTagView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/29.
//

import Foundation
class EmptyPublicTagView:UIView,NibLoadable {
    
    @IBOutlet weak var lblemptyDes: UILabel!
    @IBOutlet weak var lblemptitle: UILabel!
    @IBOutlet weak var lbltip: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lbltip.text = "Public".localiz()
        self.lblemptitle.text  = "Empty Public Tag".localiz()
        self.lblemptyDes.text = "Release the tag and light the tag , will be public".localiz()
        
    }
}
