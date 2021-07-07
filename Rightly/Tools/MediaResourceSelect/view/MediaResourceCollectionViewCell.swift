//
//  MediaResourceCollectionView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/22.
//

import Foundation
import Foundation
import Kingfisher
import Reusable
import Photos
import ZLPhotoBrowser
import MBProgressHUD
class MediaResourceCollectionViewCell: UICollectionViewCell,NibReusable{
    var imageIden:String?
    var resourceType:MediaResourceType = .all
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var masklayer: UIView!
    @IBOutlet weak var lblselectedindex: UILabel!
    @IBOutlet weak var btnselected: UIButton!
    var selectItem:ZLPhotoModel?=nil
    var mediaType:PHAssetMediaType = .unknown
    override  func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.duration.text = ""
        self.lblselectedindex.isHidden = true
    }
    @IBAction func checkBtn(_ sender: Any) {
        guard let model = self.selectItem  else {
            return
        }
        if self.resourceType == .image {
            if MediaResourceManager.shared.allselectedMedia.value.count < ZLPhotoConfiguration.default().maxSelectCount {
                MediaResourceManager.shared.selectModelAction(model)
            }
            else{
                if (  MediaResourceManager.shared.findIndex(model) != -1 ){
                    MediaResourceManager.shared.selectModelAction(model)
                }
                else{
                    MBProgressHUD.showError("Max photo ".localiz() + "\(MediaResourceManager.shared.allowMaxPicResource)")
                }
            }
        }
        else if self.resourceType == .video {
            if model.asset.duration > MediaResourceManager.shared.allowMaxDuration {
                MBProgressHUD.showError("Video Limmited  seconds by ".localiz() + "\(MediaResourceManager.shared.allowMaxDuration)")
                return
            }
            
            if MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowMaxVideoResource {
                MediaResourceManager.shared.selectModelAction(model)
            }
            else{
                if  (MediaResourceManager.shared.findIndex(model) != -1 ){
                    MediaResourceManager.shared.selectModelAction(model)
                }
                else{
                    MBProgressHUD.showError("Max video ".localiz() + "\(MediaResourceManager.shared.allowMaxVideoResource)")
                }
            }
        } else {
            if MediaResourceManager.shared.allselectedMedia.value.count < MediaResourceManager.shared.allowAllResource {
                MediaResourceManager.shared.selectModelAction(model)
            } else {
                if  (MediaResourceManager.shared.findIndex(model) != -1 ){
                    MediaResourceManager.shared.selectModelAction(model)
                } else{
                    MBProgressHUD.showError("Max photo ".localiz() + "\(MediaResourceManager.shared.allowAllResource)")
                }
            }
        }
    }
    func updateInfo(model:ZLPhotoModel,index:Int )  {
//        self.mediaType = model.asset.mediaType
        self.selectItem = model
        self.imageIden = model.asset.localIdentifier
        
        if model.priviewImage == nil {
            self.fetchImage(asset: model.asset, contentMode: .aspectFill, targetSize: CGSize.init(width: screenWidth/3.0, height: screenWidth/3.0))
        } else {
            self.assetImage.image = model.priviewImage
        }
//        self.assetImage.fetchImage(asset: model.asset, contentMode: .aspectFill, targetSize:  CGSize.init(width: screenWidth/3.0, height: screenWidth/3.0))
        if model.asset.mediaType == .video {
            self.duration.text = String.transToHourMinSec(time: Float(model.asset.duration))
        }
        else{
            self.duration.text = ""
        }
        self.lblselectedindex.text =  "\(index)"
        self.lblselectedindex.isHidden = !model.isSelected
        masklayer.alpha = (model.isSelected ==  true) ? 0.2:0
    }
    
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            @unknown default:
                break
            }
            
            if self.imageIden == asset.localIdentifier {
                self.assetImage.image = image
                self.selectItem?.priviewImage = image
            }
        }
    }
}

extension UIImageView {
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            @unknown default:
                break
            }
            self.image = image
        }
    }
}






