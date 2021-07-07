//
//  cameracell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/22.
//

import Foundation
import Foundation
import Foundation
import Kingfisher
import Reusable
class MediaResourceCameraCollectionView: UICollectionViewCell,NibReusable{
    @IBOutlet weak var btncamera: UIButton!
    var clickCamera:(()->Void)?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.btncamera.layoutButton(style: .Top, imageTitleSpace: 5)
    }
    @IBAction func cameralAction(_ sender: Any) {
        self.clickCamera?()
    }
    
}
