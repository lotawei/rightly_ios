//
//  TagSelectViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
import Foundation
import JXSegmentedView
class TagSelectViewController: BaseViewController {
    var  otherId:Int? = nil
    var  loadStyle:TagStyle = .emptyTag
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    var titles:[ItemTagCategory] = []
    var  pageDataViews:[PageTagCategoryOperatorView] = []
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    // UI
    var  operationTagView:PageTagOperatorTopView? = PageTagOperatorTopView.loadNibView()
    // viewtype
    var  tagViewTypeOperatorView:PageTagOperatorTopView? = PageTagOperatorTopView.loadNibView()
    
    lazy var closeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        button.setImage(UIImage.init(named:"关闭"), for: .normal)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    /// 保存按钮
    lazy var saveButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.setTitle("Finish".localiz(), for: .normal)
        button.setTitleColor(UIColor.init(hex: "27D3CF"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.frame = CGRect.init(x: 0, y: 0, width: 68, height: 30)
        return button
    }()
    /// 标签管理
    lazy var managerTagButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(managerTapAction(_:)), for: .touchUpInside)
        button.setTitle("Tag Manager".localiz(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.init(hex: "27D3CF")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate func setupview() {
        configViewByTagStyle()
        requestCategorySystemView()
    }
    
    func requestCategorySystemView()  {
        switch self.loadStyle {
        case .tagViewType(let des):
            guard let tagviewtypeoperatorView = self.tagViewTypeOperatorView ,let topview = self.operationTagView else {
                return
            }
            self.view.addSubview(self.managerTagButton)
            self.managerTagButton.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview().offset(-safeBottomH - 20)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(311)
                maker.height.equalTo(52)
            }
            self.view.addSubview(tagviewtypeoperatorView)
            tagviewtypeoperatorView.snp.makeConstraints { (maker) in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(topview.snp.bottom)
                maker.bottom.equalTo(self.managerTagButton.snp.top)
            }
            tagviewtypeoperatorView.loadFirst(style: .tagViewType(.mytag))
         
        case .otherTag(let id):
            return 
        default:
            
            UserTagsManager.shared.requestUserCategoryList {[weak self] (itemcategory) in
                guard let `self` = self  else {return }
                self.titles  = itemcategory
                self.configPageCategoryView()
            }
        }
    }
    func configPageCategoryView() {
        guard let topView = self.operationTagView else {
            return
        }
        for value in self.titles {
            if let pageView = PageTagCategoryOperatorView.loadNibView() {
                let caid = value.categoryId
                pageView.loadCategerytags(caid)
                pageDataViews.append(pageView)
            }
        }
        
        segmentedDataSource.titles = titles.map({ (cate) -> String in
            return  cate.name ?? ""
        })
        segmentedDataSource.titleNormalFont = UIFont.systemFont(ofSize: 16)
        segmentedDataSource.titleNormalColor = UIColor.black
        segmentedDataSource.titleSelectedColor = UIColor.init(hex: "24D3D0")
        segmentedDataSource.itemSpacing = 12
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.init(hex: "24D3D0")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        self.view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.top.equalTo(topView.snp.bottom)
            maker.height.equalTo(40)
        }
        let aview = UIView.createLineView()
        self.view.addSubview(aview)
        aview.snp.makeConstraints { (maker) in
            maker.height.equalTo(1)
            maker.width.equalToSuperview()
            maker.top.equalTo(segmentedView.snp.bottom).offset(3)
            maker.centerX.equalToSuperview()
        }
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(segmentedView.snp.bottom).offset(4)
            maker.bottom.equalToSuperview()
        }
        
        
    }
    func configViewByTagStyle()  {
        if let operatTagView = self.operationTagView  {
            self.view.addSubview(operatTagView)
            operatTagView.loadFirst(style: self.loadStyle)
        }
        var  fullscreen = false
        switch self.loadStyle {
        case .emptyTag:
            self.clearNavigationBarLine()
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.saveButton)
            UserTagsManager.shared.enableSave.subscribe(onNext: { [weak self] (isenable) in
                guard let `self` = self  else {return }
                self.saveButtonState(isenable)
            }).disposed(by: self.rx.disposeBag)
        case .otherTag:
            fullscreen = true
            self.clearNavigationBarLine()
            self.setshowLeftBack(target: false)
            self.title = ""
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.closeButton)
        case .tagManager:
            self.title = "manager_tags".localiz()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.saveButton)
            UserTagsManager.shared.enableSave.subscribe(onNext: { [weak self] (isenable) in
                guard let `self` = self  else {return }
                self.saveButtonState(isenable)
            }).disposed(by: self.rx.disposeBag)
        default:
            self.title = "My Tag".localiz()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.saveButton)
            UserTagsManager.shared.enablePubSave.subscribe(onNext: { [weak self] (isenable) in
                guard let `self` = self  else {return }
                self.saveButtonState(isenable)
            }).disposed(by: self.rx.disposeBag)
            
        }
        if !fullscreen {
            operationTagView?.snp.makeConstraints { (maker) in
                maker.top.equalToSuperview()
                maker.right.left.equalToSuperview()
                maker.height.equalTo(264)
            }
        }else{
            operationTagView?.snp.makeConstraints { (maker) in
                maker.top.bottom.equalToSuperview()
                maker.right.left.equalToSuperview()
                
            }
        }
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch self.loadStyle {
        case .otherTag(let userid):
            UserTagsManager.shared.updateTags(userid)
            break
        default:
            UserTagsManager.shared.clearSet()
            UserTagsManager.shared.updateTags()
        }
          
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage.init(named: "shadowline")
    }
    @objc func saveAction(_ sender:Any){
        switch self.loadStyle {
        case .emptyTag:
            //添加标签
            UserTagsManager.shared.saveTagConfig()
            break
        case .otherTag:
            //他人
            break
        case .tagManager:
            //标签管理
            UserTagsManager.shared.saveTagConfig()
            break
        case .tagViewType:
            //公开
            UserTagsManager.shared.savePubAndPrivateConfig()
            break
        }
        
    }
    deinit {
        debugPrint("-------------deinit")
    }
    @objc func managerTapAction(_ sender:Any){
        let tagVc = TagSelectViewController.init()
        tagVc.loadStyle = .tagManager
        self.navigationController?.pushViewController(tagVc, animated: false)
    }
    @objc func  closeAction(_ sender:Any){
        self.setshowLeftBack(target: true)
        self.navigationController?.popViewController(animated: false)
    }
    func saveButtonState(_ isenable:Bool)  {
        if isenable {
            self.saveButton.setTitleColor(UIColor.init(hex: "27D3CF"), for: .normal)
            self.saveButton.backgroundColor = UIColor.white
        } else{
            self.saveButton.setTitleColor(UIColor.white, for: .normal)
            self.saveButton.backgroundColor = UIColor.init(hex: "EDEDED")
        }
        self.saveButton.isEnabled = isenable
    }
}
extension  TagSelectViewController:JXSegmentedViewDelegate{
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        let pageView =  pageDataViews[index]
        pageView.updateCategoryTags()
    }
}
extension TagSelectViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let pageView =  pageDataViews[index]
        pageView.updateCategoryTags()
        return pageView
    }
}
