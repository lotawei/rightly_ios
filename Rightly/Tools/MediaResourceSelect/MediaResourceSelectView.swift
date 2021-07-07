//
//  MediaResourceSelectView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/22.
//

import Foundation
import PhotosUI
import ZLPhotoBrowser
import Reusable
import Photos
import MBProgressHUD
import RxSwift
import RxCocoa
enum MediaResourceType:Int{
    case image,
         video,
         all
}
fileprivate var PriviewImageAddressKey = "PriviewImageAddressKey"
extension ZLPhotoModel {
    var priviewImage: UIImage? {
        set {
            objc_setAssociatedObject(self, &PriviewImageAddressKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &PriviewImageAddressKey) as? UIImage
        }
    }
}

class MediaResourceManager: NSObject {
    static let  shared:MediaResourceManager = MediaResourceManager.init()
    var allselectedMedia:BehaviorRelay<[ZLPhotoModel]> = BehaviorRelay.init(value: [])
    fileprivate var  allMediaModels:BehaviorRelay<[Any]> = BehaviorRelay.init(value: [1])
    var allowMaxPicResource:Int = 9
    var allowAllResource:Int = 9
    var allowMaxVideoResource:Int = 1
    var allowMinDuration:TimeInterval = 1
    var allowMaxDuration:TimeInterval = 30
    var mediaResourceType:MediaResourceType = .all
    var isAnimation:Bool = true
    func findIndex(_ zlModel:ZLPhotoModel) -> Int {
        let index = self.allselectedMedia.value.firstIndex { (m) -> Bool in
            return zlModel == m
        }
        return index ??  -1
    }
    
    func findModelSelected(_ zlmodel:ZLPhotoModel) -> Bool {
        let res = self.allselectedMedia.value.contains { (z) -> Bool in
            return z == zlmodel
        }
        return res
    }
    
