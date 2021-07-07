
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
import Kingfisher
import KingfisherWebP
import ZLPhotoBrowser
import Photos
typealias ResizeHeightBlock = (_ itemheight:CGFloat) -> Void
class MediaImageAndPhotoView:UIView{
    var  preViewIndexClick:((_ index:Int) -> Void)?=nil
    var  resizeHeight:ResizeHeightBlock?=nil
    fileprivate var resourcelist:GreetingResourceList?=nil
    var tasktype:TaskType = .photo
    lazy  var imageView:UIImageView = {
        let img = UIImageView.init()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    lazy var playerbtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(preActionClick), for: .touchUpInside)
        button.setImage(UIImage.init(named:  "playVideo" ), for: .normal)
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    convenience  init(frame:CGRect,resourcelist:GreetingResourceList, tasktype:TaskType) {
        self.init(frame:frame)
        self.resourcelist = resourcelist
        self.tasktype = tasktype
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        setUpViews()
    }
    
    func setUpViews(){
        guard let  resourcelist = resourcelist else {
            return
        }
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.top.equalToSuperview()
        }
        self.imageView.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(previewImage(_:)))
        
        self.imageView.addGestureRecognizer(ges)
        var  imgur = resourcelist.url
        if tasktype == .video {
            self.addSubview(playerbtn)
            self.playerbtn.snp.remakeConstraints { (maker) in
                maker.width.height.equalTo(50)
                maker.center.equalToSuperview()
            }
            imgur = resourcelist.previewUrl
            
        }
        guard let imgl  = imgur?.dominFullPath() else {
            return
        }
        if tasktype == .video {
            self.imageView.kf.setImage(with: URL.init(string: imgl),placeholder: placehodlerImg,options: webpOptional)
        }else{
            self.imageView.kf.setImage(with: URL.init(string: imgl),placeholder: placehodlerImg,options: webpOptional)
        }
    
    }
    @objc func  preActionClick(_ sender:Any){
        
//            self.preViewIndexClick?(self.tag)
        guard let  videourl = self.resourcelist?.url else {
            return
        }
        if let url = URL.init(string: videourl.dominFullPath()){
            var  coverurl:URL? = nil
            if let preurl =  resourcelist?.previewUrl?.dominFullPath() {
                coverurl = URL.init(string: preurl)
            }

            self.preViewVideo(url:url,cover:  coverurl)
        }
        
    }
    @objc func previewImage(_ tag:UITapGestureRecognizer){
//        var  urlimg:URL?
//
//        if  tasktype  == .photo {
//            if  let imgurl = self.resourcelist?.url?.dominFullPath()  {
//                urlimg =  URL.init(string: imgurl)
//                if let imgurl = urlimg,let img = self.imageView.image {
//                    self.jumpPreViewResource(resources: [imgurl])
//                }
//            }
//        }
//        else{
//            preActionClick(1 as Any)
//        }
        if  tasktype  == .photo {
            self.preViewIndexClick?(self.tag)
            
        }else{
            preActionClick(1 as Any)
        }
    }
    
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


