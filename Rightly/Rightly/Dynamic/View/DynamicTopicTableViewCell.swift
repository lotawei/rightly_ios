//
//  DynamicTopicTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/9.
//

import UIKit

class DynamicTopicTableViewCell: UITableViewCell {

    @IBOutlet weak var topicLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform.init(rotationAngle: (.pi / 2.0));
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
