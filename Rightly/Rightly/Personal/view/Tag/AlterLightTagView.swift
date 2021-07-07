//
//  AlterLightTagView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/27.
//

import Foundation
class AlterLightTagView:UIView,NibLoadable {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var largetitle: UILabel!
    @IBOutlet weak var surebtn: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    var doneBlock:SuresuccessBlock?=nil
    override func awakeFromNib() {
        super.awakeFromNib()
        surebtn.setTitle("Go Light".localiz(), for: .normal)
        largetitle.text = "Light Tag".localiz()
        subtitle.text = "Release tag and light the tag".localiz()
    }
    
    @IBAction func doneBlockclick(_ sender: Any) {
        
        doneBlock?()
        
        self.removeFromWindow()

    }
    
}
