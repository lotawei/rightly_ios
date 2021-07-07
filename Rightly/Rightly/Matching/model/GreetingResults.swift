//
//  GreetingDetail.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/11.
//

import Foundation
import Kingfisher
import KingfisherWebP
import KakaJSON
import RxSwift
import RxCocoa
struct  MatchDtata: Convertible {
    var  matchData:[MatchGreeting] = []
    var  matchNumber:Int? = nil
}

struct MatchLimitInfo:Convertible{
    var sumNum:Int64 = 0
    var surplusNum:Int64 = 0
}
class MatchGreeting : Convertible {
    var age : Int? = nil
    var avatar : String? = nil
    var birthday : Int64?
    var gender : Gender?
    var nickname : String? = nil
    var task : TaskBrief? = nil
    var userId : Int64? = nil
    var location : MatchLocation? = nil
    var isOnline:Bool? = nil
    var  imAccId:String? = nil
    var backgroundUrl : String? = nil //背景图
    var  bgViewType:ViewType? = nil
    var  isUnlock:Bool = false
    var  preBackImageProcess:BehaviorRelay<UIImage?>=BehaviorRelay.init(value:nil)//本地维护
    required init(){
        
    }
    
    
}
extension MatchGreeting {
    func  backImageDecodeProcess( targetSize:CGSize? = nil) {
        guard let url = self.backgroundUrl?.dominFullPath() ,let netWorkUrl = URL.init(string: url) else {
            self.preBackImageProcess.accept(nil)
            return
        }
        KingfisherManager.shared.loadCacheOrNetWorkByCache(netWorkUrl,targetSize:targetSize) {[weak self] (image) in
            guard let `self` = self  else {return }
            self.preBackImageProcess.accept(image)
        }
    }
}
struct MatchLocation : Codable {
    let city : String?
    let continent : String?
    let country : String?
    let lat : Float?
    let lng : Float?
    let region : String?
    enum CodingKeys: String, CodingKey {
        case city = "city"
        case continent = "continent"
        case country = "country"
        case lat = "lat"
        case lng = "lng"
        case region = "region"
    }
}




struct GreetingResourceList:Convertible {
    init() {
    }
    
    var duration : Double? = 0
    var previewUrl : String? = nil
    var url : String? = nil
    var width:CGFloat? = 0
    var height:CGFloat? = 0
    let placehoderImage = placehodlerImg
    var imgSizeLayoutHeight:((_ scaleimage:UIImage) -> Void)?=nil
    
    init(duration:Double?,previewUrl:String?,url:String?) {
        self.duration = duration
        self.previewUrl = previewUrl
        self.url = url
        self.width = 0
        self.height = 0
    }
    func scaleByWidth(wid:CGFloat) ->  Double {
        guard let  w = width,let  h = height else {
            return 375
        }
        let  scaleImage = h / w
        return   Double(scaleImage * wid)
    }
    
    func kj_JSONValue(from modelValue: Any?, _ property: Property) -> Any? {
        switch property.name {
        case "placehoderImage":
            return nil
        case "imgSizeLayoutHeight":
            return nil
        default:
            return modelValue
        }
    }
}
extension  GreetingResourceList {
    func mapUrl(_ tasktype:TaskType) -> URL? {
        if tasktype == .photo || tasktype == .video {
            guard var imgurl =  URL.init(string: self.url?.dominFullPath() ?? "") else {
                return nil
            }
            return imgurl
        }
        return nil
    }
    func mapUrl(_ tasktype:ToicType) -> URL? {
        if tasktype == .photo || tasktype == .video {
            guard var imgurl =  URL.init(string: self.url?.dominFullPath() ?? "") else {
                return nil
            }
            return imgurl
        }
        return nil
    }
    
    func autoSizeImageHeight(_ maxWidth:CGFloat ,webpSe:Bool = false)  {
        var   resourceimgurl:URL? = nil
        if webpSe {
            guard var videourl =  URL.init(string: self.previewUrl?.dominFullPath() ?? "") else {
                return
            }
            resourceimgurl = videourl
        }else{
            guard var imgurl =  URL.init(string: self.url?.dominFullPath() ?? "") else {
                return
            }
            resourceimgurl = imgurl
        }
        guard let url = resourceimgurl else {
            
            return
        }
        
        var option:KingfisherOptionsInfo? = nil
        if webpSe == false {
            option = nil
        }else{
            option = [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        }
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString,options: option) { (result) in
            switch result {
            case .success(let imageres):
                guard let cacheimage = imageres.image else {
                    self.forcerefreshImage(url: url, maxwidth: maxWidth)
                    return
                }
                let  scaleImage = UIImage.compressImage(image: (imageres.image ?? self.placehoderImage) ?? UIImage.init(), width: maxWidth)
                self.imgSizeLayoutHeight?(scaleImage ?? UIImage.init())
                break
            case .failure(let err):
                
                break
            }
        }
    }
    
