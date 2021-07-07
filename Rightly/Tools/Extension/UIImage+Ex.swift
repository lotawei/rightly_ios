//
//  UIImage+Ex.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/23.
//

import Foundation
extension UIImage {
    func resizeImage() -> UIImage {
        return self.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: self.size.height, bottom: 0, right: self.size.height), resizingMode: .tile)
    }
}
extension UIImage {
    //修复旋转问题
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        
        guard let imageRef = cgImage else { return self }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: imageRef.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: imageRef.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: imageRef.bitmapInfo.rawValue) else { return self }
        context.concatenate(transform)
         
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
             
        default:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
         
        guard let newImageRef = context.makeImage() else { return self }
        return UIImage(cgImage: newImageRef)
    }
}
