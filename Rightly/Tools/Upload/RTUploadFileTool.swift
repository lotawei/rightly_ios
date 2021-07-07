//
//  UploadTool.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/11.
//

import Foundation
import RxSwift
import Moya
import ZLPhotoBrowser
import AVFoundation


enum UpLoadResourceType {
    case image ,
         audio ,
         video
}

enum UpLoadType:Int{
    case   userpotrait = 1, //用户头像
           imresource = 9 ,// im
           greeting = 10  //打招呼
}
struct AudioInfo {
    var  filename:String?
    var  urlpath:String
}

typealias uploadSuccessDataBlock = (_ list:GreetingResourceList)->Void
typealias uploadSuccessResourceListsBlock = (_ lists:[GreetingResourceList])->Void

/// 上传工具包括所有类型的
class  RTUploadFileTool   {
    enum FileUploadTask {
        case  taskMulityImage(_ images:UIImage,preview:Bool = false, type:UpLoadType)
        case  taskVideo(_ url:String,preview:Bool = true, type:UpLoadType)
        case  taskVoice(_ url:String, preview:Bool = true,type:UpLoadType)
    }
    
    /// 内部上传 task类型的
    /// - Parameters:
    ///   - path: 文件地址
    ///   - type:
    ///   - fileName: <#fileName description#>
    /// - Returns: description
    static func  RTUploadFile( type:FileUploadTask, fileName:String) -> Single<Response>? {
        let urlpath = "upload/file/client"
        switch type {
        case .taskMulityImage(let image,let preview,let type):
            
            
            var formdatas = [MultipartFormData]()
            //            var  formdatas = image.map { (img) -> MultipartFormData in
            var imgdata = UIImage.getDataWith(image)
            let  maxbyte = 1024*50
            if imgdata.count > maxbyte ,let img = UIImage.init(data: imgdata) {
                imgdata = img.smartCompressImageData() ?? Data.init()
            }
            let  mudata =  MultipartFormData.init(provider: .data(imgdata), name: "file",fileName: fileName, mimeType: "image/jpeg")
            formdatas.append(mudata)
            
            let typeformdata =  MultipartFormData.init(provider: .data("\(type.rawValue)".data(using: .utf8) ?? Data.init()), name:"type")
            let previewdata =  MultipartFormData.init(provider: .data("\(preview)".data(using: .utf8) ?? Data.init()), name:"preview")
            formdatas.append(typeformdata)
            formdatas.append(previewdata)
            return Provider.rx.request(.upload(formdatas, path: urlpath, methodType: .post))
        case .taskVideo(let videopath,let preview,let type):
            var  formdatas = [MultipartFormData]()
            //            var  i = 0
            //            for  videopath  in  videopaths {
            if  let url = URL.init(string: videopath) {
                let viformdata = MultipartFormData(provider: .file(url), name: "file", fileName: fileName, mimeType: "video/mp4")
                formdatas.append(viformdata)
            }
            //                i = i + 1
            //            }
            
            
            let typeformdata =  MultipartFormData.init(provider: .data("\(type.rawValue)".data(using: .utf8) ?? Data.init()), name:"type")
            
            let previewdata =  MultipartFormData.init(provider: .data("\(preview)".data(using: .utf8) ?? Data.init()), name:"preview")
            formdatas.append(typeformdata)
            formdatas.append(previewdata)
            return Provider.rx.request(.upload(formdatas, path: urlpath, methodType: .post))
        case .taskVoice(let voicepath, let preview, let type):
            var  formdatas = [MultipartFormData]()
            //            for  voicepath  in  voicepaths {
            let url = URL.init(fileURLWithPath: voicepath)
            let voiceformdata = MultipartFormData(provider: .file(url), name: "file", fileName: fileName, mimeType: "audio/AMR")
            formdatas.append(voiceformdata)
            
            //                i = i + 1
            //            }
            let typeformdata =  MultipartFormData.init(provider: .data("\(type.rawValue)".data(using: .utf8) ?? Data.init()), name:"type")
            
            let previewdata =  MultipartFormData.init(provider: .data("\(preview)".data(using: .utf8) ?? Data.init()), name:"preview")
            formdatas.append(typeformdata)
            formdatas.append(previewdata)
            
            
            
            return Provider.rx.request(.upload(formdatas, path: urlpath, methodType: .post))
        }
        
        
        
    }
    
}

extension RTUploadFileTool {
    
