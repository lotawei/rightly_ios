//
//  PublishViewTypeSelectView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/24.
//

import Foundation

class PublishViewTypeSelectView: UIView,NibLoadable {
    
    var  clickSenderType:((_ viewType:Int) -> Void)?=nil
    
    @IBOutlet weak var btnpub: UIButton!
    @IBOutlet weak var btnprivacy: UIButton!
    @IBOutlet weak var btncancel: UIButton!
    @IBAction func cancel(_ sender: Any) {
        self.removeFromWindow()
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        btnpub.setTitle("Public".localiz(), for: .normal)
        btnprivacy.setTitle("Private".localiz(), for: .normal)
        btncancel.setTitle("system_Cancel".localiz(), for: .normal)
    }
    @IBAction func sendClick(_ sender: UIButton) {
        if sender.tag == 0 {
            
            self.clickSenderType?(2)
            self.removeFromWindow()
        }else{
            
            self.clickSenderType?(1)
            self.removeFromWindow()
        }
        
    }
    
}
