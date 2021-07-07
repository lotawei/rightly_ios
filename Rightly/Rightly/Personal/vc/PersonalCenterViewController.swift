//
//  PersonalCenterViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/6.
//

import Foundation
import JXSegmentedView
class PersonalCenterViewController: BaseViewController {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView()
    let titles = ["Mentions".localiz(), "Notice".localiz()]
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    var  subVcs:[PersonalNotifyViewController] = []
    fileprivate func setupview() {
        self.title = "notif_title".localiz()
        let totalItemWidth: CGFloat = 150
        segmentedDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalColor = UIColor.black
        segmentedDataSource.titleSelectedColor = UIColor.init(hex: "24D3D0")
        segmentedDataSource.itemSpacing = 0
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.init(hex: "24D3D0")
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicator]
        self.view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview()
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
        for (index,value )in titles.enumerated() {
            let vc = PersonalNotifyViewController()
            if index == 0  {
                vc.displayNotifyType = [.focus,.like]
            }else{
                vc.displayNotifyType = [.system]
            }
            subVcs.append(vc)
        }
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
extension  PersonalCenterViewController:JXSegmentedViewDelegate{
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        let  vc = self.subVcs[index]
        vc.viewModel.input.requestCommand.onNext(nil)
    }
}
extension PersonalCenterViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return subVcs[index]
    }
}