    /// 获取资源结果
    /// - Parameters:
    ///   - resourceType: <#resourceType description#>
    ///   - type: <#type description#>
    ///   - resources: <#resources description#>
    ///   - successdata: <#successdata description#>
    ///   - disposebag: <#disposebag description#>
    static func uploadgreetingResourceList<T>(_ resourceType:UpLoadResourceType,type:UpLoadType = .greeting , _ resources:Array<T> , _ successdata:@escaping uploadSuccessResourceListsBlock ,disposebag:DisposeBag) {
        let groupQuene = DispatchGroup.init()
        switch resourceType  {
        case .image:
            if let  resourceDatas =  resources as? [ZLPhotoModel] {
                var  creatsnapresoucelists = [GreetingResourceList]()
                creatsnapresoucelists = Array.init(repeating: GreetingResourceList.init(duration: 0, previewUrl: nil, url: nil), count: resourceDatas.count)
                for (index,model) in resourceDatas.enumerated() {
                    groupQuene.enter()
                    RTUploadFileTool.uploadAsset(model, type:type, resourcelistblock: { (result) in
                        defer{
                            groupQuene.leave()
                        }
                        
                        if result.url != nil {
                            creatsnapresoucelists[index] = result
                        }
                    }, disposebag)
                    
                    
                }
                groupQuene.notify(queue: DispatchQueue.main) {
                    successdata(creatsnapresoucelists)
                }
            }
            break
            
        case .video:
            
            if let  resourceDatas =  resources as? [ZLPhotoModel] {
                var  creatsnapresoucelists = [GreetingResourceList]()
                creatsnapresoucelists = Array.init(repeating: GreetingResourceList.init(duration: 0, previewUrl: nil, url: nil), count: resourceDatas.count)
                for (index,model) in resourceDatas.enumerated() {
                    groupQuene.enter()
                    RTUploadFileTool.uploadAsset(model, type:type,resourcelistblock: { (result) in
                        defer{
                            groupQuene.leave()
                        }
                        
                        if result.url != nil {
                            creatsnapresoucelists[index] = result
                        }
                    }, disposebag)
                    
                    
                }
                groupQuene.notify(queue: DispatchQueue.main) {
                    successdata(creatsnapresoucelists)
                }
            }
            
            
            break
        case .audio:
            if let  resourceDatas =  resources as? [AudioInfo] {
                var  creatsnapresoucelists = [GreetingResourceList]()
                creatsnapresoucelists = Array.init(repeating: GreetingResourceList.init(duration: 0, previewUrl: nil, url: nil), count: resourceDatas.count)
                for (index,model) in resourceDatas.enumerated() {
                    groupQuene.enter()
                    RTUploadFileTool.uploadVoice(model, type:type,resourcelistblock: { (result) in
                        defer{
                            groupQuene.leave()
                        }
                        if result.url != nil {
                            creatsnapresoucelists[index] = result
                        }
                    }, disposebag)
                }
                groupQuene.notify(queue: DispatchQueue.main) {
                    successdata(creatsnapresoucelists)
                }
            }
            break
            
        default:
            break
        }
        
        
    }
}


extension  RTUploadFileTool {
    
