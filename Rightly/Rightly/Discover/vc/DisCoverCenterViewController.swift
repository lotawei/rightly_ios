//
//  DisCoverCenterViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/5/22.
//

import Foundation
import Foundation
import JXSegmentedView
class DisCoverCenterViewController: BaseViewController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    let titles = ["话题".localiz(), "推荐".localiz()]
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    var  subVcs:[JXSegmentedListContainerViewListDelegate] = []
    lazy var  topicVc:DisCoverTopicViewController = {
        let  topicVc = DisCoverTopicViewController.init()
        return topicVc
    }()
    lazy var  recommendVc:DynamicListViewController = {
        let  recommendVc = DynamicListViewController.init(.topic) //不传就是推荐
        return recommendVc
    }()
    fileprivate func setupview() {
        self.fd_prefersNavigationBarHidden = true
        let totalItemWidth: CGFloat = 150
        segmentedDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = UIColor.gray
        segmentedDataSource.titleSelectedColor = UIColor.black
        segmentedDataSource.itemSpacing = 0
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.init(hex: "24D3D0")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        self.view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview().offset(UIScreen.safeInsetTop())
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
        
        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom).offset(4)
            make.bottom.equalTo(-(safeBottomH +  68))
        }
        
        contentView.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
//            maker.left.right.equalToSuperview()
//            maker.top.equalTo(segmentedView.snp.bottom).offset(4)
//            maker.bottom.equalToSuperview()
        }
        subVcs.append(self.topicVc)
        subVcs.append(self.recommendVc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearNavigationBarLine()
        guard let userid = UserManager.manager.currentUser?.additionalInfo?.userId else {
            return
        }
        UserDefaults.standard.setValue(nil, forKey: systemKey + "\(userid)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setupNavigationBarLine()
    }
    
}

extension DisCoverCenterViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        var  vc = self.subVcs[index]
        if var selectVc = vc as? DisCoverTopicViewController {
            selectVc.viewModel.input.disCoverType.accept(.topic)
        }
        return vc
    }
}

