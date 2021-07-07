//
//  UserPersonalGreetingCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/29.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
import Kingfisher
import SnapKit
class UserPersonalGreetingCell: UITableViewCell,NibReusable{
    var  operatorClick:((_ greetingResult:GreetingResult)->Void)?=nil
    var  privacyClick:((_ greetingResult:GreetingResult)->Void)?=nil
    var   vmData:GreetingResultVModel?=nil
    @IBOutlet weak var cityview: UIStackView!
    @IBOutlet weak var btncity: UIButton!
    @IBOutlet weak var lblviewtype: UIButton!
    @IBOutlet weak var lblcreateat: UILabel!
    @IBOutlet weak var content: UILabel!
    var disposebag = DisposeBag.init()
    @IBOutlet weak var tasktipView: UIView!
    @IBOutlet weak var taskicon: UIImageView!
    @IBOutlet weak var taskdes: UILabel!
    @IBOutlet weak var usertagView: UIView!
    var  selectagView:TagSelectView =  TagSelectView.init(frame: .zero)
    @IBOutlet weak var itemtopimage: UIImageView!
    @IBOutlet weak var resourceView: UIStackView!
    var  audioView:ReleaseAudioView?=ReleaseAudioView.loadNibView()
    override func prepareForReuse() {
        super.prepareForReuse()
        disposebag = DisposeBag.init()
        self.audioView?.removeFromSuperview()
        for subview in self.resourceView.arrangedSubviews{
            subview.removeFromSuperview()
        }
        itemtopimage.isHidden = true
    }
    
    @IBAction func operatorClick(_ sender: Any) {
        guard let  result = self.vmData?.greetingresult else {
            return
        }
        self.operatorClick?(result)
    }
    @IBAction func privacyChangeClick(_ sender: Any) {
        guard let  result = self.vmData?.greetingresult else {
            return
        }
        self.privacyClick?(result)
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        selectagView.loadGrayStyle()
        self.usertagView.addSubview(selectagView)
        selectagView.frame = .zero
        
    }
    
    func bindVmData(_  vmdata:GreetingResultVModel,istop:Bool = false)  {
        self.vmData = vmdata
        itemtopimage.isHidden = !istop
        vmdata.output.greetingReultData.asObservable().subscribe(onNext: { [weak self] (resultdata) in
            guard let `self` = self  else {return }
            self.lblcreateat.text = String.updateTimeToCurrennTime(timeStamp: Double(resultdata.createdAt ?? 0))
            let vtitle = resultdata.viewType.map { (value) -> String in
                let viewtype  = ViewType.init(rawValue: value.rawValue ??  2)
                switch viewtype {
                case .Private:
                    return "In private".localiz()
                case .Public:
                    return "In public".localiz()
                case .none:
                    return "In public".localiz()
                }
            }
            self.lblviewtype.setTitle(vtitle, for: .normal)
            self.content.attributedText = resultdata.content?.exportEmojiTransForm()
            var  displayTags:[String]?
            if  let tags = resultdata.tags {
                displayTags = tags.map({ (tag) -> String in
                        return tag.name ?? ""
                })
            }
            
            if let topics = resultdata.topics {
                displayTags = topics.map({ (tag) -> String in
                        return "#\((tag.name ?? ""))"
                })
            }
            if  let displayTopicorTags = displayTags {
                self.usertagView.isHidden = false
                self.selectagView.setTags(displayTopicorTags)
                self.selectagView.snp.updateConstraints { (maker) in
                    maker.width.equalTo(self.selectagView.contensizeWidth)
                    maker.left.top.bottom.equalToSuperview()
                }
            }else{
                self.usertagView.isHidden = true
            }
         
            if let taskBrief = resultdata.task {
                    self.tasktipView.isHidden = false
                    self.taskdes.text = "     "  + (taskBrief.descriptionField ?? "")
                    self.taskicon.image = taskBrief.type.taskImageIcon()
                    self.tasktipView.backgroundColor = taskBrief.type.tasktypeColor()
            }else{
                self.tasktipView.isHidden = true
            }
            if let tasktype = resultdata.taskType {
                self.layoutresource(tasktype,resourcelists: resultdata.resourceList ?? [])
            }
        }).disposed(by: self.rx.disposeBag)
        vmdata.output.greetingLocationdecode.asObservable().subscribe(onNext: { [weak self] (city) in
            guard let `self` = self  else {return }
            if let city = city ,!city.isEmpty {
                self.btncity.setTitle(city, for: .normal)
                self.cityview.alpha = 1  //不要尝试使用ishidden 会有奇怪的问题 就算在主线程
            }
            else{
                self.cityview.alpha = 0
            }
            
        }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func  layoutresource(_ taskType:TaskType,resourcelists:[GreetingResourceList]){
        if resourcelists.count == 0 {
            resourceView.isHidden = true
            return
        }
        resourceView.isHidden = false
        if taskType == .photo || taskType == .video {
            var  urls = resourcelists.map { (resourcelist) -> URL? in
                return  resourcelist.mapUrl(taskType)
            }
            for (index,var item) in resourcelists.enumerated() {
                var imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
                imgphotoView.tag = index
                self.resourceView.addArrangedSubview(imgphotoView)
                var  height:CGFloat = 0
                height = CGFloat(item.scaleByWidth(wid: screenWidth - 32))
                height = height > 0 ? height:375
                imgphotoView.snp.makeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
                imgphotoView.preViewIndexClick = {  [weak self] selectedindex in
                    guard let `self` = self  else {return }
//                    self.jumpPreViewResource(resources:urls ,selectindex:selectedindex)
                    self.jumpNewPreViewResource(resources:urls ,selectindex:IndexPath.init(item: selectedindex, section: 0))
                }
            }
        }
        else{
            guard let audioview = self.audioView else {
                return
            }
            guard let  audioresource = resourcelists.first , let url = audioresource.url ,let duration = audioresource.duration else {
                
                return
            }
            let widthAndDuration  =  audioview.layoutReleaseAudioView(Int(duration))
            audioview.audiopath = url.dominFullPath()
            if audioview.superview == nil {
                self.resourceView.addArrangedSubview(audioview)
                audioview.snp.makeConstraints { (maker) in
                    maker.width.equalTo(widthAndDuration.0 + 80)
                    maker.height.equalTo(40)
                }
//                self.resourceView.layoutIfNeeded()
            }
        }
    }
    
    fileprivate  func resizeImage(_ height:CGFloat, _ index:Int){
        if  index <= self.resourceView.arrangedSubviews.count - 1{
            UIView.animate(withDuration: 0.01) {
                self.resourceView.arrangedSubviews[index].snp.remakeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
            }
        }
    }
}

