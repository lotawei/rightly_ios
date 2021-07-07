//
//  PageTagCategoryView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
import TagListView
import UIKit
import RxSwift
//为了区分是tag下的展示
enum TagDes:Int{
    case pub,
         mytag
}
//复用 tagselectViewController 后续复杂可拆
enum TagStyle {
    case  emptyTag, //第一次添加
          tagViewType(_ tagstate:TagDes), //标签公开管理
          tagManager,//标签增删
          otherTag(_ otherid:Int64)//他人标签
}
class PageTagOperatorTopView: UIView,NibLoadable {
    var  emptyview:UIView? = EmptyPublicTagView.loadNibView()
    @IBOutlet weak var lbltip: UILabel!
    @IBOutlet weak var stackItemMore: UIStackView!
    @IBOutlet weak var lblcount: UILabel!
    @IBOutlet weak var tagView: TagListView!
    fileprivate var tagstyle:TagStyle = .emptyTag
    @IBOutlet weak var lineview: UIView!
    var displayDataTags:[ItemTag] = []
    /// 配置界面加载样式
    /// - Parameter style:
    func  loadFirst(style:TagStyle){
        self.tagstyle = style
        switch style {
        case .emptyTag:
            self.stackItemMore.isHidden = false
            self.tagView.paddingX = 14
            self.tagView.enableRemoveButton = true
            self.lbltip.text = "Add your tag".localiz()
            self.lbltip.textColor = UIColor.init(hex: "27D3CF")
            self.lbltip.font = UIFont.systemFont(ofSize: 36)
            UserTagsManager.shared.usertags.subscribe(onNext: { [weak self] (tags) in
                guard let `self` = self ,let tags = tags else {return }
                let  selectedTags = tags.filter { (tag) -> Bool in
                    return tag.isselected
                }
                self.configtags(selectedTags)
                self.lblcount.text = "\(selectedTags.count)/20"
            }).disposed(by: self.rx.disposeBag)
        case .tagViewType(let typedes):
            self.stackItemMore.isHidden = false
            self.tagView.paddingX = 18
            if typedes == .pub {
                self.lineview.isHidden = false
                self.tagView.enableRemoveButton = true
                self.lbltip.text = "Public".localiz()
                self.lbltip.textColor = UIColor.black
                self.lbltip.font = UIFont.systemFont(ofSize: 18)
                UserTagsManager.shared.usertags.subscribe(onNext: { [weak self] (tags) in
                    guard let `self` = self ,let tags = tags else {return }
                    let filterOpenTags =  tags.filter { (tag) -> Bool in
                        return tag.viewType == ViewType.Public
                    }
                    self.configtags(filterOpenTags)
                    self.lblcount.text = "\(filterOpenTags.count)/20"
                }).disposed(by: self.rx.disposeBag)
            }else{
                self.lbltip.text = "My Tag".localiz()
                self.tagView.enableRemoveButton = false
                self.lbltip.textColor = UIColor.black
                self.lbltip.font = UIFont.systemFont(ofSize: 18)
                UserTagsManager.shared.usertags.subscribe(onNext: { [weak self] (atags) in
                    guard let `self` = self ,let tags = atags else {return }
                    self.configtags(tags)
                    self.lblcount.text = "\(tags.count)/20"
                }).disposed(by: self.rx.disposeBag)
            }
        case .tagManager:
            self.stackItemMore.isHidden = false
            self.tagView.paddingX = 14
            self.tagView.enableRemoveButton = true
            self.lbltip.text = "My Tag".localiz()
            self.lbltip.textColor = UIColor.black
            self.lbltip.font = UIFont.systemFont(ofSize: 18)
            UserTagsManager.shared.usertags.subscribe(onNext: { [weak self] (tags) in
                guard let `self` = self ,let tags = tags else {return }
                let  selectedTags = tags.filter { (tag) -> Bool in
                    return tag.isselected
                }
                self.configtags(selectedTags)
                self.lblcount.text = "\(selectedTags.count)/20"
            }).disposed(by: self.rx.disposeBag)
        case .otherTag(let id):
            self.stackItemMore.isHidden = true
            self.tagView.paddingX = 14
            self.tagView.enableRemoveButton = false
            self.lbltip.text = "TA的标签".localiz()
            self.lbltip.textColor = UIColor.init(hex: "27D3CF")
            self.lbltip.font = UIFont.systemFont(ofSize: 36)
            UserTagsManager.shared.othertags.subscribe(onNext: { [weak self] (tags) in
                guard let `self` = self ,let tags = tags else {return }
                self.configtags(tags,userEnable: false)
                self.lblcount.text = "\(tags.count)/20"
            }).disposed(by: self.rx.disposeBag)
        }
    }
    
