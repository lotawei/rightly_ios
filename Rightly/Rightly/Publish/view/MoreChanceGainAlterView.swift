//
//  MoreChanceGainAlterView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/22.
//

import Foundation
class MoreChanceGainAlterView:UIView,NibLoadable {
    fileprivate let  matchCount = 10
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var largetitle: UILabel!
    @IBOutlet weak var surebtn: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    var doneBlock:SuresuccessBlock?=nil
    override func awakeFromNib() {
        super.awakeFromNib()
        surebtn.setTitle("eng_ok".localiz(), for: .normal)
        displayerInfo()
    }
    func displayerInfo()  {
        largetitle.text = "Congratulations".localiz()
        subtitle.text = "Completed the system task and got $$ matching opportunities presented by the system".localiz().replacingOccurrences(of: "$$", with: "\(matchCount)")

    }
    
    @IBAction func doneBlockclick(_ sender: Any) {
        doneBlock?()
        self.removeFromWindow()

    }
   
}