    static func uploadAsset(_ model:ZLPhotoModel ,type:UpLoadType,resourcelistblock:@escaping uploadSuccessDataBlock , _ disposebag:DisposeBag) {
        if model.asset.mediaType == .image {
            model.fetImageData { (imgdata, filename, fullpath) in
                var  setionmage:(UIImage,String) = (UIImage(),"")
                if let imgdata  = UIImage.init(data: imgdata) {
                    setionmage.0 = imgdata
                }
                if let name = filename {
                    setionmage.1 = name
                }
                
                RTUploadFileTool.RTUploadFile(type: .taskMulityImage(setionmage.0, preview: true, type: type), fileName: setionmage.1)?.filterSuccessfulStatusCodes().subscribe({ (res) in
                    switch res {
                    case .success(let response):
                        let result = ReqResult.init(requestData: response.data)
                        var  uploadresponse:UploadResponseData?  = result.modeDataKJTypeSelf(typeSelf: UploadResponseData.self)
                        if let data =  uploadresponse ,let url = data.url  {
                            var resourcelist = GreetingResourceList.init(duration: 0, previewUrl: data.previewUrl, url: url)
                            resourcelist.width = setionmage.0.size.width
                            resourcelist.height = setionmage.0.size.height
                            resourcelistblock(resourcelist)
                        }
                        else{
                            DispatchQueue.main.async {
                                MBProgressHUD.showError("server  upload failed".localiz())
                            }
                        }
                    case .error(let err):
                        resourcelistblock(GreetingResourceList.init(duration: 0, previewUrl: nil, url: nil))
                        break
                    }
                    
                }).disposed(by: disposebag)
                
            }
        }
        else if model.asset.mediaType == .video{
            
            model.fetandConvertVideoData { (filename, fullpath) in
                var  videoinfo:(String,String) = ("","")
                if let path = fullpath {
                    videoinfo.0 = path
                }
                if let name  = filename {
                    videoinfo.1 = name
                }
                
                RTUploadFileTool.RTUploadFile(type: .taskVideo(videoinfo.0, preview: true, type: type), fileName: videoinfo.1)?.filterSuccessfulStatusCodes().subscribe({ (res) in
                    switch res {
                    case .success(let response):
                        var  uploadresponse:UploadResponseData? = ReqResult.init(requestData: response.data).modeDataKJTypeSelf(typeSelf: UploadResponseData.self)
                        if let data =  uploadresponse ,let url = data.url  {
                            FileManager.deleteTransFormFile(videoinfo.0)
                            var resourcelist = GreetingResourceList.init(duration: (model.asset.duration * 1000), previewUrl: data.previewUrl, url: url)
                            let size = RTUploadFileTool.getLocalImageSizeVideo(videoinfo.0)
                            resourcelist.width =  size.width
                            resourcelist.height =  size.height
                            resourcelistblock(resourcelist)
                            
                        }
                        else{
                            DispatchQueue.main.async {
                                MBProgressHUD.showError("server  upload failed".localiz())
                            }
                        }
                    case .error(let err):
                        debugPrint("--------------\(err)")
                        DispatchQueue.main.async {
                            MBProgressHUD.showError("server  upload failed".localiz())
                        }
                        break
                    }
                    
                }).disposed(by: disposebag)
                
            }
            
        }
        
    }
    
    static func uploadVoice(_ audioInfo:AudioInfo,type:UpLoadType,resourcelistblock:@escaping uploadSuccessDataBlock , _ disposebag:DisposeBag) {
        let duration = RTVoiceRecordManager.getAudioduration(urlpath: audioInfo.urlpath)
        RTUploadFileTool.RTUploadFile(type: .taskVoice(audioInfo.urlpath, preview: true, type: type), fileName: audioInfo.filename ?? "usertaskaudio")?.filterSuccessfulStatusCodes().subscribe({ (res) in
            switch res {
            case .success(let response):
                var  uploadresponse:UploadResponseData? = ReqResult.init(requestData: response.data).modeDataKJTypeSelf(typeSelf: UploadResponseData.self)
                if let data =  uploadresponse ,let url = data.url  {
                    let resourcelist = GreetingResourceList.init(duration: Double(duration), previewUrl: data.previewUrl, url: url)
                    resourcelistblock(resourcelist)
                }
                else{
                    DispatchQueue.main.async {
                        MBProgressHUD.showError("server  upload failed".localiz())
                    }
                }
            case .error(let err):
//                resourcelistblock(GreetingResourceList.init(duration: 0, previewUrl: nil, url: nil))
                DispatchQueue.main.async {
                    MBProgressHUD.showError("server  upload failed".localiz())
                }
                break
            }
            
        }).disposed(by: disposebag)
        
    }
    
}
extension  FileManager {
    static func  deleteTransFormFile(_ filepath:String) {
        if  FileManager.default.fileExists(atPath: filepath) {
            try? FileManager.default.removeItem(atPath: filepath)
        }
    }
}


extension  RTUploadFileTool {
    
    static  func getLocalImageSizeVideo(_ url:String) -> CGSize {
        let  strUrl = URL.init(string: url)
        if strUrl != nil {
            let asset = AVURLAsset.init(url:strUrl! , options: nil)
            let gen = AVAssetImageGenerator.init(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time:CMTime = CMTimeMake(value: 1, timescale: 1)
            
            do {
                let image = try gen.copyCGImage(at: time, actualTime: nil)
                return CGSize.init(width: image.width, height: image.height)
            } catch  {
                print("\(error)")
            }
        }
        
        return  CGSize.init(width: 0, height: 0)
    }
    
    
    
    
}

extension  RTUploadFileTool {
    func updateLocation(_ lat:Double,_ lng:Double ,disposebag:DisposeBag){
          MatchTaskGreetingProvider.init().matchUpdateLocation(lat: lat, lng: lng, disposebag).subscribe(onNext: { [weak self] (res) in
                debugPrint("update location success -----")
          },onError: { (err) in
                debugPrint("update location failed -----")
          }).disposed(by: disposebag)
      }
}