    fileprivate  func  forcerefreshImage(url:URL ,maxwidth:CGFloat,webpSe:Bool = false){
        var option:KingfisherOptionsInfo? = nil
        if webpSe == false {
            option =  [.fromMemoryCacheOrRefresh]
        }else{
            option = [.fromMemoryCacheOrRefresh,.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        }
        KingfisherManager.shared.downloader.downloadImage(with:url, options:option) { (result) in
            switch result {
            case .success(let imageres):
                let  scaleImage = UIImage.compressImage(image: imageres.image, width: maxwidth)
                self.imgSizeLayoutHeight?(scaleImage ?? UIImage.init())
                break
            case .failure(let err):
                break
            }
        }
    }
    
    
}
struct GreetingResult : Convertible {
    var city : String? = nil
    var content : String?
    var createdAt : Int64?
    var greetingId : Int64?
    var isLike : Bool? //是否like
    var resourceList : [GreetingResourceList]?
    var status : Int? //
    var task : TaskBrief?
    var taskId : Int64?
    var toUserId : Int64?
    var address:String?
    var viewType:ViewType?  //
    var updatedAt:Int?
    var likeNum:Int?
    var lng:Double?
    var lat:Double?
    var user : UserAdditionalInfo?
    var userId : Int64?
    var location:MatchLocation?
    var likeAt:Int?
    var isTop:Bool?
    var taskType:TaskType? = nil
    var tags:[ItemTag]? = nil
    var topics:[DiscoverTopicModel]? = nil
    var isUnlock:Bool? =  nil
    var isMatchEnd:Bool? = nil
    enum CodingKeys: String, CodingKey {
        case city = "city"
        case address = "address"
        case content = "content"
        case createdAt = "createdAt"
        case greetingId = "greetingId"
        case isLike = "isLike"
        case resourceList = "resourceList"
        case status = "status"
        case task
        case updatedAt
        case viewType = "viewType"
        case taskId = "taskId"
        case toUserId = "toUserId"
        case likeNum  = "likeNum"
        case lng
        case lat
        case user
        case userId
        case location
        case likeAt
        case isTop
        case tags
        case taskType
        case isUnlock
        case topics
        case isMatchEnd
    }
}
struct GreetingResults : Convertible {
    
    var pageNum : Int? = nil
    var pageSize : Int? = nil
    var results : [GreetingResult]? = nil
    var total : Int? = nil
    var totalPage : Int? = nil
    
}

struct GreetingDetail : Convertible {
    
    var address : String?
    var content : String?
    var createdAt : Int64?
    var greetingId : Int64?
    var isLike : Bool?
    var lat : Double?
    var likeNum : Int?
    var lng : Double?
    var resourceList : [GreetingResourceList]?
    var status : Int?
    var task : TaskBrief?
    var taskId : Int64?
    var toUserId : Int64?
    var updatedAt : Int?
    var user : UserAdditionalInfo? = nil
    var userId : Int64? = nil
    var location:MatchLocation? = nil
    var tags:[ItemTag]? = nil
    var topics:[DiscoverTopicModel]? = nil
    var taskType:TaskType? = nil
}




extension  GreetingResult {
    
    static func ==( lh:GreetingResult,  rh:GreetingResult) -> Bool {
        
        return lh.greetingId == rh.greetingId
    }
}


extension  KingfisherManager {
    func  loadCacheOrNetWorkByCache(_ url:URL,targetSize:CGSize? = nil,imageRes:@escaping((_ cacheImage:UIImage?)->Void)){
        var  webSe:Bool = false
        if url.absoluteString.contains("webp") {
            webSe = true
        }
        var option:KingfisherOptionsInfo? = nil
        if webSe == false {
            option = [.fromMemoryCacheOrRefresh]
        }else{
            option = [.fromMemoryCacheOrRefresh,.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        }
        if let size = targetSize {
            option = (option ?? []) + [KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor.init(size: size))]
        }
        KingfisherManager.shared.retrieveImage(with: url) { (result) in
            switch result {
            case .success(let imageres):
                guard let cacheimage = imageres.image.images?.first else {
                    KingfisherManager.shared.downloader.downloadImage(with:url, options:option) { (result) in
                        switch result {
                        case .success(let imageres):
                            imageRes(imageres.image)
                            break
                        case .failure(let err):
                            imageRes(nil)
                            break
                        }
                    }
                    return
                }
                imageRes(cacheimage)
                break
            case .failure(let err):
                imageRes(nil)
                break
            }
        }
     
    }
    
}
