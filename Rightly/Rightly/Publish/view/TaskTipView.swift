//
//  TaskTipView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/22.
//

import Foundation

class TaskTipView: UIView,NibLoadable {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbldes: UILabel!
    var taskType:TaskType = .photo {
        didSet {
            self.updateDisplay()
        }
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateDisplay(){
        self.img.image = taskType.NewtaskImageIcon()
        self.backgroundColor = taskType.NewTaskTipBackColor()
        self.lbldes.textColor = taskType.NewTaskTipStyleTextColor()
    }
}
