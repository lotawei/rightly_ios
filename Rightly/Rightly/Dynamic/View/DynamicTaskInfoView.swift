//
//  DynamicTaskInfoView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/3.
//

import UIKit

class DynamicTaskInfoView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    func bindingModel(_ model:TaskBrief) {
        self.backgroundColor = model.type.taskbackColor()
        self.iconImageView.image = UIImage.init(named: model.type.typeTitleIconName())
        self.contentLabel.text = model.descriptionField
    }
}
