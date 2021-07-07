//
//  DynamicListViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import UIKit
import JXSegmentedView
import RxCocoa
import RxSwift
import MJRefresh

public enum DynamicListType : Int {
    case topic = 0  //话题的动态列表
    case likes = 1  //喜欢的动态列表
    case myDynamics = 2 //我的动态列表
    case otherDynamics = 3  //他人的动态列表
}

enum PullDownState: Int {
    case normal = 0
    case canRequest = 1
}

class DynamicListViewController: BaseViewController {
    var headerRefreshBlock:(()-> Void)?=nil
    var viewDidScrollBlock:((_ offset:CGPoint)-> Void)?=nil
    var isLockUser:BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
    fileprivate var viewModel:DynamicListViewModel?
    fileprivate var listType:DynamicListType = .topic
    fileprivate var parameter:String? = nil
    fileprivate var isemptyData:Bool = false
    fileprivate var pullState:PullDownState = .normal
    var userId:String?=nil
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero)
        tableView.register(DynamicImagesTableViewCell.self, forCellReuseIdentifier: "imagesId")
        tableView.register(DynamicVideoTableViewCell.self, forCellReuseIdentifier: "videoId")
        tableView.register(DynamicAudioTableViewCell.self, forCellReuseIdentifier: "audioId")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.mj_footer = GlobalRefreshFooter.init(refreshingBlock: { [weak self] in
            guard let `self` = self else {return}
            if self.viewModel?.output.requestStatus.value == .requesting {
                self.tableView.mj_footer?.endRefreshing()
                return
            }
            
            self.viewModel?.input.footerCommand.onNext(self.parameter)
        })
        
        return tableView
    }()
    
    lazy var blankFooterView: UIView = {
        let resultView = UIView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: safeBottomH))
        resultView.backgroundColor = .white
        return resultView
    }()
    
    lazy var unlockFooterView: DynamicUnlockFooterView = {
        let resultView = DynamicUnlockFooterView.loadNibView() ?? DynamicUnlockFooterView.init()
        resultView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 49)
        return resultView
    }()
    
    init(_ listType:DynamicListType, _ parameter:String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.listType = listType
        self.parameter = parameter
        self.viewModel = DynamicListViewModel.init(listType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.bindingData()
        forceRefresh(notification: nil)
    }
    override func forceRefresh(notification: NSNotification? = nil) {
        self.viewModel?.input.headerCommand.onNext(self.parameter)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel?.stopAllAudio()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindingData() {
        self.isLockUser.subscribe { [weak self] (state) in
            guard let `self` = self else {return}
            self.afterDelay(0.0001) {
                self.setUpFloatUnlockTipView()
            }
        }.disposed(by: self.rx.disposeBag)
        
        self.viewModel?.output.requestStatus.subscribe(onNext:{ [weak self] (state) in
            guard let `self` = self else {return}
            if state != .requesting {
                self.tableView.mj_footer?.endRefreshing()
                
                if state == .noMoreData {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
            }
        }).disposed(by: self.rx.disposeBag)
        
        self.viewModel?.output.dynamicDatas.subscribe(onNext:{ [weak self] (datas) in
            guard let `self` = self else {return}
            self.afterDelay(0.0001) {
                self.setUpFloatUnlockTipView()
                self.tableView.reloadData()
            }
        }).disposed(by: self.rx.disposeBag)
        
        self.tableView.rx.didScroll.subscribe(onNext: { [weak self]  in
            guard let `self` = self else {return }
            if self.tableView.mj_offsetY < -88 {
                if (self.pullState == .normal && self.viewModel?.output.requestStatus.value != .requesting) {
                    self.headerRefreshBlock?()
                    self.viewModel?.input.headerCommand.onNext(self.parameter)
                }
                self.pullState = .canRequest
            } else if self.tableView.mj_offsetY >= -1.0 {
                self.pullState = .normal
            }
            
            self.viewDidScrollBlock?(self.tableView.contentOffset)
        }).disposed(by: self.rx.disposeBag)
        
        self.viewModel?.output.emptyData.subscribe(onNext: { [weak self] (empty) in
            guard let `self` = self  else {return }
            self.isemptyData = empty
            if  !self.isemptyData {
                self.tableView.tableFooterView = nil
            }else{
                self.afterDelay(0.001) {
                    let  footerV = self.configFooterEmptyView()
                    self.tableView.tableFooterView = footerV
                }
            }
            
        }).disposed(by: self.rx.disposeBag)
        
    }
    
    func setUpFloatUnlockTipView() {
        //        let hasMore = (self.viewModel?.output.dynamicDatas.value.count ?? 0) >= 3
        //        if self.listType == .otherDynamics && self.isLockUser.value  {
        //            self.tableView.tableFooterView = self.unlockFooterView
        //            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
        //        } else {
        //            self.tableView.tableFooterView = safeBottomH > 0 ? self.blankFooterView : nil
        //            if self.viewModel?.output.requestStatus.value == .noMoreData {
        //                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
        //            } else {
        //                self.tableView.mj_footer?.resetNoMoreData()
        //            }
        //        }
       
        let  dynamicCount = self.viewModel?.output.dynamicDatas.value.count ?? 0
        var  shuouldDisplay = false
        if dynamicCount > 0 && dynamicCount <= 3 {
            shuouldDisplay = true
        }else{
            shuouldDisplay  = false
        }
        if self.listType == .otherDynamics && self.isLockUser.value  && shuouldDisplay {
            self.unlockFooterView.removeFromSuperview()
            self.unlockFooterView.userId  = self.userId
            self.view.addSubview(self.unlockFooterView)
            self.unlockFooterView.snp.makeConstraints { (maker) in
                maker.width.equalTo(scaleWidth(228))
                maker.height.equalTo(scaleHeight(48))
                maker.centerX.equalToSuperview()
                maker.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-30)
            }
        }else{
            self.tableView.tableFooterView = safeBottomH > 0 ? self.blankFooterView : nil
            if self.viewModel?.output.requestStatus.value == .noMoreData {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer?.resetNoMoreData()
            }
        }
    }
}

// event
extension DynamicListViewController {
    
    /// 指定加载到父控制器
    /// - Parameters:
    ///   - parentsCtrl: 父控制器
    ///   - parentsView: 待加载的View, 必须属于父控制器下的View
    public func addParents(_ parentsCtrl:UIViewController, _ parentsView:UIView) {
        parentsCtrl.addChild(self)
        self.didMove(toParent: parentsCtrl)
        parentsView.addSubview(self.view)
    }
    
    fileprivate func deleteAction(_ indexPath:IndexPath)  {
        if indexPath.row >= self.viewModel?.output.dynamicDatas.value.count ?? 0 {
            self.toastTip("Delete failed".localiz())
            return
        }
        
        let deleteTipView = AlterViewTipView.loadNibView()
        deleteTipView?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        deleteTipView?.displayerInfo(.deleteTip)
        deleteTipView?.doneBlock = { [weak self] in
            guard let `self` = self  else {return }
            MBProgressHUD.showStatusInfo("deleting...".localiz())
            let tempViewModel = self.viewModel?.output.dynamicDatas.value[indexPath.row]
            tempViewModel?.requestDelete(block: { [weak self] state in
                MBProgressHUD.dismiss()
                guard let `self` = self  else {return }
                self.viewModel?.deleteData(indexPath.row)
                self.toastTip(state ? "Delete success".localiz() : "Delete failed".localiz())
            })
        }
        deleteTipView?.showOnWindow( direction: .center)
    }
    
    fileprivate func topData(_ indexPath:IndexPath) {
        if indexPath.row >= self.viewModel?.output.dynamicDatas.value.count ?? 0 {
            self.toastTip("Top failed".localiz())
            return
        }
        
        let tempViewModel = self.viewModel?.output.dynamicDatas.value[indexPath.row]
        tempViewModel?.requestTop(block: { [weak self] state in
            guard let `self` = self else {return}
            if state == -1 {
                self.toastTip("Cancel top".localiz())
                self.viewModel?.input.headerCommand.onNext(self.parameter)
            } else if state == 1 {
                self.toastTip("Top success".localiz())
                self.viewModel?.topData(indexPath.row)
                self.tableView.setContentOffset(.zero, animated: true)
            } else {
                self.toastTip("Top failed".localiz())
            }
        })
    }
    
    fileprivate func changeViewType(_ indexPath:IndexPath)  {
        if indexPath.row >= self.viewModel?.output.dynamicDatas.value.count ?? 0 {
            self.toastTip("Edit failed".localiz())
            return
        }
        
        let viewTypeSelectView = PublishViewTypeSelectView.loadNibView()
        viewTypeSelectView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 200)
        viewTypeSelectView?.showOnWindow( direction: .up)
        viewTypeSelectView?.clickSenderType =  { [weak self] (viewtype) in
            guard let `self` = self  else {return }
            guard let toViewType = ViewType(rawValue: viewtype) else {
                return
            }
            
            MBProgressHUD.showStatusInfo("Editing.....".localiz())
            let tempViewModel = self.viewModel?.output.dynamicDatas.value[indexPath.row]
            tempViewModel?.requestChangeViewType(toViewType, block: { [weak self] (state) in
                guard let `self` = self else {return}
                MBProgressHUD.dismiss()
                if state == -1 {
                    return
                }
                
                self.toastTip(state == 1 ? "Edit success".localiz() : "Edit failed".localiz())
            })
        }
    }
    
    fileprivate func showMyMoreAlertView(_ indexPath:IndexPath) {
        let operationView = GreetingItemBottomView.loadNibView()
        operationView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 232)
        operationView?.selectItem = indexPath
        operationView?.selectItemBlock = { [weak self] itemselect in
            guard let `self` = self  else {return }
            switch itemselect {
            case .itemResult(let type, let res):
                guard let result = res as? IndexPath else {
                    return
                }
                switch type {
                case .itemDelete:
                    self.deleteAction(result)
                case .itemPrivacy:
                    self.changeViewType(result)
                case .itembeTop:
                    self.topData(result)
                case .itemCancelTop:
                    self.topData(result)
                default:
                    break
                }
            }
        }
        operationView?.showOnWindow(direction: .up)
    }
    
    fileprivate func showOtherMoreAlertView(_ indexPath:IndexPath) {
        if indexPath.row >= self.viewModel?.output.dynamicDatas.value.count ?? 0 {
            return
        }
        
        let otherAlterView = OtherAlterTipView.loadNibView() ?? OtherAlterTipView.init()
        otherAlterView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 300)
        otherAlterView.showOnWindow( direction:.up)
        otherAlterView.hidefollow()
        otherAlterView.selectItemBlock = { [weak self] (item,issues) in
            guard let `self` = self  else {return }
            switch item {
            case .itemReport:
                let tempViewModel = self.viewModel?.output.dynamicDatas.value[indexPath.row]
                tempViewModel?.requestReport(issues.first?.reportType() ?? 0, content: issues.first ?? "other", block: { [weak self] (success) in
                    guard let `self` = self else {return}
                    self.toastTip(success ? "Report success".localiz() : "Report failed".localiz())
                })
                break
            case .itemFollow:
                break
            default:
                break
            }
        }
    }
}

