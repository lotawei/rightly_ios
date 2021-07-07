//
//  SelectGreetingTaskCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/1.
//

import Reusable
import RxSwift
import RxCocoa
import SnapKit
class SelectItemPlateViewTaskCell: UITableViewCell,NibReusable{
    var  operatorClick:((_ greetingResult:GreetingResult)->Void)?=nil
    @IBOutlet weak var cityview: UIStackView!
    var   vmData:GreetingResultVModel?=nil
    var  selectItemClick:((_ res:GreetingResult?) -> Void)?=nil
    @IBOutlet weak var itemoperatorbtn: UIButton!
    @IBOutlet weak var btncity: UIButton!
    @IBOutlet weak var btnlike: UIButton!
    @IBOutlet weak var lblviewtype: UILabel!
    @IBOutlet weak var lblcreateat: UILabel!
    @IBOutlet weak var content: UILabel!
    var disposebag = DisposeBag.init()
    @IBOutlet weak var tasktipView: UIView!
    @IBOutlet weak var tipheight: NSLayoutConstraint!
    var  tipview:TaskTipView? = TaskTipView.loadNibView()
    
    @IBOutlet weak var btniselected: UIButton!
    //资源视图
    @IBOutlet weak var resourceView: UIStackView!
    
    
    var  audioView:ReleaseAudioView?=ReleaseAudioView.loadNibView()
    var  voiceWidth:Constraint?=nil
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposebag = DisposeBag.init()
        self.audioView?.removeFromSuperview()
        for subview in self.resourceView.arrangedSubviews{
            subview.removeFromSuperview()
        }
    }
    @IBAction func selectAction(_ sender: Any) {
        guard let  result = self.vmData?.greetingresult else {
            return
        }
  
        if self.btniselected.isSelected {
            self.selectItemClick?(nil)
        }else{
            selectItemClick?(result)
        }
    }
    
    @IBAction func operatorClick(_ sender: Any) {
        guard let  result = self.vmData?.greetingresult else {
            return
        }
        self.operatorClick?(result)
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        guard let tipview = tipview else {
            return
        }
        self.tasktipView.addSubview(tipview)
        tipview.snp.makeConstraints { (maker) in
            maker.left.right.bottom.top.equalToSuperview()
        }
        
        
        
    }
    func bindVmData(_  vmdata:GreetingResultVModel)  {
        self.vmData = vmdata
        vmdata.output.likeNumber.asDriver(onErrorJustReturn: "").drive(self.btnlike.rx.title(for: .normal)).disposed(by: self.disposebag)
        vmdata.output.greetingContent.asDriver(onErrorJustReturn: NSAttributedString.init(string: "")).drive( self.content.rx.attributedText).disposed(by: self.disposebag)
//        vmdata.output.likeatTime.asDriver(onErrorJustReturn: "").drive( self.lblcreateat.rx.text).disposed(by: self.disposebag)
        vmdata.output.greetingCreateTime.asDriver(onErrorJustReturn: "").drive( self.lblcreateat.rx.text).disposed(by: self.disposebag)
        vmdata.output.greetingviewType.asDriver(onErrorJustReturn: ViewType.Public).map { (value) -> String in
            let viewtype  = ViewType.init(rawValue: value?.rawValue ??  2)
            switch viewtype {
            case .Private:
                return "In private".localiz()
            case .Public:
                return "In public".localiz()
            case .none:
                return "In public".localiz()
            }
        }.drive(self.lblviewtype.rx.text).disposed(by: self.disposebag)
        vmdata.output.itemSelected.asDriver().drive(self.btniselected.rx.isSelected).disposed(by: self.disposebag)
//        vmdata.output.greetingcity.asDriver(onErrorJustReturn: "").drive( self.btncity.rx.title()).disposed(by: self.disposebag)
        vmdata.output.resultData.asObservable().subscribe(onNext: { [weak self] (resultdata) in
            guard let `self` = self  else {return }
            
            guard let task = resultdata?.0 ,  let resourcelist = resultdata?.1 else{return }
            self.tipview?.taskType = task.type
            self.tipview?.lbldes.text  = task.descriptionField ?? ""
            self.layoutresource(task.type,resourcelists: resourcelist)
            let tipH = (self.tipview?.lbldes.sizeThatFits(CGSize(width: (screenWidth - 70), height: screenHeight)).height ?? 18) + 16 + 24
            self.tipheight.constant = max(tipH, 58)
        }).disposed(by: self.rx.disposeBag)
        
        vmdata.output.greetingLocationdecode.asObservable().subscribe(onNext: { [weak self] (city) in
            guard let `self` = self  else {return }
            if let city = city ,!city.isEmpty {
                self.btncity.setTitle(city, for: .normal)
                self.cityview.alpha = 1
            }
            else{
                self.cityview.alpha = 0
            }
            
        }).disposed(by: self.rx.disposeBag)
        
        
    }
    
    fileprivate func  layoutresource(_ taskType:TaskType,resourcelists:[GreetingResourceList]){
        
        if taskType == .photo || taskType == .video {
            var  urls = resourcelists.map { (resourcelist) -> URL? in
                return  resourcelist.mapUrl(taskType)
            }
            for (index,var item) in resourcelists.enumerated() {
                var imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
                imgphotoView.tag = index
                self.resourceView.addArrangedSubview(imgphotoView)
                var  height:CGFloat = 0
                height = CGFloat(item.scaleByWidth(wid: screenWidth - 32 - 64))
                height = height > 0 ? height:375
                imgphotoView.snp.makeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
//                let imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
//                self.resourceView.addArrangedSubview(imgphotoView)
//
//                imgphotoView.resizeHeight = { [weak self]
//                    height in
//
//                    self?.resizeImage(height, index)
//                }
//                var imgphotoView = MediaImageAndPhotoView.init(frame: .zero, resourcelist:item, tasktype: taskType)
//                imgphotoView.tag = index
//                imgphotoView.imageView.image = item.placehoderImage
//                self.resourceView.addArrangedSubview(imgphotoView)
//                item.imgSizeLayoutHeight = {  [weak self]
//                    image in
//                    imgphotoView.imageView.image = image
//                }
//                if imgphotoView.tasktype == .photo {
//                    item.autoSizeImageHeight(screenWidth - 32,webpSe: false)
//                }else{
//                    item.autoSizeImageHeight(screenWidth - 32,webpSe: true)
//                }
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
                    maker.centerY.equalToSuperview()
                    maker.width.equalTo(widthAndDuration.0 + 80)
                    maker.height.equalTo(38)
                }
            }
        }
        
        
    }
    
    fileprivate  func resizeImage(_ height:CGFloat, _ index:Int){
        if  index <= self.resourceView.arrangedSubviews.count - 1{
            UIView.animate(withDuration: 0.5) {
                self.resourceView.arrangedSubviews[index].snp.remakeConstraints { (maker) in
                    maker.height.equalTo(height)
                }
            }
        }
        
    }
    
    
}


