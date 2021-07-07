//
//  GreetTypeInfoView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/31.
//

import UIKit
import Kingfisher
import KingfisherWebP
//可解析webp或其它格式的
let  webpOptional:KingfisherOptionsInfo = [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]

class GreetTypeInfoView: UIView, NibLoadable {
    var resources:[ResourceViewModel]?
    var greetingID:String?=nil
    @IBOutlet weak var imageTypeView: UIView!
    @IBOutlet weak var imagePreviewView: UIImageView!
    @IBOutlet weak var imageLoadIcon: UIImageView!
    
    @IBOutlet weak var audioTypeView: UIView!
    @IBOutlet weak var audioPreviewView: UIImageView!
    @IBOutlet weak var audioLoadIcon: UIImageView!
    
    @IBOutlet weak var videoTypeView: UIView!
    @IBOutlet weak var videoPreviewView: UIImageView!
    @IBOutlet weak var videoLoadIcon: UIImageView!
    
    @IBOutlet weak var greetContentLabel: UILabel!
    
    @IBOutlet weak var clickBtn: UIButton!
    
    
    @IBAction func clickBtnAction(_ sender: UIButton) {
        guard let previewResources = self.resources else {
            return
        }
        
        var urls:[URL] = Array.init()
        for tempResource in previewResources {
            if let resourceURL = tempResource.contentURL {
                urls.append(resourceURL)
            }
        }
        self.jumpPreViewResource(resources: urls)
    }
    
    private func showImageTypeView(resource:ResourceViewModel?) {
        self.imageTypeView.isHidden = false
        self.imagePreviewView.kf.setImage(with: resource?.contentURL, placeholder: nil, options: nil) { (result) in
            switch result {
            case .success(_):
                self.imageLoadIcon.isHidden = true
            default:
                self.imageLoadIcon.isHidden = false
            }
        }
    }
    
    private func showVideoTypeView(resource:ResourceViewModel?) {
        self.videoTypeView.isHidden = false
        self.videoPreviewView.kf.setImage(with: resource?.previewURL, placeholder: nil, options: webpOptional) { (result) in
            switch result {
            case .success(_):
                self.videoLoadIcon.isHighlighted = true
            default:
                self.videoLoadIcon.isHighlighted = false
            }
        }
    }
    
    func bindGreetingData(_ task:TaskBrief?, resources:[ResourceViewModel], content:String? ,greetingID:String?) {
        self.greetContentLabel.text = content
        
        self.imageTypeView.isHidden = true
        self.audioTypeView.isHidden = true
        self.videoTypeView.isHidden = true
        self.greetingID = greetingID
        switch task?.type {
        case .photo:
            self.showImageTypeView(resource: resources.first)
        case .voice:
            self.audioTypeView.isHidden = false
        case .video:
            self.showVideoTypeView(resource: resources.first)
        default:
            debugPrint("")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let greettap = UITapGestureRecognizer.init(target: self, action: #selector(jumpGreetingDetail(_:)))
        self.addGestureRecognizer(greettap)
        self.isUserInteractionEnabled = true
    }
    
    @objc func jumpGreetingDetail(_ sender: Any) {
        guard let greetingid = self.greetingID else {
            self.getCurrentViewController()?.toastTip("Greeting Delete".localiz())
            return
        }
        
        GlobalRouter.shared.jumpDynamicDetail(greetingid)
    }
}
