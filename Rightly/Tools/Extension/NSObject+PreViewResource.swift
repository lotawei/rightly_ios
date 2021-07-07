//
//  NSObject+PreViewResource.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/9.
//

import Foundation
import Photos
import ZLPhotoBrowser
import JXPhotoBrowser
extension   NSObject {
    
    /// 预览图片
    /// - Parameters:
    ///   - resources: 资源数组
    ///   - selectindex: 选中页数
    func jumpPreViewResource(resources:[Any],selectindex:Int? = 0)  {
            
        let filterDatas = resources.filter { (obj) -> Bool in
            return obj is PHAsset || obj is UIImage || obj is URL
        }

        guard let currentVc = self.getCurrentViewController() else {
            return
        }
        let videoSuffixs = ["mp4", "mov", "avi", "rmvb", "rm", "flv", "3gp", "wmv", "vob", "dat", "m4v", "f4v", "mkv"] // and more suffixs
        ZLPhotoConfiguration.default().allowSelectOriginal = true
        ZLPhotoConfiguration.default().allowSelectImage = false
        ZLPhotoConfiguration.default().allowPreviewPhotos = true
        let previewVC = ZLImagePreviewController(datas:filterDatas ,index: selectindex ?? 0, showSelectBtn: false, showBottomView: false){ (url) -> ZLURLType in

            if let sf = url.absoluteString.split(separator: ".").last, videoSuffixs.contains(String(sf)) {
                return .video
            } else {
                return .image
            }
        } urlImageLoader: { (url, imageView, progress, loadFinish) in
            imageView.kf.setImage(with: url) { (receivedSize, totalSize) in
                let percentage = (CGFloat(receivedSize) / CGFloat(totalSize))
                debugPrint("\(percentage)")
                progress(percentage)
            } completionHandler: { (_) in
                loadFinish()
            }
        }
        previewVC.modalPresentationStyle = .fullScreen
        currentVc.showDetailViewController(previewVC, sender: nil)
    }
    
    /// 新样式的api
    /// - Parameters:
    ///   - resources: <#resources description#>
    ///   - selectindex: <#selectindex description#>
    ///   - collectionView: <#collectionView description#>
    func jumpNewPreViewResource(resources:[Any],selectindex:IndexPath = IndexPath.init(item: 0, section: 0),collectionView:UICollectionView? = nil)  {
        let browser = JXPhotoBrowser()
        // 浏览过程中实时获取数据总量
        browser.numberOfItems = {
           return resources.count
        }
        // 刷新Cell数据。本闭包将在Cell完成位置布局后调用。
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            let indexPath = IndexPath(item: context.index, section: selectindex.section)
            if resources[indexPath.item] is UIImage ,let image = resources[indexPath.item] as? UIImage{
                browserCell?.imageView.image = image
            }
            if resources[indexPath.item] is URL ,let imageUrl = resources[indexPath.item] as? URL{
                browserCell?.imageView.kf.setImage(with: imageUrl)
            }
            
        }
        if let collectionV = collectionView {
            //动画的
            browser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, destinationView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
                let path = IndexPath(item: index, section: selectindex.section)
                guard let cell = collectionV.cellForItem(at: path) as? MediaResourceCollectionViewCell else {
                    return nil
                }
                let image = cell.assetImage.image
                let transitionView = UIImageView(image: image)
                transitionView.contentMode = cell.assetImage.contentMode
                transitionView.clipsToBounds = true
                let thumbnailFrame = cell.assetImage.convert(cell.assetImage.bounds, to: destinationView)
                return (transitionView, thumbnailFrame)
            })
        }
        // UIPageIndicator样式的页码指示器
        browser.pageIndicator = JXPhotoBrowserNumberPageIndicator()
        // 可指定打开时定位到哪一页
        browser.pageIndex = selectindex.item
        
        // 展示
        browser.show()
    }
    
    /// 视频预览
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - cover: <#cover description#>
    func preViewVideo(url:URL,cover:URL? = nil)  {
        guard let currentVc =  UIViewController.getCurrentViewController() else {
            return
        }
        let  videovc = ZFPreVideoViewController.init()
        videovc.videoUrl = url
        videovc.coverUrl = cover
        currentVc.navigationController?.pushViewController(videovc, animated: true)
    }
    /// create preViewVideo
    func createPreViewVideo(url:URL,cover:URL? = nil) -> ZFPreVideoViewController {
        let  videovc = ZFPreVideoViewController.init()
        videovc.videoUrl = url
        videovc.coverUrl = cover
        return videovc
    }
    
}
