//
//  DisCoverGuideView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/10.
//

import Foundation
//话题详情引导
enum DisTopicEnterType {
    case  join(_ snapV:UIImage,_ size:CGSize,_ point:CGPoint)
    case  rank(_ snapV:UIImage,_ size:CGSize,_ point:CGPoint)
    case  vote(_ snapV:UIImage,_ size:CGSize,_ point:CGPoint)
}
class DisCoverGuideView:UIView,NibLoadable {
    @IBOutlet weak var holowJoinImageV: UIImageView!
    @IBOutlet weak var joinLable: UILabel!
    @IBOutlet weak var holowJoinArrowImageV: UIImageView!
    @IBOutlet weak var holowRankImageV: UIImageView!
    @IBOutlet weak var rankLable: UILabel!
    @IBOutlet weak var holowRankArrowImageV: UIImageView!
    @IBOutlet weak var holowVoteImageV: UIImageView!
    @IBOutlet weak var voteLable: UILabel!
    @IBOutlet weak var holowVoteArrowImageV: UIImageView!
    var guideId:String?=nil
    var disCoverEnterypes:[DisTopicEnterType] = []
    var doneBlock:curClickBlock?=nil
    func configHoloVs(guideId:String,_ disCoverEnterypes:[DisTopicEnterType])  {
        self.guideId = guideId
        self.disCoverEnterypes = disCoverEnterypes
        for itemType in disCoverEnterypes {
            switch itemType {
            case .join(let image, let size, let point):
                self.holowJoinImageV.image = image
                self.holowJoinArrowImageV.image = UIImage.init(named: "arrowjoin")
            case .rank(let image, let size, let point):
                self.holowRankImageV.image = image
                self.holowRankArrowImageV.image = UIImage.init(named: "arrowrank")
            case .vote(let image, let size, let point):
                self.holowVoteImageV.image = image
                self.holowVoteArrowImageV.image = UIImage.init(named: "arrowvote")
            default:
                break
            }
        }
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.joinLable.font = UIFont.getSystemGuideFontFimalyName(size: 18, custom: .FZSJ_CHUSKJDAL)
        self.rankLable.font = UIFont.getSystemGuideFontFimalyName(size: 18, custom: .FZSJ_CHUSKJDAL)
        self.voteLable.font = UIFont.getSystemGuideFontFimalyName(size: 18, custom: .FZSJ_CHUSKJDAL)
        self.joinLable.text = "Join match".localiz()
        self.rankLable.text = "Rank info".localiz()
        self.voteLable.text = "Enter vote".localiz()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneBlockclick(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    @objc func doneBlockclick(_ sender: Any) {
        guard let guid = self.guideId else {
            return
        }
        doneBlock?(guid)
        self.removeFromWindow()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let  lableWidth:CGFloat = 120
        for itemType in disCoverEnterypes {
            switch itemType {
            case .join(let image, let size, let point):
                self.holowJoinImageV.frame = CGRect.init(origin: point, size: size)
                self.holowJoinArrowImageV.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(89), height: scaleHeight(266))
                self.holowJoinArrowImageV.frame.origin  = CGPoint.init(x: holowJoinImageV.frame.minX + scaleWidth(89)/2.0 , y:holowJoinImageV.frame.minY - 10 - scaleHeight(266))
                self.joinLable.frame = CGRect.init(x: holowJoinArrowImageV.frame.minX - lableWidth*0.5, y: holowJoinArrowImageV.frame.minY - 10 - 20, width: lableWidth, height: 20)
            case .rank(let image, let size, let point):
                self.holowRankImageV.frame = CGRect.init(origin: point, size: size)
                self.holowRankArrowImageV.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(42), height: scaleHeight(64))
                self.holowRankArrowImageV.frame.origin  = CGPoint.init(x: holowRankImageV.frame.minX  - scaleWidth(42) + size.width/2.0 - 36, y:holowRankImageV.frame.maxY +  10)
                self.rankLable.frame = CGRect.init(x: holowRankArrowImageV.center.x - lableWidth*0.5, y: holowRankArrowImageV.frame.maxY + 10, width: lableWidth, height: 20)
            case .vote(let image, let size, let point):
                self.holowVoteImageV.frame = CGRect.init(origin: point, size: size)
                self.holowVoteArrowImageV.frame = CGRect.init(x: 0, y: 0, width: scaleWidth(89), height: scaleHeight(190))
                self.holowVoteArrowImageV.frame.origin  = CGPoint.init(x: holowVoteImageV.frame.minX  , y:holowVoteImageV.frame.minY -  10 - scaleHeight(190))
                self.voteLable.frame = CGRect.init(x: holowVoteArrowImageV.frame.maxX - lableWidth*0.5, y: holowVoteArrowImageV.frame.minY - 10 - 20, width: lableWidth, height: 20)
            default:
                break
            }
        }
    }
    
    
}
