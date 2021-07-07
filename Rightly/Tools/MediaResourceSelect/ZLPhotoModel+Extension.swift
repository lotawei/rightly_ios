//
//  ZLPhotoModel+Extension.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/23.
//

import Foundation
import Photos
import ZLPhotoBrowser

typealias FetchImageData = (_ img:Data, _ fileImagename:String? , _ urlpath:String?)->Void
typealias FetchVideoData = ( _ filename:String? , _ fullpath:String?)->Void
typealias ConvertBlock = (_ result:RTApiResult<String>) -> Void
extension  ZLPhotoModel {
    
    func  fetImageData( result:@escaping FetchImageData)  {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .original
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = false
        option.progressHandler = { (pro, error, stop, info) in
            DispatchQueue.main.async {
                //                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        let filename = asset.value(forKey: "filename") as? String
        PHImageManager.default().requestImageData(for: asset, options: option) { (data, _, _, info) in
            
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            
            if !cancel, let data = data {
                
                self.asset.requestContentEditingInput(with: nil) { (input, info) in
                    var path = input?.fullSizeImageURL?.absoluteString
                    if path == nil, let dir = self.asset.value(forKey: "directory") as? String, let name = self.asset.value(forKey: "filename") as? String {
                        path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
                    }
                    result(data,filename ,path)
                }
            }
        }
    }
    
    func  fetandConvertVideoData( result:@escaping FetchVideoData)  {
        _ = ZLPhotoManager.fetchAVAsset(forVideo: asset) { (avset, info) in
            
            if  let avurlasset = avset as? AVURLAsset {
                let url = URL.init(fileURLWithPath: avurlasset.url.absoluteString)
                AVURLAsset.convertMovToMP4(url) { (res) in
                    switch res {
                    case .success(let path):
                        guard let mp4path = path else {
                            result(avurlasset.url.lastPathComponent,avurlasset.url.absoluteString)
                            return
                        }
                        let newurlp = URL.init(fileURLWithPath: mp4path)
                        
                        result(newurlp.lastPathComponent,mp4path)
                    case .failed(let err):
                        result(nil,nil)
                    }
                }
//                result(avurlasset.url.lastPathComponent,avurlasset.url.absoluteString)
            }
            
        }
    }
    
    
    func  fetorignalVideoData( result:@escaping FetchVideoData)  {
        _ = ZLPhotoManager.fetchAVAsset(forVideo: asset) { (avset, info) in
            
            if  let avurlasset = avset as? AVURLAsset {
                result(avurlasset.url.lastPathComponent,avurlasset.url.absoluteString)
            }
            
        }
    }
    
}

extension  AVURLAsset {
    static  func  convertMovToMP4(_ url:URL,outresult:@escaping ConvertBlock  ){
        let asset = AVAsset(url: url) // video url from library
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileDir = dirPaths[0].appendingPathComponent("\(bundleIdentifier).convervideo", isDirectory: true)
        try? fileMgr.createDirectory(at: fileDir, withIntermediateDirectories: true, attributes: nil)
        
        let filePath = fileDir.appendingPathComponent(url.lastPathComponent)
        let targetURL = filePath.deletingPathExtension().appendingPathExtension("mp4")
        try? fileMgr.removeItem(at: targetURL)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540)
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.metadata = asset.metadata
        exportSession?.outputURL = targetURL
        exportSession?.exportAsynchronously {
            if exportSession?.status == .completed {
                print("AV export succeeded. \(targetURL)") //AV export succeeded.
                // outputUrl to post Audio on server
                outresult(RTApiResult<String>.init(result:targetURL.absoluteString, error: nil))
            } else if exportSession?.status == .cancelled {
                print("AV export cancelled.")
            } else {
                print("Error is \(String(describing: exportSession?.error))")
                outresult(RTApiResult.init(result: nil, error: NSError.init(domain: "无法转换", code: -88, userInfo: nil)))
            }
        }
    }
}
extension  String {
    static func randomStringWithLength (len : Int) -> NSString {
         let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

         let randomString : NSMutableString = NSMutableString(capacity: len)

         for  _ in 0...len {
             let length = UInt32 (letters.length)
             let rand = arc4random_uniform(length)
             randomString.appendFormat("%C", letters.character(at:Int(rand)))
         }

         return randomString
     }
     
}
