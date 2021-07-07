//
//  UIImageView+Ex.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/23.
//

import Foundation
import Kingfisher
import KingfisherWebP
extension  UIImageView {
    
    /// 扩展一个方法 加载资源很大的图片后到固定尺寸不会那么耗性能
    /// - Parameters:
    ///   - resource: URL
    ///   - targetSize: 目标固定大小尺寸的解码图片
    ///   - placeholder: 占位图
    ///   - options: 可支持webp或者自带默认的
    ///   - completionHandler: 返回图片结果
    func loadImage(with resource:URL?,targetSize:CGSize? = nil,placeholder:UIImage? = nil,options:KingfisherOptionsInfo? = nil ,completionHandler:((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        var  processoptions:KingfisherOptionsInfo? = options
        if let size = targetSize {
            processoptions =   [KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor.init(size: size))] + (options ?? [])
            self.kf.setImage(with: resource, placeholder: placeholder, options: processoptions, completionHandler: completionHandler)
        }
        else{
            self.kf.setImage(with: resource, placeholder: placeholder, options: processoptions, completionHandler: completionHandler)
        }
    }
}