extension DynamicListViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.listType == .otherDynamics && self.isLockUser.value {
            return min(self.viewModel?.output.dynamicDatas.value.count ?? 0, 3)
        }
        
        return self.viewModel?.output.dynamicDatas.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var baseCell:DynamicBaseTableViewCell
        
        guard let tempViewModel = self.viewModel?.output.dynamicDatas.value[indexPath.row] else {
            return UITableViewCell.init()
        }
        
        if tempViewModel.customType == .photo {
            baseCell = tableView.dequeueReusableCell(withIdentifier: "imagesId", for: indexPath) as! DynamicImagesTableViewCell
        } else if tempViewModel.customType == .video {
            baseCell = tableView.dequeueReusableCell(withIdentifier: "videoId", for: indexPath) as! DynamicVideoTableViewCell
        } else if tempViewModel.customType == .voice {
            baseCell = tableView.dequeueReusableCell(withIdentifier: "audioId", for: indexPath) as! DynamicAudioTableViewCell
        } else {
            baseCell = tableView.dequeueReusableCell(withIdentifier: "imagesId", for: indexPath) as! DynamicImagesTableViewCell
        }
        
        baseCell.bindingViewModel(tempViewModel, self.listType, (indexPath.row == self.viewModel?.output.dynamicDatas.value.count ?? 0 - 1))
        
        baseCell.moreBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
            guard let `self` = self else {return}
            let previewViewCtrl = PreviewNavigationController.init(.image)
            previewViewCtrl.modalPresentationStyle = .custom
            self.parent?.present(previewViewCtrl, animated: true)
            
//            if self.listType == .myDynamics {
//                self.showMyMoreAlertView(indexPath)
//            } else {
//                self.showOtherMoreAlertView(indexPath)
//            }
        }.disposed(by: baseCell.disposeBag)
        
        // 音频cell 单独增加点击播放
        if let audioCell = baseCell as? DynamicAudioTableViewCell {
            audioCell.playBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
                guard let `self` = self else {return}
                self.viewModel?.playAudio(indexPath.row)
            }.disposed(by: baseCell.disposeBag)
        }
        
        return baseCell
    }
}


extension DynamicListViewController:JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}
extension  DynamicListViewController {
    func configFooterEmptyView() -> UIView? {
        if self.listType != .myDynamics {
            let  emptyv = EmptyView.loadNibView()
            emptyv?.placeimage.image = UIImage(named: "emptyview")
            var  height:CGFloat = screenHeight
            if self.listType == .likes {
                height = screenHeight
            }else{
                height = scaleHeight(280)
            }
            emptyv?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: height)
            return emptyv
        }
        else {
            let  emptyv = EmptyOwerCell.loadNibView()
            emptyv?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: scaleHeight(280))
            return emptyv
        }
    }
}
