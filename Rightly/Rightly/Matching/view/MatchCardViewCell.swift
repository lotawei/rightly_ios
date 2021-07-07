//
//  MatchCardViewCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/12.
//
import Foundation
import Kingfisher
import Reusable
import RxSwift
class MatchCardViewCell: YHDragCardCell,NibReusable{
    
    var  removeAction:(()->Void)?=nil
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight =  85
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        return tableview
    }()
    @IBOutlet weak var leftAnimation: UIButton!
    @IBOutlet weak var rightAniamtion: UIButton!
    
    let disposebag:DisposeBag = DisposeBag.init()
    fileprivate  var  info:MatchGreeting?=nil
    @IBOutlet weak var disLikeBtn: UIButton!
    @IBOutlet weak var backimg: UIImageView!
    @IBOutlet weak var lockStackView: UIStackView!
    @IBOutlet weak var taskBtn: UIButton!
    @IBOutlet weak var displayLbl: UILabel!
    @IBOutlet weak var usernickname: UILabel!
    @IBOutlet weak var locktip: UILabel!
    @IBOutlet weak var lockImg: UIImageView!
    @IBOutlet weak var userstate: UIView!
    @IBOutlet weak var lbldetail: UITextView!
    @IBOutlet weak var visualView: UIView!
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpUserhomePage(_:)))
        self.visualView.addGestureRecognizer(tap)
        self.visualView.isUserInteractionEnabled = true
        MatchLimitCountManager.shared.unlockUser.subscribe(onNext: { [weak self] (userid) in
            guard let `self` = self  else {return }
            if (self.info?.userId ?? 0) == userid {
                self.lockStackView.isHidden = true
                self.visualView.alpha = 0.1
            }
        }).disposed(by: self.disposebag)
        lbldetail.alpha = 0
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadow(type:.all, color: UIColor.lightGray, opactiy: 0.2, shadowSize: 3)
    }
    func  updateInfo(_ info:MatchGreeting) {
        self.info = info
        self.leftAnimation.alpha = 0
        self.rightAniamtion.alpha = 0
        if let vtype =  info.bgViewType{
            switch vtype {
            case .Private:
                self.visualView.alpha = visualAlpha
                lockStackView.isHidden = false
                locktip.text = "完成任务解锁".localiz()
            default:
                self.visualView.alpha = 0.1
                lockStackView.isHidden = true
            }
        }
        if  (info.isUnlock) {
            self.visualView.alpha = 0.1
            lockStackView.isHidden = true
        }
        self.usernickname.text = info.nickname
//        self.usernickname.text = "竞技等级阿胶浆大家速度嚼啊嚼可视对讲看看见啊手机卡加快速度看见啊手机打开"
        let backPlaceImg = UIImage(named:"images", in:Bundle.init(for: self.classForCoder), compatibleWith: nil)
        info.preBackImageProcess.asObservable().subscribe(onNext: { [weak self] (res) in
             guard let `self` = self  else {return }
            if  res == nil {
                self.backimg.image = backPlaceImg
            }else{
                self.backimg.image = res
            }
        }).disposed(by: self.rx.disposeBag)
       
        if let age = info.age {
            self.displayLbl.text = "\(age)"
        }
        if let gender = info.gender{
            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + gender.desGender
        }
        if let city = info.location?.city ,!city.isEmpty{
            self.displayLbl.text = (self.displayLbl.text ?? "") + "," + city
        }
        self.userstate.isHidden = !(info.isOnline ??  false)
        self.lbldetail.attributedText = info.task?.getTaskNoTaskImageDesc(.center,font: 24)
        self.lbldetail.textAlignment = .center
//        self.taskBtn.backgroundColor = info.task?.type.taskNewVersionColor()
        self.taskBtn.setBackgroundImage(info.task?.type.taskBtnBackGroundImage(), for: .normal)
        
    }
    @objc func jumpUserhomePage(_ sender:UITapGestureRecognizer){
        guard let usid = info?.userId else {
            return
        }
        if !UserManager.isOwnerMySelf(usid) {
            self.jumpUSer(userid: usid)
        }
        
    }
    
    
    @IBAction func dislikeAction(_ sender: Any) {
        self.removeAction?()
    }
    
    @IBAction func dotask(_ sender: Any) {
        guard let usid = info?.userId else {
            return
        }
        if !UserManager.isOwnerMySelf(usid) {
            GlobalRouter.shared.dotaskUser(usid)
        }
    }
    
}
