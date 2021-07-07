//
//  GreetInfoLockEditView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/1.
//

import UIKit

class GreetInfoLockEditView: UIView, NibLoadable {
    let editView = MessageEditView.loadNibView() ?? MessageEditView()
    
    @IBOutlet weak var diplayInfo: UILabel!
    override func awakeFromNib() {
        self.diplayInfo.text = "adopt_the_task".localiz()
        if self.editView.superview == nil {
            self.insertSubview(self.editView, at: 0)
            self.editView.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
        }
    }
}
