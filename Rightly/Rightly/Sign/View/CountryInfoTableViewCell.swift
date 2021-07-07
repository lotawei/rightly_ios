//
//  CountryInfoTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/26.
//

import UIKit

class CountryInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var areaCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindingModel(_ model:CountryInfoModel?) {
        self.countryNameLabel.text = model?.Name
        self.areaCodeLabel.text = model?.areaCodeStr
    }
}
