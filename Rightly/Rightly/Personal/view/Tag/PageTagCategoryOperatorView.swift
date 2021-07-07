//
//  PageTagCategoryRemoveView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
import JXSegmentedView
import TagListView
import MJRefresh
class PageTagCategoryOperatorView: UIView,NibLoadable,JXSegmentedListContainerViewListDelegate {
    var mjrefreshHeader:GlobalRefreshAutoGiftHeader?
    @IBOutlet weak var scrollerView: UIScrollView!
    @IBOutlet weak var tagListView: TagListView!
    var  itemTags:[ItemTag] = []
    var categroyID:Int64?
    var emptyview:UIView?
    //当状态改变可强制刷新界面可配置空列表展示
    var  showEmpty:Bool = false {
        didSet{
            self.layoutIfNeeded()
        }
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.tagListView.alignment  = .left
        //视图所有的更改都靠监听 数据源的改变去重新配置视图
        UserTagsManager.shared.usertags.subscribe(onNext: { [weak self] (usetags) in
            guard let `self` = self  else {return }
            var  tags = UserTagsManager.shared.filterCategoryTags(self.itemTags)
            self.configtags(tags)
        }).disposed(by: self.rx.disposeBag)
        
        mjrefreshHeader = GlobalRefreshAutoGiftHeader.init(refreshingBlock: {
            self.updateCategoryTags()
        })
        self.scrollerView.mj_header = mjrefreshHeader
    }
    func loadCategerytags(_ categoryId:Int64)  {
        self.categroyID = categoryId
    }
    func updateCategoryTags()  {
        self.setEmtpyViewDelegate(target: self)
        guard let cid = self.categroyID else {
            return
        }
        UserTagsManager.shared.requestCategoryItemTags(cid) {[weak self] (tags) in
            guard let `self` = self  else {return }
            self.mjrefreshHeader?.endRefreshing()
            self.itemTags = tags
            self.configtags(tags)
            self.showEmpty = tags.count == 0
            self.setNeedsLayout()
        }
    }
    fileprivate func configtags(_ tags:[ItemTag])  {
        self.tagListView.removeAllTags()
        for tag in tags {
            let tagView =  self.tagListView.addTag(tag.name ??  "--")
            tagView.onTap = { [weak self] tagView in
                //添加到自己的标签中
                guard let `self` = self  else {return }
                if tagView.isSelected {
                    UserTagsManager.shared.untagSelect(tag)
                    tagView.isSelected = !tagView.isSelected
                }else{
                    if UserTagsManager.shared.tagSelected(tag) {
                        tagView.isSelected = !tagView.isSelected
                    }
                }
            }
            tagView.isSelected = tag.isselected
        }
    }
   
    
    func listView() -> UIView {
        return self
    }
}
extension PageTagCategoryOperatorView:EmptyViewProtocol{
    var showEmtpy: Bool {
        get {
            return showEmpty
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
