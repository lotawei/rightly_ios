//
//  AvatarSelectCollectionView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//

import Reusable
import RxSwift
import RxCocoa
class AvatarSelectCollectionView: UICollectionViewCell,NibReusable {
      
    var  itemIndexPathBlock:((_ indexpath:IndexPath)->Void)?=nil
    var  indexpath:IndexPath?=nil
    @IBOutlet weak var selectLayer: UIView!
    @IBOutlet weak var imgview: UIImageView!
    
    @IBOutlet weak var btn: UIButton!
    
    func updateSelect(_ selcted:Bool, avtarInfo:SysAvatarInfo,indexpath:IndexPath)  {
        self.indexpath = indexpath
        let inbundleimg = placehodlerImg
        if let avurl = avtarInfo.url?.dominFullPath(), !avurl.isEmpty {
            imgview.kf.setImage(with: URL(string:avurl), placeholder: inbundleimg)
        }else{
            imgview.image = inbundleimg
        }
        self.selectLayer.isHidden = !selcted
      
     
    }
    
    @IBAction func selectInfoAction(_ sender: Any) {
        guard let indexpath = self.indexpath else {
            return
        }
        itemIndexPathBlock?(indexpath)
        
    }
    
}

