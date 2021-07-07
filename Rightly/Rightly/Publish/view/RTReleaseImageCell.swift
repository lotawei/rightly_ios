//
//  WeChatMomentImageCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/9.
//

import Foundation
import Reusable
import Photos
import ZLPhotoBrowser
class RTReleaseImageCell: UICollectionViewCell,Reusable {
    var imageView: UIImageView!
    var playImageView: UIImageView!
    var closeBtn:UIButton!
    var model:ZLPhotoModel?=nil
    var imageIden:String?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cornerRadius = 8.0
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        playImageView = UIImageView(image: UIImage(named: "playVideo"))
        playImageView.contentMode = .scaleAspectFit
        playImageView.isHidden = true
        contentView.addSubview(playImageView)
        playImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        closeBtn = UIButton.init(type: .custom)
        closeBtn.setImage(UIImage.init(named: "删除"), for: .normal)
        closeBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        closeBtn.isHidden = true
        self.contentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-8)
            maker.top.equalToSuperview().offset(8)
            maker.width.height.equalTo(20)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.closeBtn.isHidden = true
        self.imageView.image = nil
    }
    func updateModel(model:ZLPhotoModel)  {
        self.model = model
        self.imageIden = model.asset.localIdentifier
        self.closeBtn.isHidden = (MediaResourceManager.shared.findIndex(model) != -1 ) ? false : true
        let w =  (screenWidth - 40 - 10) / 3
//        self.imageView.fetchImage(asset: model.asset, contentMode: .aspectFill, targetSize:CGSize.init(width: w, height: w))
        if model.priviewImage == nil {
            self.fetchImage(asset: model.asset, contentMode: .aspectFill, targetSize:CGSize.init(width: w, height: w))
        } else {
            self.imageView.image = model.priviewImage
        }
        guard let mediatype = self.model?.asset.mediaType else {
            self.playImageView.isHidden = true
            return
        }
        if mediatype == .video {
            self.playImageView.isHidden = false
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func  deleteAction(){
        guard let model  = self.model else {
            return
        }
        MediaResourceManager.shared.selectModelAction(model)
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
                self.imageView.image = image
               
            }
        }
    }
}
