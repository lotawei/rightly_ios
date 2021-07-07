//
//  DiscoverTopicCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/25.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
class DiscoverTopicImageAndVideoCell: UITableViewCell,NibReusable {
    var   actionDetailMore:((_ item:DiscoverTopicModel)->Void)?=nil
    var  item:DiscoverTopicModel?=nil
    let  resourceItemHeight:CGFloat = 131
    var  resourceItemW:CGFloat = 80
    let itempadding:CGFloat = 8
    @IBOutlet weak var userEnjoylbl: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMatch: UILabel!
    @IBOutlet weak var detaillbl: UILabel!
    @IBOutlet weak var resourceItmesView: UIView!
    @IBOutlet weak var resourceHeigt: NSLayoutConstraint!
    lazy var  itemscrollerview:UIScrollView = {
        let  scrollerview =  UIScrollView.init(frame: .zero)
        scrollerview.backgroundColor = UIColor.white
        scrollerview.showsVerticalScrollIndicator = false
        scrollerview.showsHorizontalScrollIndicator = false
        return scrollerview
    }()

    var  itemViews:[MediaImageAndPhotoView] = [MediaImageAndPhotoView]()
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.resourceItmesView.addSubview(self.itemscrollerview)
        self.itemscrollerview.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
 
    }
    fileprivate func clearResourceViews() {
        for item in itemViews {
            item.removeFromSuperview()
        }
        itemViews.removeAll()
    }
    
    func updateDisPlay(_ item:DiscoverTopicModel)  {
        clearResourceViews()
        self.item = item
        lblName.text = "#"+"\(item.name ?? "")"
        lblMatch.isHidden = !(item.isMatch ?? false)
        userEnjoylbl.text = item.peopleNum?.enjoyPeopleDisplay()
        self.detaillbl.text = item.simpleDescription
        var resourcelists:[GreetingResourceList] = []
        if let greetings = item.greetings {
            for greet in greetings {
                if let resourcelist = greet.resourceList?.first {
                    resourcelists.append(resourcelist)
                }
            }
        }
        var  urls = resourcelists.map { (resourcelist) -> URL? in
            return  resourcelist.mapUrl(item.type)
        }
        for (index,value) in resourcelists.enumerated() {
            let  resourceV = self.createResouceView(item.type,value)
            if let itemV = resourceV  {
                itemV.tag = index
                itemViews.append(itemV)
                itemV.preViewIndexClick = {  [weak self] selectedindex in
                    guard let `self` = self  else {return }
//                    self.jumpPreViewResource(resources:urls ,selectindex:selectedindex)
                    self.jumpNewPreViewResource(resources: urls,selectindex: IndexPath.init(item: selectedindex, section: 0))
                    
                }
            }
        }
        if resourcelists.count == 0 {
            self.resourceHeigt.constant = 0
        }else{
            self.resourceHeigt.constant = 131
        }
        self.setUpSubView()
    }
    private func  setUpSubView(){
        var prefix:CGFloat = 0
        var  i:CGFloat = 0
        resourceItemW = (screenWidth - 32 - 3*itempadding)/4
        for t in itemViews {
            itemscrollerview.addSubview(t)
            t.frame = CGRect.init(x: prefix, y: 0, width: resourceItemW, height: resourceItemHeight)
            prefix = prefix +  CGFloat(resourceItemW) + itempadding
            i = i + 1
        }
        self.itemscrollerview.contentSize = CGSize.init(width: prefix + itempadding , height: 0)
    }
    @objc func sendClick(_ sender:UITapGestureRecognizer) {
        
    }
    @IBAction func moreAction(_ sender: Any) {
        guard let topic = self.item else {
            return
        }
        actionDetailMore?(topic)
    }
}

extension UITableViewCell {
    func createResouceView(_ topicType:ToicType ,_ resourcelist:GreetingResourceList) -> MediaImageAndPhotoView? {
   
        if topicType == .photo {
           return  MediaImageAndPhotoView.init(frame: .zero, resourcelist: resourcelist, tasktype: .photo)
        }
        else if topicType == .video {
            return  MediaImageAndPhotoView.init(frame: .zero, resourcelist: resourcelist, tasktype: .video)
        }
        return nil
    }
}
