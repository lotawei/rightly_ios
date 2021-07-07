//
//  GuideOtherTipView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/30.
//

import Foundation
typealias curClickBlock = ((_ guideid:String)->Void)
class GuideMatchTipView:UIView,NibLoadable {
    var  guideId:GuideEnter?=nil
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var guideHandsImage: UIImageView!
    @IBOutlet weak var largeTitle: UILabel!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var stackCenterY: NSLayoutConstraint!
    var doneBlock:curClickBlock?=nil
    @IBOutlet weak var bodystackView: UIStackView!
    @IBAction func doneBlockclick(_ sender: Any) {
        guard let guid = self.guideId?.rawValue else {
            return
        }
        doneBlock?(guid)
        self.removeFromWindow()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneBlockclick(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        //load custom fonts
        self.subTitle.font = UIFont.getSystemGuideFontFimalyName(size: 18, custom: .FZSJ_CHUSKJDAL)
        self.largeTitle.font = UIFont.getSystemGuideFontFimalyName(size: 18, custom: .FZSJ_CHUSKJDAL)
    }
    fileprivate var  targetSize:CGSize  = .zero
    fileprivate var  targetPosition:CGPoint = .zero
    /// 配置视图
    /// - Parameters:
    ///   - guid: 引导id
    ///   - holoView: 镂空视图
    ///   - size: 镂空大小
    ///   - point: 镂空位置
    func configGuideView(_ guid:GuideEnter, holoView:UIImage, size:CGSize, point:CGPoint) {
        img.clipsToBounds = false
        self.guideId = guid
        self.targetSize = size
        self.targetPosition = point
        self.img.image = holoView
        switch guid {
        case .MacthOtherDisLikeTip:
            self.largeTitle.text = "Not interested in him".localiz()
            self.subTitle.text = "You can swipe left or click the close button to skip".localiz()
            self.sureBtn.setTitle("I known".localiz(), for: .normal)
            guideHandsImage.image = UIImage.init(named: "guidehandleft")
        case .MacthOtherLikeTip:
            self.largeTitle.text = "Like him".localiz()
            self.subTitle.text = "Swipe right or click the \"reply\" button to establish a connection".localiz()
            self.sureBtn.setTitle("eng_ok".localiz(), for: .normal)
            guideHandsImage.image = UIImage.init(named: "guidehandright")
        case .MatchViewFilter:
            self.largeTitle.text = "Want to find interested people faster".localiz()
            self.subTitle.text = "Click this button to add the filter conditions you want".localiz()
            self.sureBtn.setTitle("That’s great".localiz(), for: .normal)
            guideHandsImage.image = UIImage.init(named: "guidefilter")
        default:
            break
        }
        
    }
    
    fileprivate func layoutViews() {
        let  boudnsize = self.bounds.size
        if let gid = self.guideId {
            switch gid {
            case .MacthOtherDisLikeTip:
                let  idicateHeight:CGFloat = 264.0
                let idicateWidth  = scaleWidth(143)
                img.clipsToBounds = true
                img.backgroundColor = UIColor.white
                img.layer.cornerRadius = self.targetSize.width/2.0
                img.layer.borderWidth = 1
                self.img.frame = CGRect.init(x: self.targetPosition.x, y: self.targetPosition.y, width: self.targetSize.width, height: self.targetSize.height)
                self.stackCenterY.constant = 50
                
                guideHandsImage.frame = CGRect.init(x: 0, y:0, width: idicateWidth, height: idicateHeight)
                guideHandsImage.frame.origin = CGPoint.init(x: self.center.x - idicateWidth/2.0, y: self.bodystackView.frame.minY - CGFloat(idicateHeight)  - 21)
            case .MacthOtherLikeTip:
                let  idicateHeight = scaleHeight(264)
                let idicateWidth  = scaleWidth(143)
                img.clipsToBounds = true
                //                img.backgroundColor = UIColor.white
                img.layer.cornerRadius = 31 //死的
                img.layer.borderWidth = 0
                img.layer.borderColor = UIColor.clear.cgColor
                self.img.frame = CGRect.init(x: self.targetPosition.x, y: self.targetPosition.y, width: self.targetSize.width, height: self.targetSize.height)
                self.stackCenterY.constant = 80
                
                guideHandsImage.frame = CGRect.init(x: 0, y:0, width: idicateWidth, height: idicateHeight)
                guideHandsImage.frame.origin = CGPoint.init(x: self.center.x - idicateWidth/2.0, y: self.bodystackView.frame.minY - CGFloat(idicateHeight)  - 21)
                break
            case .MatchViewFilter:
                img.clipsToBounds = true
                img.layer.borderWidth = 1
                img.backgroundColor = UIColor.white
                img.layer.cornerRadius = self.targetSize.width/2.0
                img.layer.borderWidth = 1
                self.img.frame = CGRect.init(x: self.targetPosition.x, y: self.targetPosition.y, width: self.targetSize.width, height: self.targetSize.height)
                self.guideHandsImage.frame = CGRect.init(x: 0, y: 0, width: 81, height: 93)
                self.guideHandsImage.frame.origin = CGPoint.init(x: img.frame.maxX - 40 - 15, y: img.frame.maxY + 30) //自己算下拉
                self.stackCenterY.constant = 64
                break
            default:
                break
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }

}
