//
//  GiftItemView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/31.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class GiftItemView: UIView,NibLoadable{
    let disposebag = DisposeBag()
    var  giftDetail:BehaviorRelay<GiftModel?> = BehaviorRelay.init(value: nil)
    private var  isselected:Bool = false {
        didSet{
            selectState()
        }
    }
    @IBOutlet weak var gifImage: UIImageView!
    @IBOutlet weak var gifLblPrice: UILabel!
    var  purchaseItem:((_ detailPurchase:GiftModel? )->Void)?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.giftDetail.asObservable().subscribe(onNext: {[weak self] (detailvalue) in
            guard let `self` = self ,let detail = detailvalue  else {return}
            self.configUI(detail)
            
        }).disposed(by: disposebag)
        let tapges = UITapGestureRecognizer.init(target: self, action: #selector(selectView))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapges)
        
    }
    fileprivate func  configUI(_ detail:GiftModel){
        let inbundleimg = UIImage(named:"images")
        if let url = detail.iconUrl?.dominFullPath() ,  !url.isEmpty{
            gifImage.kf.setImage(with: URL.init(string:url), placeholder: inbundleimg)
        }else{
            gifImage.image = inbundleimg
        }
        gifLblPrice.text = Int.coinDisplay(detail.price ?? 0)
        self.selectState()
    }
    func  selectState(){
        if  isselected {
            self.backgroundColor = UIColor.init(hex: "353B48").withAlphaComponent(0.8)
            
        }else{
            self.backgroundColor = UIColor.clear
        }
    }
    
    @objc    func  selectView(){
        self.isselected = true
    }
    
    fileprivate func  sendGift(tapcount:Int)  {
        guard let detail = self.giftDetail.value else {
            return
        }
    }
    
}
