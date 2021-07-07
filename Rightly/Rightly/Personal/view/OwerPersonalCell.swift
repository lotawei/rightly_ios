//
//  OwerPersonalCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/18.
//

import Foundation
import Foundation
import Reusable
import RxSwift
import RxCocoa
class OwerPersonalCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var lbldesc: UILabel!
    @IBOutlet weak var img: UIImageView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    func updateDisplay(_ img:String,_ title:String)  {
        self.img.image = UIImage.init(named: img)
        self.lbldesc.text = title
    }
    
}