    func selectModelAction(_ model:ZLPhotoModel)  {
        var newmodels = self.allselectedMedia.value
        let valueindex = self.findIndex(model)
        if valueindex != -1 {
            newmodels.remove(at: valueindex)
            self.allselectedMedia.accept(newmodels)
        } else {
            newmodels.append(model)
            self.allselectedMedia.accept(newmodels)
        }
    }
    
    
    
}
class MediaResourceSelectView: UIView ,NibLoadable {
    let disposeBag = DisposeBag()
    var mediaType:PHAssetMediaType = PHAssetMediaType.unknown
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        var newmodels = MediaResourceManager.shared.allselectedMedia.value
        newmodels.removeAll()
        MediaResourceManager.shared.allselectedMedia.accept(newmodels)
        self.collectionView.register(cellType: MediaResourceCameraCollectionView.self)
        self.collectionView.register(cellType: MediaResourceCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        let sizewidth = screenWidth / 3.0
        self.layout.itemSize = CGSize.init(width: sizewidth, height: sizewidth)
        MediaResourceManager.shared.allselectedMedia.subscribe(onNext: { [weak self] value in
            guard let `self` = self  else {return }
            self.collectionView.reloadData()
        }).disposed(by: self.rx.disposeBag)
        MediaResourceManager.shared.allMediaModels.subscribe(onNext: { [weak self] value in
            guard let `self` = self  else {return }
            self.collectionView.reloadData()
        }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func requestResource(_ type:MediaResourceType) {
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if type == .video  {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            mediaType = .video
            ZLPhotoConfiguration.default().allowRecordVideo  = true
            ZLPhotoConfiguration.default().maxSelectCount = MediaResourceManager.shared.allowMaxVideoResource
            ZLPhotoConfiguration.default().maxRecordDuration = Second(MediaResourceManager.shared.allowMaxDuration)
            ZLPhotoConfiguration.default().minRecordDuration = Second(MediaResourceManager.shared.allowMinDuration)
            ZLPhotoConfiguration.default().maxSelectVideoDuration = Second(MediaResourceManager.shared.allowMaxDuration)
            ZLPhotoConfiguration.default().minSelectVideoDuration = Second(MediaResourceManager.shared.allowMinDuration)
            
        } else if type == .image {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            mediaType = .image
            ZLPhotoConfiguration.default().allowSelectImage = true
            ZLPhotoConfiguration.default().allowTakePhoto  = true
            ZLPhotoConfiguration.default().maxSelectCount = MediaResourceManager.shared.allowMaxPicResource
        } else {
            option.predicate = NSPredicate(format: "mediaType == %ld OR mediaType == %ld", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            mediaType = .unknown
            ZLPhotoConfiguration.default().maxSelectCount = MediaResourceManager.shared.allowAllResource
        }
        
        ZLPhotoConfiguration.default().maxSelectVideoDuration = Second(MediaResourceManager.shared.allowMaxDuration)
        
        /// Load Photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                var  newdatas = [Any]()
                newdatas.append(1)
                DispatchQueue.global().async {
                    var mediaresource:PHFetchResult<PHAsset>
                    if type == .all {
                        mediaresource = PHAsset.fetchAssets(with: option)
                    } else {
                        mediaresource = PHAsset.fetchAssets(with: self.mediaType, options: option)
                    }
                    
                    for i in 0..<mediaresource.count {
                        let asset = mediaresource.object(at: i)
                        let zhphotoModel = ZLPhotoModel.init(asset: asset)
                        newdatas.append(zhphotoModel)
                    }
                    newdatas = newdatas.filter { (model) -> Bool in
                        if  let m = model as? ZLPhotoModel {
                            if m.asset.mediaType == .video {
                                return ( m.asset.duration > MediaResourceManager.shared.allowMinDuration) && ( m.asset.duration < MediaResourceManager.shared.allowMaxDuration)
                            }
                            else{
                                return true
                            }
                        }
                        return true
                    }
                    DispatchQueue.main.async {
                        MediaResourceManager.shared.allMediaModels.accept(newdatas)
                    }
                }
                
            case .denied, .restricted:
                DispatchQueue.main.async {
                    MBProgressHUD.showError("No permission".localiz())
                }
                
            case .notDetermined:
                DispatchQueue.main.async {
                    MBProgressHUD.showError("No permission".localiz())
                }
            case .limited:
                DispatchQueue.main.async {
                    MBProgressHUD.showError("Not limited".localiz())
                }
            @unknown default:
                DispatchQueue.main.async {
                    MBProgressHUD.showError("error occurred".localiz())
                }
            }
        }
    }
    
    func requestMediaResource(type:MediaResourceType) {
        
        SystemPermission.checkPhoto(alertEnable: true) {[weak self] (has) in
            guard let `self` = self  else {return }
            if has {
                self.requestResource(type)
            }
        }
        
        
    }
}
extension MediaResourceSelectView:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MediaResourceManager.shared.allMediaModels.value.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1){
//            return
//        }
//        if MediaResourceManager.shared.isAnimation {
//            UIView.stackViewEffect(view: cell, offsetY: 20, duration: 0.3)
//        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = MediaResourceManager.shared.allMediaModels.value[indexPath.row] as? ZLPhotoModel
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaResourceCameraCollectionView.self)
            cell.clickCamera = {
                [weak self] in
                self?.jumpCamera()
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaResourceCollectionViewCell.self)
            switch self.mediaType {
            case .image:
                cell.resourceType = .image
            case .video:
                cell.resourceType = .video
            default:
                cell.resourceType = .all
            }
            if let mo = model {
                mo.isSelected = MediaResourceManager.shared.findModelSelected(mo)
                cell.updateInfo(model: mo,index: (MediaResourceManager.shared.findIndex(mo) ?? 0) + 1)
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let model = MediaResourceManager.shared.allMediaModels.value[indexPath.row] as? ZLPhotoModel {
            jumpPreView([model.asset])
        } else {
            self.jumpCamera()
        }
    }
    
    func jumpCamera(){
        if self.mediaType == .image {
            ZLPhotoConfiguration.default().allowRecordVideo  = false
            ZLPhotoConfiguration.default().allowSelectImage = true
            ZLPhotoConfiguration.default().allowTakePhoto  = true
            if  MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowMaxPicResource  {
                MBProgressHUD.showError("Max photo ".localiz() + "\(MediaResourceManager.shared.allowMaxPicResource)")
                return
            }
        } else if self.mediaType == .video {
            ZLPhotoConfiguration.default().allowTakePhoto  = false
            ZLPhotoConfiguration.default().allowRecordVideo  = true
            if  MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowMaxVideoResource  {
                
                MBProgressHUD.showError("Max Video ".localiz() + "\(MediaResourceManager.shared.allowMaxVideoResource)")
                return
            }
        } else {
            
            if MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowAllResource {
                MBProgressHUD.showError("Max photo ".localiz() + "\(MediaResourceManager.shared.allowAllResource)")
                return
            }
        }
        
        SystemPermission.checkPhoto(alertEnable: true) {[weak self] (has) in
            guard let `self` = self  else {return }
            if has {
                //调相册拍照
                DispatchQueue.main.async {
                    guard let currentVc = self.getCurrentViewController() else {
                        return
                    }
                    ZLPhotoConfiguration.default().maxRecordDuration = Second(MediaResourceManager.shared.allowMaxDuration)
                    ZLPhotoConfiguration.default().minRecordDuration = Second(MediaResourceManager.shared.allowMinDuration)
                    let camera = ZLCustomCamera()
                    camera.takeDoneBlock = { [weak self] (image, videoUrl) in
                        self?.save(image: image, videoUrl: videoUrl)
                    }
                    currentVc.showDetailViewController(camera, sender: nil)
                }
            }
        }
        
    }
    
    func jumpPreView(_ phasset:[PHAsset])  {
        //调预览
        guard let currentVc = self.getCurrentViewController() else {
            return
        }
        
        var showSelect = true
        if self.mediaType == .image {
            if  MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowMaxPicResource  {
                showSelect = false
            }
        } else if self.mediaType == .video {
            if  MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowMaxVideoResource  {
                showSelect = false
            }
        } else {
            if  MediaResourceManager.shared.allselectedMedia.value.count >= MediaResourceManager.shared.allowAllResource  {
                showSelect = false
            }
        }
        let previewVC = ZLImagePreviewController(datas: phasset, showSelectBtn: false,showBottomView: false)
        previewVC.doneBlock = { [weak self] (res) in
            if !showSelect {
                return
            }
            for asset  in res {
                if let  assetvalue = asset as? PHAsset {
                    let zlmodel = ZLPhotoModel.init(asset: assetvalue)
                    MediaResourceManager.shared.selectModelAction(zlmodel)
                }
            }
        }
        previewVC.modalPresentationStyle = .fullScreen
        currentVc.showDetailViewController(previewVC, sender: nil)
    }
    
    func save(image: UIImage?, videoUrl: URL?) {
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        if let image = image {
            hud.show()
            ZLPhotoManager.saveImageToAlbum(image: image) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    var selectvalue =  MediaResourceManager.shared.allselectedMedia.value
                    selectvalue.append(ZLPhotoModel.init(asset: at))
                    MediaResourceManager.shared.allselectedMedia.accept(selectvalue)
                    var allvalue =  MediaResourceManager.shared.allMediaModels.value
                    allvalue.insert(ZLPhotoModel.init(asset: at), at: 1)
                    MediaResourceManager.shared.allMediaModels.accept(allvalue)
                    
                } else {
                    debugPrint("保存图片到相册失败")
                }
                hud.hide()
            }
        } else if let videoUrl = videoUrl {
            hud.show()
            ZLPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] (suc, asset) in
                if suc, let at = asset {
                    //                    self?.fetchImage(for: at)
                    var selectvalue =  MediaResourceManager.shared.allselectedMedia.value
                    selectvalue.append(ZLPhotoModel.init(asset: at))
                    MediaResourceManager.shared.allselectedMedia.accept(selectvalue)
                    var allvalue =  MediaResourceManager.shared.allMediaModels.value
                    allvalue.insert(ZLPhotoModel.init(asset: at), at: 1)
                    MediaResourceManager.shared.allMediaModels.accept(allvalue)
                } else {
                    debugPrint("保存视频到相册失败")
                }
                hud.hide()
            }
        }
    }
    
}
