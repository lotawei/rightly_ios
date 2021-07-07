//
//  DynamicDetailsViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/9.
//

import UIKit
import IQKeyboardManagerSwift
import MJRefresh

class DynamicDetailsViewController: UIViewController {
    var dataViewModel:DynamicDataViewModel? = nil
    let viewModel:DynamicDetailsViewModel
    var selectIndexPath:IndexPath? = nil
    var greetingId:String? = nil
    
    lazy var editView: CommentEditView = {
        let resultView = CommentEditView.loadNibView() ?? CommentEditView.init()
        resultView.sendBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
            guard let `self` = self else {return}
            MBProgressHUD.showStatusInfo("Sending...".localiz())
            self.viewModel.postComment(self.editView.textView.attributedText, indexPath: self.selectIndexPath) { (ok) in
                MBProgressHUD.dismiss()
                if !ok {
                    MBProgressHUD.showError("Send failure".localiz())
                } else {
                    self.editView.textView.resignFirstResponder()
                }
            }
        }.disposed(by: self.rx.disposeBag)
        return resultView
    }()
    
    lazy var tableView: UITableView = {
        let resultView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), style: .grouped)
        resultView.backgroundColor = .white
        resultView.register(DynamicImagesTableViewCell.self, forCellReuseIdentifier: "imagesId")
        resultView.register(DynamicVideoTableViewCell.self, forCellReuseIdentifier: "videoId")
        resultView.register(DynamicAudioTableViewCell.self, forCellReuseIdentifier: "audioId")
        resultView.register(CommentTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "spaceId")
        resultView.register(CommentTableFooterView.self, forHeaderFooterViewReuseIdentifier: "moreId")
        resultView.register(nibName: "CommentTableViewCell", forCellId: "commentId")
        resultView.register(nibName: "CommentReplyTableViewCell", forCellId: "replyId")
        resultView.delegate = self
        resultView.dataSource = self
        resultView.separatorStyle = .none
        resultView.estimatedRowHeight = 76
        resultView.rowHeight = UITableView.automaticDimension
        resultView.showsVerticalScrollIndicator = false
        
        resultView.mj_footer = MJRefreshBackStateFooter.init(refreshingBlock: { [weak self] in
            guard let `self` = self else {return }
            self.viewModel.requestCommentList { [weak self] (ok) in
                guard let `self` = self  else {return }
                self.tableView.mj_footer?.endRefreshing()
            }
        })
        
        return resultView
    }()
    
    init(_ viewModel:DynamicDataViewModel) {
        self.dataViewModel = viewModel
        self.viewModel = DynamicDetailsViewModel.init(viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ greetingId:String) {
        self.greetingId = greetingId
        self.viewModel = DynamicDetailsViewModel.init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.bindingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
        
        if self.dataViewModel == nil {
            self.tableView.isHidden = true
            self.editView.isHidden = true
            
            guard let greetId = self.greetingId else {
                return
            }
            
            MBProgressHUD.showStatusInfo("Refreshing".localiz())
            self.viewModel.requestDynamic(greetId) { (ok) in
                if !ok {
                    MBProgressHUD.showError("未知错误！")
                    return
                }
                
                MBProgressHUD.dismiss()
                self.dataViewModel = self.viewModel.dynamicViewModel
                self.setupFirstViewData()
            }
        } else {
            self.setupFirstViewData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
        self.dataViewModel?.isPlaying.accept(false)
    }
    
    
    
    func bindingData() {
        self.viewModel.isOver.subscribe(onNext:{ [weak self] (state) in
            guard let `self` = self else {return}
            if state {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self.tableView.mj_footer?.resetNoMoreData()
            }
        }).disposed(by: self.rx.disposeBag)
        
        self.viewModel.commentDatas.subscribe(onNext:{ [weak self] (datas) in
            guard let `self` = self else {return}
            self.tableView.reloadData()
            self.tableView.mj_footer?.endRefreshing()
        }).disposed(by: self.rx.disposeBag)
    }
    
    func setupView() {
        self.title = "Mentions".localiz()
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.editView)
        
        self.tableView.snp.makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(self.editView.snp.top)
        }
        
        self.editView.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(0)
        }
    }
    
    func setupFirstViewData() {
        self.tableView.isHidden = false
        self.editView.isHidden = false
        if self.viewModel.commentDatas.value.count <= 0 && !self.viewModel.isOver.value {
            self.viewModel.requestCommentList { (ok) in
            }
        }
    }
    
    fileprivate func deleteAction() {
        let deleteTipView = AlterViewTipView.loadNibView()
        deleteTipView?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
        deleteTipView?.displayerInfo(.deleteTip)
        deleteTipView?.doneBlock = { [weak self] in
            guard let `self` = self  else {return }
            MBProgressHUD.showStatusInfo("deleting...".localiz())
            self.dataViewModel?.requestDelete(block: { [weak self] state in
                MBProgressHUD.dismiss()
                guard let `self` = self  else {return }
                self.toastTip(state ? "Delete success".localiz() : "Delete failed".localiz())
                // TODO: - 删除直接返回 刷新上一个页面的列表
                
            })
        }
        deleteTipView?.showOnWindow( direction: .center)
    }
    
    fileprivate func topData() {
        self.dataViewModel?.requestTop(block: { [weak self] state in
            guard let `self` = self else {return}
            if state == -1 {
                self.toastTip("Cancel top".localiz())
                // TODO: - 取消置顶 上一个页面刷新排序
                
            } else if state == 1 {
                self.toastTip("Top success".localiz())
                // TODO: - 取消置顶 上一个页面刷新排序
            } else {
                self.toastTip("Top failed".localiz())
            }
        })
    }
    
    fileprivate func changeViewType()  {
        let viewTypeSelectView = PublishViewTypeSelectView.loadNibView()
        viewTypeSelectView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 200)
        viewTypeSelectView?.showOnWindow( direction: .up)
        viewTypeSelectView?.clickSenderType =  { [weak self] (viewtype) in
            guard let `self` = self  else {return }
            guard let toViewType = ViewType(rawValue: viewtype) else {
                return
            }
            
            MBProgressHUD.showStatusInfo("Editing.....".localiz())
            self.dataViewModel?.requestChangeViewType(toViewType, block: { [weak self] (state) in
                guard let `self` = self else {return}
                MBProgressHUD.dismiss()
                if state == -1 {
                    return
                }
                
                self.toastTip(state == 1 ? "Edit success".localiz() : "Edit failed".localiz())
            })
        }
    }
    
    fileprivate func showMyMoreAlertView() {
        let operationView = GreetingItemBottomView.loadNibView()
        operationView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 232)
        operationView?.selectItemBlock = { [weak self] itemselect in
            guard let `self` = self  else {return }
            switch itemselect {
            case .itemResult(let type, _):
                switch type {
                case .itemDelete:
                    self.deleteAction()
                case .itemPrivacy:
                    self.changeViewType()
                case .itembeTop:
                    self.topData()
                case .itemCancelTop:
                    self.topData()
                default:
                    break
                }
            }
        }
        operationView?.showOnWindow(direction: .up)
    }
    
    fileprivate func showOtherMoreAlertView() {
        let otherAlterView = OtherAlterTipView.loadNibView() ?? OtherAlterTipView.init()
        otherAlterView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 300)
        otherAlterView.showOnWindow( direction:.up)
        otherAlterView.hidefollow()
        otherAlterView.selectItemBlock = { [weak self] (item,issues) in
            guard let `self` = self  else {return }
            switch item {
            case .itemReport:
                self.dataViewModel?.requestReport(issues.first?.reportType() ?? 0, content: issues.first ?? "other", block: { [weak self] (success) in
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

// MARK: - NSNotification
extension DynamicDetailsViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.3) {
            self.editView.textViewBottom.constant = 8 + keyboardHeight
            self.view.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        guard let scrollIndexPath = self.selectIndexPath else {
            return
        }
        
        self.tableView.scrollToRow(at: scrollIndexPath, at: .bottom, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.editView.textViewBottom.constant = 8 + safeBottomH
            self.view.layoutIfNeeded()
            self.editView.textView.text = ""
            self.editView.textView.placeholder = "Post a comment".localiz()
        } completion: { (isOk) in
            self.selectIndexPath = nil
        }
    }
}

// MARK: - Delegate
extension DynamicDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataViewModel == nil ? 0 : self.viewModel.commentDatas.value.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.dataViewModel == nil ? 0 : 1
        } else if section - 1 >= self.viewModel.commentDatas.value.count {
            return 0
        }
        
        let tempViewModel = self.viewModel.commentDatas.value[section - 1]
        return tempViewModel.replyDatas.value.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.dataViewModel?.cellHeight ?? 0
        }
        
        let tempCommentViewModel = self.viewModel.commentDatas.value[indexPath.section - 1]
        if indexPath.row == 0 {
            return tempCommentViewModel.cellHeight
        }
        
        let tempReplyViewModel = tempCommentViewModel.replyDatas.value[indexPath.row - 1]
        return tempReplyViewModel.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var baseCell:DynamicBaseTableViewCell
            
            if self.dataViewModel?.customType == .photo {
                baseCell = tableView.dequeueReusableCell(withIdentifier: "imagesId", for: indexPath) as! DynamicImagesTableViewCell
            } else if self.dataViewModel?.customType == .video {
                baseCell = tableView.dequeueReusableCell(withIdentifier: "videoId", for: indexPath) as! DynamicVideoTableViewCell
            } else if self.dataViewModel?.customType == .voice {
                baseCell = tableView.dequeueReusableCell(withIdentifier: "audioId", for: indexPath) as! DynamicAudioTableViewCell
            } else {
                baseCell = tableView.dequeueReusableCell(withIdentifier: "imagesId", for: indexPath) as! DynamicImagesTableViewCell
            }
            
            baseCell.commentBtn.isEnabled = false
            guard let bindDataViewModel = self.dataViewModel else {
                return baseCell
            }
            
            baseCell.bindingViewModel(bindDataViewModel, .topic)
            
            baseCell.moreBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
                guard let `self` = self else {return}
                if (self.dataViewModel?.isMyself  ?? false) {
                    self.showMyMoreAlertView()
                } else {
                    self.showOtherMoreAlertView()
                }
            }.disposed(by: baseCell.disposeBag)
            
            // 音频cell 单独增加点击播放
            if let audioCell = baseCell as? DynamicAudioTableViewCell {
                audioCell.playBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
                    guard let `self` = self else {return}
                    // TODO: - 播放音频
                    self.dataViewModel?.isPlaying.accept(!(self.dataViewModel?.isPlaying.value ?? false))
                    if ((self.dataViewModel?.isPlaying.value) != nil) {
                        guard let playPath = self.dataViewModel?.resourceViewModel?.contentURL?.absoluteString else {
                            return
                        }
                        RTVoiceRecordManager.shareinstance.startPlayerAudio(audiopath: playPath) { [weak self] (finish) in
                            guard let `self` = self else {return}
                            self.dataViewModel?.isPlaying.accept(false)
                        }
                    } else {
                        RTVoiceRecordManager.shareinstance.stopPlayerAudio()
                    }
                }.disposed(by: baseCell.disposeBag)
            }
            
            return baseCell
        }
        
        //1级回复
        let tempCommentViewModel = self.viewModel.commentDatas.value[indexPath.section - 1]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentId", for: indexPath) as! CommentTableViewCell
            cell.bindingViewModel(tempCommentViewModel)
            cell.replyBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
                guard let `self` = self else {return}
                self.selectIndexPath = indexPath
                self.editView.textView.text = ""
                self.editView.textView.placeholder = "Reply:".localiz() + self.viewModel.getNickname(indexPath)
                self.editView.textView.becomeFirstResponder()
            }.disposed(by: cell.disposeBag)
            return cell
        }
        
        //2,3级回复
        let tempReplyViewModel = tempCommentViewModel.replyDatas.value[indexPath.row - 1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyId", for: indexPath) as! CommentReplyTableViewCell
        cell.bindingViewModel(tempReplyViewModel)
        cell.replyBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (event) in
            guard let `self` = self else {return}
            self.selectIndexPath = indexPath
            self.editView.textView.text = ""
            self.editView.textView.placeholder = self.viewModel.getNickname(indexPath)
            self.editView.textView.becomeFirstResponder()
        }.disposed(by: cell.disposeBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.5
        }
        
        let tempViewModel = self.viewModel.commentDatas.value[section - 1]
        if tempViewModel.replyNum.value <= 0 {
            return 0.5
        }
        
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "spaceId")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "moreId") as? CommentTableFooterView
        footerView?.loadingActivity.stopAnimating()
        
        if section == 0 {
            footerView?.moreBtn.isHidden = true
            footerView?.loadingActivity.isHidden = true
            footerView?.bindingViewModel(nil)
        } else {
            let tempViewModel = self.viewModel.commentDatas.value[section - 1]
            footerView?.bindingViewModel(tempViewModel)
        }
        return footerView
    }
}



