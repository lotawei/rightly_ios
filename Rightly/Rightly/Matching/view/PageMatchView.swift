////
////  PageMatchView.swift
////  Rightly
////
////  Created by lejing_lotawei on 2021/3/5.
////
//
//import Foundation
//import UIKit
//import RxSwift
//import RxDataSources
//import RxCocoa
//import MJRefresh
//let  sizheightCell:CGFloat = 286
//
//class PageMatchView: UIView {
//    fileprivate var  pageLockAlterView:MatchLockAlterView? = MatchLockAlterView.loadNibView()
//    var  blurview:UIVisualEffectView?=nil
//    var  userblurView:Bool = false {
//        didSet{
//            self.makeblurView()
//        }
//    }
//    
//    var  pagedata = BehaviorRelay.init(value: [SectionModel<String,MatchTaskModel>]())
//    fileprivate var datasource:RxCollectionViewSectionedReloadDataSource<SectionModel<String,MatchTaskModel>>!
//    lazy var  collectionView:UICollectionView = {
//        let  layout = UICollectionViewFlowLayout.init()
//        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 15)
//        layout.itemSize = CGSize.init(width: (screenWidth-40)/2.0, height:sizheightCell)
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
//        let collectionview = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
//        collectionview.showsVerticalScrollIndicator = false
//        collectionview.backgroundColor = UIColor.init(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 0.9)
//        collectionview.register(cellType: MatchTaskCollectionViewCell.self)
//        return  collectionview
//    }()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                self.collectionView.mj_header?.endRefreshing()
//            }
//        })
//        bindData()
//    }
//    func setupUI(){
//        self.addSubview(self.collectionView)
//        self.collectionView.snp.makeConstraints { (maker) in
//            maker.left.right.top.bottom.equalToSuperview()
//        }
//    }
//   fileprivate func  bindData(){
//        datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,MatchTaskModel>>.init(configureCell: { (source, collectionview, indexpath, item) -> UICollectionViewCell in
//            let cell:MatchTaskCollectionViewCell = collectionview.dequeueReusableCell(for: indexpath)
//            cell.updateInfo(item)
//            return cell
//        })
//        
//        pagedata.asDriver().drive(self.collectionView.rx.items(dataSource: datasource)).disposed(by: self.rx.disposeBag)
//        
//    }
//    func  updateData(_ taskModels:[MatchTaskModel]){
//        pagedata.accept([SectionModel<String,MatchTaskModel>.init(model: "", items: taskModels)])
//        
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//}
//extension  PageMatchView {
//    
//    func  makeblurView(_ alpha:CGFloat? = 0.9) {
//        pageLockAlterView?.removeFromSuperview()
//        if blurview != nil {
//            blurview?.removeFromSuperview()
//        }
//        if userblurView {
//            blurview = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
//            guard let blur = blurview else {
//                return
//            }
//            self.addSubview(blur)
//            blur.alpha = alpha ?? 1
//            blur.snp.makeConstraints { (maker) in
//                maker.left.right.top.bottom.equalToSuperview()
//            }
//            
//            // 弹窗的
//            
//            pageLockAlterView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: self.frame.height)
//            pageLockAlterView?.showOnWindow(window:self,direction: .center,enableclose: false)
//           
//        }
//        
//    }
//}
//
