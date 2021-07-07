//
//  IconTextImageMoreCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
enum IconItem {
    case  item(_ img:String? = nil, _ title:String , _ subtite:String? = nil)
}
class IconTextImageMoreCell: UITableViewCell,NibReusable {
    
    @IBOutlet weak var lblsubtitle: UILabel!
    @IBOutlet weak var imginfo: UIImageView!
    @IBOutlet weak var lbltext: UILabel!
    @IBOutlet weak var imgmore: UIImageView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    func updateItem(item:IconItem){
        switch item {
        case .item(let img, let title, let subtitle):
            if let imgname = img {
                //                self.imginfo.image = UIImage.init(named: imgname)
                if imgname.contains("/") {
                    let inbundleimg = placehodlerImg
                        imginfo.kf.setImage(with: URL(string:imgname), placeholder: inbundleimg)
                }
                else{
                    imginfo.image = UIImage.init(named: imgname)
                }
                
                
            }
            
            self.lbltext.text = title
            
            
            if let subtitle = subtitle {
                self.lblsubtitle.text = subtitle
                
            }else{
                self.lblsubtitle.text = ""
            }
            
        default:
            break
            
        }
        
    }
    
}

