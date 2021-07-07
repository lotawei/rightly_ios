//
//  AlterViewTipView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
enum AlterTipInfoType:Int {
    case logoutTip = 1,
         deleteTip = 2
}


typealias SuresuccessBlock = (()->Void)
class AlterViewTipView:UIView,NibLoadable {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var largetitle: UILabel!
    @IBOutlet weak var surebtn: UIButton!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    var doneBlock:SuresuccessBlock?=nil
    override func awakeFromNib() {
        super.awakeFromNib()
        surebtn.setTitle("Log sure".localiz(), for: .normal)
        cancelbtn.setTitle("Log cancel".localiz(), for: .normal)
    }
    func displayerInfo(_ type:AlterTipInfoType)  {
        switch type {
        case .logoutTip:
            largetitle.text = "Log Out".localiz()
            subtitle.text = "Are you sure to log out?".localiz()
        default:
            largetitle.text = "Delete".localiz()
            subtitle.text = "Are you sure to delete?".localiz()
        }
    }
    
    @IBAction func doneBlockclick(_ sender: Any) {
        
        doneBlock?()
        
        self.removeFromWindow()

    }
    @IBAction func cancelclick(_ sender: Any) {
        self.removeFromWindow()
    }
}
