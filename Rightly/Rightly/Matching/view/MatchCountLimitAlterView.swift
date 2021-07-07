//
//  MatchCountLimitAlterView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/9.
//

import Foundation
import UIKit
class MatchCountLimitAlterView:UIView, NibLoadable  {
    
    @IBOutlet weak var btnsure: UIButton!
    @IBOutlet weak var btncancel: UIButton!
    @IBOutlet weak var lblrunout: UILabel!
    @IBOutlet weak var lblmorechance: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        lblrunout.text = "Run out of times".localiz()
        lblmorechance.text = "Today's matching opportunities are exhausted.\nComplete the task and get more matching opportunities".localiz()
        btncancel.setTitle("Cancel".localiz(), for: .normal)
        btnsure.setTitle("Sure".localiz(), for: .normal)
    }
    @IBAction func cancelclick(_ sender: Any) {
        self.removeFromWindow()
        
    }
    @IBAction func sureclick(_ sender: Any) {
        let  morechanceVc = GetMoreChanceViewController.loadFromNib()
        self.getCurrentViewController()?.navigationController?.pushViewController(morechanceVc, animated: true)
        self.removeFromWindow()
    }
    
}

