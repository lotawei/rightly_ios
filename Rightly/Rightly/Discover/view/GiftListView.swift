//
//  GiftListView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/31.
//
import UIKit
import  RxSwift
import RxCocoa

//礼物视图
class GiftListView:UIView,NibLoadable{
    //需要送出的礼物列表
    var  detailsData = [GiftModel]()
    let disposebag = DisposeBag()
    /// 直播间礼物列表
     var cycleScrollView: LVCycleScrollView = {
        let cycleScrollView = LVCycleScrollView.cycle(frame:.zero, loopTimes: 1)
        cycleScrollView.currentPageDotEnlargeTimes = 1.0
        cycleScrollView.customDotViewType = .hollow
        cycleScrollView.pageDotColor = UIColor.gray
        cycleScrollView.currentPageDotColor = UIColor.white
        cycleScrollView.pageControlDotSize = CGSize(width: 12, height: 12)
        cycleScrollView.backgroundColor = UIColor.clear
        return cycleScrollView
    }()
    @IBOutlet weak var itemsGiftView: UIView!
    @IBOutlet weak var btnSend: UIButton!
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.itemsGiftView.addSubview(cycleScrollView)
        self.cycleScrollView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        configData()
    }
    func configData()  {
        self.detailsData = [GiftModel.init(),GiftModel.init()]
        self.cycleScrollView.viewArray = self.setupCustomSubView(detailsData)
    }
    func setupCustomSubView(_ detailitems:[GiftModel]) -> [UIView] {
        var tmpX: CGFloat = 0
        var tmpY: CGFloat = 0
        
        let horizontalRow = 4
        let verticalRow = 2
        
        let tmpW = screenWidth / CGFloat(horizontalRow)
        let tmpH = self.itemsGiftView.frame.height / 2 / CGFloat(verticalRow)
        
        var bottomView: UIView?
        
        var customSubViewArray: [UIView] = []
        
        for index in 0..<detailitems.count {
            
            tmpX = CGFloat(index % horizontalRow) * tmpW
            if (index % (horizontalRow * verticalRow)) < horizontalRow {
                tmpY = 0
            } else {
                tmpY = tmpH
            }
            
            if bottomView == nil || (index % (horizontalRow * verticalRow) == 0) {
                bottomView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: self.itemsGiftView.frame.width / 2 + 30))
                bottomView?.backgroundColor  = .clear
                customSubViewArray.append(bottomView!)
            }
            bottomView?.addSubview(self.setupUIView(index: index, frame: CGRect(x: tmpX, y: tmpY, width: tmpW, height: tmpH), itemdetail: detailitems[index]))
            
        }
        
        return customSubViewArray
    }
    
    func setupUIView(index: Int, frame: CGRect,itemdetail:GiftModel) -> GiftItemView {
        let itemview = GiftItemView.loadNibView()
        itemview?.frame = CGRect.init(x: 0, y: 0, width: 75, height: 75)
        itemview?.center = CGPoint.init(x: frame.midX, y: frame.midY)
        itemview?.giftDetail.accept(itemdetail)
        return itemview!
    }
    
}
