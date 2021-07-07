//
//  UIImage_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/2.
//

import Foundation

extension UIImage {
    
    /// 创建纯色图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 大小
    /// - Returns: UIImage
    static func createSolidImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        color.set()
        UIRectFill(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return resultImage
    }
}
extension  UIImage {
    /**
     * 获取图片的大小
     */
    static func getDataWith(_ hdImage: Any) -> Data {
        var data = Data.init()
        if let image = hdImage as? UIImage {
            data = image.jpegData(compressionQuality: 1) ?? Data.init()
        }
        return data
        
    }
}

public extension UIImage {
    
    /// 图片等比缩放
    ///
    /// - Parameters:
    ///   - image: 原始图片
    ///   - width: 需要缩放到的宽度
    /// - Returns: 缩放后的图片
    static func compressImage(image: UIImage, width: CGFloat) -> UIImage? {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let newWidth: CGFloat = width
        let newHeight = imageHeight / (imageWidth / newWidth)
        
        let widthScale = imageWidth / newWidth
        let heightScale = imageHeight / newHeight
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        if widthScale > heightScale {
            image.draw(in: CGRect(x: 0, y: 0, width: imageWidth / heightScale, height: newHeight))
        } else {
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: imageHeight / widthScale))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension UIImage {
    
    func smartCompressImageData() -> Data? {
        let  image = self
        /// 仿微信算法 *
        let width = Int(image.size.width ?? 0)
        let height = Int(image.size.height ?? 0)
        var updateWidth = width
        var updateHeight = height
        let longSide = Int(max(width, height))
        let shortSide = Int(min(width, height))
        let scale = Float(shortSide) / Float(longSide)
        // 大小压缩
        if shortSide < 1080 || longSide < 1080 {
            // 如果宽高任何一边都小于 1080
            updateWidth = width
            updateHeight = height
        } else {
            // 如果宽高都大于 1080
            if width < height {
                // 说明短边是宽
                updateWidth = 1080
                updateHeight = Int(1080 / scale)
                
            }else{
                updateWidth = Int(1080 / scale);
                updateHeight = 1080;
            }
        }
        let compressSize = CGSize(width: updateWidth, height: updateHeight)
        UIGraphicsBeginImageContext(compressSize)
        image.draw(in: CGRect(x: 0, y: 0, width: compressSize.width, height: compressSize.height))
        let compressImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // 质量压缩 50%
        let compressData = compressImage?.jpegData(compressionQuality: 0.5)
        return compressData
    }
    
    func smartCompressImg() -> UIImage? {
        let  image = self
        /// 仿微信算法 *
        let width = Int(image.size.width ?? 0)
        let height = Int(image.size.height ?? 0)
        var updateWidth = width
        var updateHeight = height
        let longSide = Int(max(width, height))
        let shortSide = Int(min(width, height))
        let scale = Float(shortSide) / Float(longSide)
        // 大小压缩
        if shortSide < 1080 || longSide < 1080 {
            // 如果宽高任何一边都小于 1080
            updateWidth = width
            updateHeight = height
        } else {
            // 如果宽高都大于 1080
            if width < height {
                // 说明短边是宽
                updateWidth = 1080
                updateHeight = Int(1080 / scale)
                
            }else{
                updateWidth = Int(1080 / scale);
                updateHeight = 1080;
            }
        }
        let compressSize = CGSize(width: updateWidth, height: updateHeight)
        UIGraphicsBeginImageContext(compressSize)
        image.draw(in: CGRect(x: 0, y: 0, width: compressSize.width, height: compressSize.height))
        let compressImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let compressData = compressImage?.jpegData(compressionQuality: 0.5)
        return compressImage
    }
    
    func compressWithMaxLength(_ maxLength: Int) -> Data? {
        var compress: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: compress) else {
            return nil
        }
        
        if data.count <= maxLength {
            return data
        }
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        // 装逼二分法压缩~~!
        for _ in 0..<6 {
            compress = (max + min) / 2
            data = self.jpegData(compressionQuality: compress)!
            if data.count < Int(Double(maxLength) * 1) {
                min = compress
            } else if data.count > maxLength {
                max = compress
            } else {
                break
            }
        }
        
        if data.count <= maxLength {
            return data
        }
        
        // 先压缩，再裁剪
        
        guard var resultImage = UIImage.init(data: data) else {
            return nil
        }
        
        var lastLenght: Int = 0
        while (data.count > maxLength && data.count != lastLenght) {
            lastLenght = data.count
            let imgsize = resultImage.size
            let ration: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            let size = CGSize.init(width: imgsize.width*ration, height: imgsize.height*ration)
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect.init(origin: .zero, size: size))
            if let img = UIGraphicsGetImageFromCurrentImageContext() {
                resultImage = img
            } else {
                break
            }
            UIGraphicsEndImageContext()
            if let d = resultImage.jpegData(compressionQuality: compress) {
                data = d
            } else {
                break
            }
        }
        return data
        
    }
    
}



extension UIImage {
    //heic
    static func convert(url: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    
}

extension  UIImage {
    
    func imageWithColor(color: UIColor) -> UIImage? {
            var image:UIImage? = withRenderingMode(.alwaysTemplate)
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            color.set()
            image?.draw(in:CGRect(x: 0, y: 0, width: size.width, height: size.height))
            image = UIGraphicsGetImageFromCurrentImageContext() ?? nil
            UIGraphicsEndImageContext()
            return image
    }
    
}