    /// 配置视图标签
    /// - Parameter tags: <#tags description#>
    fileprivate func configtags(_ tags:[ItemTag] , userEnable:Bool = true)  {
        self.displayDataTags = tags
        self.tagView.removeAllTags()
        self.tagView.delegate = self
        configTagTextStyle()
        for tag in tags {
            let tagView =  self.tagView.addTag(tag.name ??  "--")
            if userEnable {
                tagView.onTap = { [weak self] tagView in
                    //移除当前标签
                    guard let `self` = self  else {return }
                    self.dealTaptag(tagView, tag: tag)
                }
                
            }
            self.configTagStyle(tagView, tag)
        }
        
        switch self.tagstyle{
        case .tagViewType(.pub):
            self.showEMptyView(tags.count == 0)
        default:
            break
        }
       
    }
    func showEMptyView(_ show:Bool) {
        if show {
            self.addSubview(self.emptyview!)
            self.emptyview?.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }else{
            self.emptyview?.removeFromSuperview()
        }
    }
    /// 处理点击手势
    /// - Parameters:
    ///   - tagV:
    ///   - tag:
    func  dealTaptag(_ tagV:TagView ,tag:ItemTag){
        switch self.tagstyle {
        case .emptyTag:
            if  UserTagsManager.shared.untagSelect(tag) {
                self.tagView.removeTagView(tagV)
            }
        case .tagViewType(let owertag):
            if owertag == .pub {
                UserTagsManager.shared.unpubSelectTag(tag)
            }else{
                if (tag.isLight ?? false) {
                    if tagV.isSelected {
                        UserTagsManager.shared.unpubSelectTag(tag)
                        tagV.isSelected = !tagV.isSelected
                    }else{
                        if UserTagsManager.shared.pubSelectTag(tag) {
                            tagV.isSelected = !tagV.isSelected
                        }
                    }
                }else{
                    self.goLightTag(tag)
                }
            }
        case .tagManager:
            if  UserTagsManager.shared.untagSelect(tag) {
                self.tagView.removeTagView(tagV)
            }
        case .otherTag:
            break
        default:
            break
        }
        
    }
    
    /// 设置整体标签样式
    func configTagTextStyle()  {
        switch self.tagstyle {
        case .emptyTag:
            tagView.loadGraySelectStyle()
        case .tagManager:
            tagView.loadGraySelectStyle()
        case .tagViewType(let des):
            tagView.loadLightSelectStyle()
        case .otherTag:
            tagView.loadLightSelectStyle()
        }
    }
    /// 按加载类型配置样式
    /// - Parameters:
    ///   - tagView: <#tagView description#>
    ///   - itemtag: <#itemtag description#>
    func  configTagStyle(_ tagView:TagView ,_ itemtag:ItemTag){
        switch self.tagstyle {
        case .emptyTag:
            tagView.isSelected = itemtag.isselected
        case .tagManager:
            tagView.isSelected = itemtag.isselected
        case .tagViewType(let typedes):
            if typedes == .mytag {
                tagView.isSelected = ((itemtag.viewType ?? .Private) == .Public ) ? true:false
            }
            else{
                tagView.isSelected = ((itemtag.viewType ?? .Private) == .Public ) ? true:false
            }
            tagView.tagViewForLight(islight: itemtag.isLight ?? false)
        case .otherTag:
            tagView.isSelected = ((itemtag.viewType ?? .Private) == .Public ) ? true:false
        default:
            break
        }
    }
    
}

extension PageTagOperatorTopView:TagListViewDelegate{
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if self.displayDataTags.count > 0 {
             let tag = self.displayDataTags.filter({ (tag) -> Bool in
                return  ((tag.name ?? "" ) == title)
            })
            if let selecttag = tag.first {
                self.dealTaptag(tagView, tag: selecttag)
            }
        }
    }
}

