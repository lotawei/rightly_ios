//
//  DynamicBaseTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import UIKit
import RxSwift

class DynamicBaseTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var topIconImageView1: UIImageView!
    @IBOutlet weak var timeLabel1: UILabel!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var viewTypeLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var timeView2: UIView!
    @IBOutlet weak var topIconImageView2: UIImageView!
    @IBOutlet weak var timeLabel2: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var taskView: UIView!
    @IBOutlet weak var taskIconImageView: UIImageView!
    @IBOutlet weak var taskDescLabel: UILabel!
    
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicTableView: DynamicTopicTableView!
    
    @IBOutlet weak var dynamicDataView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var giftNumBtn: UIButton!
    @IBOutlet weak var likeNumBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineNodeView: UIView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var customContentViewHeight: NSLayoutConstraint!
    
    var viewModel:DynamicDataViewModel?
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.loadBaseViewFromXib()
        self.loadChildViewFromXib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadBaseViewFromXib() {
        let baseViewNib = UINib.init(nibName: "DynamicBaseTableViewCell", bundle: nil)
        let nibView:UIView = baseViewNib.instantiate(withOwner: self, options: nil).first as! UIView
        self.contentView.addSubview(nibView)
        
        nibView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    open func loadChildViewFromXib() {
        guard let childClassName = type(of: self).description().components(separatedBy: ".").last else {
            return
        }
        
        let childViewNib = UINib.init(nibName: childClassName, bundle: nil)
        let nibView:UIView = childViewNib.instantiate(withOwner: self, options: nil).first as! UIView
        self.customContentView.addSubview(nibView)
        
        nibView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func bindingViewModel(_ viewModel:DynamicDataViewModel, _ listType:DynamicListType, _ isLastCell:Bool = false) {
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        
        if listType == .myDynamics || listType == .otherDynamics {
            self.userInfoView.isHidden = true
            self.timeView2.isHidden = false
            self.lineView.isHidden = false
            self.viewTypeLabel.isHidden = listType == .otherDynamics
            
            self.topIconImageView2.isHidden = !viewModel.isTop.value
            self.lineNodeView.isHidden = viewModel.isTop.value
            self.timeLabel2.text = viewModel.pushDate
            self.lineImageView.image = UIImage.init(named: isLastCell ? "dynamic_personal_fade_away_line" : "dynamic_personal_line")
        } else {
            self.userInfoView.isHidden = false
            self.timeView2.isHidden = true
            self.lineView.isHidden = true
            self.viewTypeLabel.isHidden = !viewModel.isMyself
            
            self.topIconImageView1.isHidden = !viewModel.isTop.value
            self.headImageView.kf.setImage(with: viewModel.headURL, placeholder: UIImage.init(named: viewModel.placeHeadImageName))
            self.nickNameLabel.text = viewModel.nickName
            self.timeLabel1.text = viewModel.pushDate
        }
        
        self.topicView.isHidden = viewModel.topicList.count <= 0
        
        if let taskModel = viewModel.task {
            self.taskView.isHidden = false
            self.taskView.backgroundColor = taskModel.type.NewTaskTipBackColor()
            self.taskIconImageView.image = UIImage.init(named: taskModel.type.typeTitleIconName())
            self.taskDescLabel.textColor = taskModel.type.taskDescColor()
            self.taskDescLabel.text = taskModel.descriptionField
        } else {
            self.taskView.isHidden = true
        }
        
        if let desc = viewModel.contentDesc, desc.count > 0 {
            self.descLabel.attributedText = desc.exportEmojiTransForm()
            self.descLabel.isHidden = false
        } else {
            self.descLabel.isHidden = true
        }
        
//        if let address = viewModel.address, address.count > 0 {
//            self.locationView.isHidden = false
//            self.locationLabel.text = address
//        } else {
//            self.locationView.isHidden = true
//        }
//
        self.viewModel?.requestLocation()
        self.subscribeViewModel()
        self.topicTableView.cellDatas = viewModel.topicList
        self.topicTableView.setContentOffset(.zero, animated: false)
        self.topicTableView.reloadData()
    }
    
    func subscribeViewModel() {
        self.viewModel?.isLike.subscribe(onNext:{ [weak self] (state) in
            guard let `self` = self else {return}
            self.likeNumBtn.isSelected = state
        }).disposed(by: self.disposeBag)

        self.viewModel?.commentNum.subscribe(onNext:{ [weak self] (num) in
            guard let `self` = self else {return}
            self.commentBtn.isHidden = num < 0
            self.commentBtn.setTitle(String(num), for: .normal)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.giftNum.subscribe(onNext:{ [weak self] (num) in
            guard let `self` = self else {return}
            self.giftNumBtn.isHidden = num < 0
            self.giftNumBtn.setTitle(String(num), for: .normal)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.likeNum.subscribe(onNext:{ [weak self] (num) in
            guard let `self` = self else {return}
            self.likeNumBtn.isHidden = num < 0
            self.likeNumBtn.setTitle(String(num), for: .normal)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.viewType.subscribe(onNext:{ [weak self] (type) in
            guard let `self` = self else {return}
            self.viewTypeLabel.text = type == .Public ? "Public".localiz() : "Private".localiz()
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.isTop.subscribe(onNext:{ [weak self] (state) in
            guard let `self` = self else {return}
            self.topIconImageView1.isHidden = !state
            self.topIconImageView2.isHidden = !state
            self.lineNodeView.isHidden = state
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.decodeLocationCity.subscribe(onNext: { [weak self] (city) in
            guard let `self` = self  else {return }
            if  city.isEmpty {
                self.locationView.isHidden = true
            }else{
                self.locationView.isHidden = false
                self.locationLabel.text = city
            }
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - Action
extension DynamicBaseTableViewCell {
    @IBAction func headBtnAction(_ sender: UIButton) {
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        
        guard let userid = Int64(self.viewModel?.userId ?? "0") else {
            return
        }
        
        let personalVc = PersonalViewController.loadFromNib()
        personalVc.userid = userid
        if !UserManager.isOwnerMySelf(userid) {
            currentvc.navigationController?.pushViewController(personalVc, animated: true)
        }
    }
    
    @IBAction func likeBtnAction(_ sender: UIButton) {
        self.viewModel?.requestLike()
    }
    
    @IBAction func commentBtnAction(_ sender: UIButton) {
        guard let vm = self.viewModel, let currentvc = self.getCurrentViewController() else {
            return
        }
        
        let ctrl = DynamicDetailsViewController.init(vm)
        currentvc.navigationController?.pushViewController(ctrl, animated: true)
    }
}
