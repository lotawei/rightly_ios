//
//  UnlockUserAlterView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/20.
//

import Foundation
class UnlockUserAlterView:UIView,NibLoadable {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var largetitle: UILabel!
    @IBOutlet weak var surebtn: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    var doneBlock:SuresuccessBlock?=nil
    override func awakeFromNib() {
        super.awakeFromNib()
        surebtn.setTitle("go now".localiz(), for: .normal)
        displayerInfo()
    }
    func displayerInfo()  {
        largetitle.text = "Congratulate".localiz()
        subtitle.text = "it`s great,you unlock his homepage,enjoy seeing".localiz()

    }
    
    @IBAction func doneBlockclick(_ sender: Any) {
        doneBlock?()
        self.removeFromWindow()

    }
   
}
