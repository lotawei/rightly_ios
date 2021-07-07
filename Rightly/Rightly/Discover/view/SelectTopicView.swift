//
//  SelectTopicView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/27.
//

import Foundation
import RxSwift
import TagListView
import MJRefresh
typealias SelectedTopicBlock = ((_ models:[DiscoverTopicModel]) -> Void)
class SelectTopicView: UIView,NibLoadable {
    var selectedBlock:SelectedTopicBlock?=nil
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    @IBOutlet weak var itemscrollerview: UIScrollView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var addtipLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    fileprivate var  userselectedTopics:[DiscoverTopicModel] = []
    var emptyview:UIView?
    var emptyshow = false {
        didSet{
            self.itemscrollerview.setNeedsLayout()
        }
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.tagListView.alignment  = .left
        self.addtipLabel.text = "Add topic".localiz()
        self.addBtn.setTitle("Add".localiz(), for: .normal)
        self.closeBtn.setTitle("Close".localiz(), for: .normal)
        mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            self.requestTopicItems()
        })
        self.itemscrollerview.mj_header = mjrefreshHeader
        self.itemscrollerview.setEmtpyViewDelegate(target: self)
    }
    
    func requestTopicItems()  {
        DiscoverProvider.init().gainTopicselectData(self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            self.mjrefreshHeader?.endRefreshing()
            if let  selectTopics = res.modelArrType(DiscoverTopicModel.self) {
                self.configtags(selectTopics)
            }
//            switch res {
//            case .success(let topicsdata):
//                guard let selectTopics = topicsdata else {
//                    return
//                }
//
//                self.configtags(selectTopics)
//                break
//            case .failed(let err):
//                MBProgressHUD.showError("Network Failed".localiz())
//            }
//
        },onError: { (err) in
            MBProgressHUD.showError("Network Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    fileprivate func configtags(_ tags:[DiscoverTopicModel])  {
        self.tagListView.removeAllTags()
        for tag in tags {
            let tagView =  self.tagListView.addTag(tag.name ??  "--")
            tagView.onTap = { [weak self] tagView in
                //添加到自己的标签中
                guard let `self` = self  else {return }
                if tagView.isSelected {
                    tagView.isSelected = !self.selectTopicTag(tag, isselected: false)
                }else{
                    tagView.isSelected =  self.selectTopicTag(tag, isselected: true)
                }
            }
            tagView.tagViewForMatch(ismatch: tag.isMatch ?? false)
            tagView.isSelected = tag.isselected 
        }
        self.emptyshow = tags.count == 0
    }
    
    func selectTopicTag(_  topic:DiscoverTopicModel, isselected:Bool) -> Bool  {
        if isselected {
            if (topic.isJoin ?? true) && ( topic.isMatch ?? false){
                self.windowToastTip("不可重复参加该话题".localiz())
                return false
            }
            if self.userselectedTopics.count == 3 {
                self.windowToastTip("最多选择3个同类型话题".localiz())
                return false
            }
            
            for selectedTopic in self.userselectedTopics {
                if topic.type !=  selectedTopic.type {
                    self.windowToastTip("无法添加不同话题类型".localiz())
                    return false
                }else{
                    self.userselectedTopics.append(topic)
                    return true
                }
            }
            self.userselectedTopics.append(topic)
            return true
        }else{
            if self.userselectedTopics.contains(where: { (model) -> Bool in
                return topic.topicId == model.topicId
            }) {
                self.userselectedTopics.removeAll { (model) -> Bool in
                    return topic.topicId == model.topicId
                }
                return true
            }
            return false
        }
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.removeFromWindow()
    }
    
    @IBAction func addAction(_ sender: Any) {
        if self.userselectedTopics.count == 0  {
            self.windowToastTip("Select a topic".localiz())
            return
        }
        self.selectedBlock?(self.userselectedTopics)
        self.removeFromWindow()
    }
}
extension SelectTopicView:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return emptyshow
        }
    }
    func configEmptyView() -> UIView? {
        if let view = self.emptyview {
            return view
        }
        let  emptyv = EmptyView.loadNibView()
        emptyv?.frame = self.bounds
        emptyv?.placeimage.image = UIImage(named: "emptyview")
        self.emptyview = emptyv
        return emptyv
    }
}
