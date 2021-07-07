//
//  NewMessageTaskTipView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/9.
//

import Foundation

class NewMessageTaskTipView: UIView,NibLoadable {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var largetTitleLable: UILabel!
    @IBOutlet weak var lblDes: UILabel!
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
        self.backgroundColor = taskType.taskNewVersionColor()
    }
    func setUserTask(_ usertask:TaskBrief)  {
        self.taskType = usertask.type
        self.largetTitleLable.text = usertask.type.typeTitle()
        self.lblDes.text  = usertask.descriptionField
        self.img.image = usertask.type.typeCenterTaskIconImage()
    }
}