extension PageTagOperatorTopView {
    func goLightTag(_ itemtag:ItemTag)  {
        let  alterTipV = AlterLightTagView.loadNibView()
        alterTipV?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        alterTipV?.showOnWindow( direction: .center)
        alterTipV?.doneBlock = {
            [weak self] in
            guard let `self` = self  else {return }
            self.hasRelationTopicLightJump(itemtag: itemtag)
        }
    }
    func hasRelationTopicLightJump(itemtag:ItemTag)  {
        let lightVc = UserLightOrJoinTopicViewController.loadFromNib()
        lightVc.releaseType = .tag
        itemtag.relationTopicName({[weak self] (newTopicTag) in
            guard let `self` = self  else {return }
            lightVc.processType = .lightTag([newTopicTag])
            self.getCurrentViewController()?.navigationController?.pushViewController(lightVc, animated: false)
        }, disposeBag: self.rx.disposeBag)
        lightVc.blockRefresh =  {
            [weak self] in
            guard let `self` = self  else {return }
            UserTagsManager.shared.updateTags()
        }
       
    }
}

extension  ItemTag {
    
    /// 获取普通标签所关联的话题
    /// - Parameter relationTopicItemtag:
    func relationTopicName(_ relationTopicItemtag:@escaping((_ item:ItemTag) -> Void),disposeBag:DisposeBag)  {
        DiscoverProvider.init().requestNormalTagRelationTopic(self.tagId, disposebag: disposeBag) {[weak self] (model) in
            guard let `self` = self  else {return }
            if model?.name?.isEmpty ?? true{
                UIViewController.getCurrentViewController()?.toastTip("No topic relation to this tag".localiz())
                return
            }
            //否则
            self.name =  "#" + "\(model?.name ?? "")"//显示话题的
            self.relationTopic = model
            relationTopicItemtag(self)
        }
    }
}

extension  UIButton {
    
    /// 点亮样式的视图
    /// - Returns:
    static func lightStateButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.backgroundColor = UIColor.init(hex: "24D3D0")
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        return button
    }
    /// 比赛标签样式
    /// - Returns:
    static func matchStateButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.init(hex: "FD6AC5"), for: .normal)
        button.setTitle("match".localiz(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.backgroundColor = UIColor.init(hex: "F8E4F3")
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }
}

extension  TagListView {
    /// 灰度样式加载
    func loadGraySelectStyle()  {
        selectedTextColor = UIColor.init(hex: "A3A3A3")
        tagBackgroundColor = UIColor.white
        tagSelectedBackgroundColor = UIColor.init(hex: "EDEDED")
        removeIconLineColor =  UIColor.init(hex: "A3A3A3")
    }
    /// 加载亮一点的选中状态
    func loadLightSelectStyle()  {
        selectedTextColor = UIColor.init(hex: "24D3D0")
        tagBackgroundColor =  UIColor.init(hex: "EDEDED")
        tagSelectedBackgroundColor = UIColor.init(hex: "E9FAFA")
        removeIconLineColor =  UIColor.init(hex: "24D3D0")
    }
}

extension TagView {
    
    /// 设置标签点亮状态的样式
    /// - Parameters:
    ///   - tagView: <#tagView description#>
    ///   - islight: <#islight description#>
    func tagViewForLight(islight:Bool)  {
        if !islight {
            let  abtn = UIButton.lightStateButton()
            abtn.tag = -119
            self.addSubview(abtn)
            abtn.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(16)
                maker.top.equalToSuperview().offset(3)
                maker.right.equalToSuperview().offset(-3)
            }
        }else{
            if let iconLihtView = self.viewWithTag(-119) {
                iconLihtView.removeFromSuperview()
            }
        }
    }
    
    /// 设置标签比赛的样式
    
    func tagViewForMatch(ismatch:Bool)  {
        if ismatch {
            let  abtn = UIButton.matchStateButton()
            abtn.tag = -120
            self.addSubview(abtn)
            abtn.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(32)
                maker.centerY.equalToSuperview()
                maker.height.equalTo(20)
                maker.right.equalToSuperview().offset(-3)
            }
        }else{
            if let iconLihtView = self.viewWithTag(-120) {
                iconLihtView.removeFromSuperview()
            }
        }
    }
}
