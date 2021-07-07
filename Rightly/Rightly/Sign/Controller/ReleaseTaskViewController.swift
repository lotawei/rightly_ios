//
//  ReleaseTaskViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/3.
//

import UIKit
import RxSwift
import FSPagerView
import MBProgressHUD
import RxCocoa
import Kingfisher
import KMPlaceholderTextView
import IQKeyboardManagerSwift
class ReleaseCustomLinearTransformer: FSPagerViewTransformer {
    override func proposedInteritemSpacing() -> CGFloat {
        return  50
    }
}
class ReleaseTaskViewController:BaseViewController{
    
    @IBOutlet weak var scrollerHeight: NSLayoutConstraint!
    var  maxcount = 120
    @IBOutlet weak var titleLblTip: UILabel!
    lazy var lbltaskDesc: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    lazy var  itemscrollerview:UIScrollView = {
        let  scrollerview =  UIScrollView.init(frame: .zero)
        scrollerview.backgroundColor = UIColor.white
        scrollerview.showsVerticalScrollIndicator = false
        scrollerview.showsHorizontalScrollIndicator = false
        scrollerview.clipsToBounds = true
        return scrollerview
    }()
    
    @IBOutlet weak var sanjiaoView: UIImageView!
    @IBOutlet weak var bodyscrolleView: UIScrollView!
    @IBOutlet weak var sanjiaobottom: NSLayoutConstraint!
    @IBOutlet weak var lblstrikeup: UILabel!
    @IBOutlet weak var lbldestip: UILabel!
    @IBOutlet weak var contentBodyV: UIView!
    var  firstCompleReload:Bool = false
    @IBOutlet weak var backbtn: UIImageView!
    var  task:TaskBrief? = nil
    
    var  inputvalidSuccess:PublishSubject<Bool> = PublishSubject()
    //    @IBOutlet weak var txtinput: KMPlaceholderTextView!
    var  avatarselectIndex:Int = 0
    @IBOutlet weak var topbackimg: UIImageView!
    @IBOutlet weak var ovallayer: UIImageView!
    var  randomValues:RandomEncodeValue?
    let  taskavatarimgs:[(Int,TaskType)] = [(0,.photo),(1,.video),(2,.voice)]
    @IBOutlet weak var btncommit: UIButton!
    @IBOutlet weak var inputformView: UIView!
    @IBOutlet weak var selectBannerView: UIView!
    lazy var bannerView:FSPagerView = {
        let bannerview = FSPagerView.init()
        bannerview.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerview.decelerationDistance = FSPagerView.automaticDistance
        bannerview.isInfinite = true
        return  bannerview
    }()
    fileprivate func setupView() {
        //        IQKeyboardManager.shared.enable = false
        //        keyboardStateSubscribe()
        self.fd_prefersNavigationBarHidden = true
        self.backbtn.isHidden =  ((self.navigationController?.viewControllers.count ?? 0) > 1) ? false:true
        IQKeyboardManager.shared.enable = false
        lblstrikeup.text = lblstrikeup.text?.localiz()
        lbltasklib.text = "Task library >>".localiz()
        lbldestip.text = lbldestip.text?.localiz()
        //        lbltasklib.text = lbltasklib.text?.localiz()
        //        txtinput.placeholder = "say anything".localiz()
        self.selectBannerView.addSubview(self.bannerView)
        self.bannerView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalToSuperview()
        }
        self.bannerView.transformer = ReleaseCustomLinearTransformer(type:.linear)
        self.bannerView.itemSize = CGSize.init(width: 100, height: 100)
        self.bannerView.isInfinite = true
        self.bannerView.delegate = self
        self.bannerView.dataSource = self
        self.contentBodyV.addSubview(self.itemscrollerview)
        self.itemscrollerview.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        //        txtinput.delegate = self
    }
    @IBOutlet weak var lbltasklib: UILabel!
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func jumpLibtaskRecomend(_ sender:Any){
        let guideVc = GuideCreateHotTaskViewController.loadFromNib()
        //
        //        guideVc.selectedTaskBlock = {
        //            [weak self] task in
        //            guard let `self` = self  else {return }
        //            if task != nil {
        //                self.task = task
        //                self.setInfo()
        //            }
        //        }
        self.navigationController?.pushViewController(guideVc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        dataInital()
        requestRandomTask()
    }
    func requestRandomTask()  {
        MBProgressHUD.showStatusInfo("Loading...".localiz())
        MatchTaskGreetingProvider.init().taskRandom(6, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            MBProgressHUD.dismiss()
            if let  va = res.modeDataKJTypeSelf(typeSelf: RandomEncodeValue.self) {
                self.randomValues = va
                if self.task == nil {
                    self.randomTaskValue()
                }else{
                    self.setInfo()
                }
            }
        },onError: { (err) in
            self.toastTip("Network failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    func dataInital()  {
        self.btncommit.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.actiondealWith()
        }).disposed(by: self.rx.disposeBag)
        
        self.bannerView.reloadData()
        self.setInfo()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    /// 设置随机任务
    fileprivate func  randomTaskValue(){
        guard let ranVs = self.randomValues else {
            return
        }
        var  taskbriefs:[TaskBrief] = []
        var  randomTask:TaskBrief
        switch self.avatarselectIndex {
        case 0:
            taskbriefs = ranVs.phototasks
        case 1:
            taskbriefs = ranVs.videotasks
        case 2:
            taskbriefs = ranVs.voicetasks
        default:
            break
        }
        randomTask = taskbriefs[Int.random(lower: 0, taskbriefs.count - 1)]
        self.task = randomTask
        self.setInfo()
    }
    
    //设置任务描述
    fileprivate func configDisplayDesc() {
        if let type = self.task?.type {
            updateBackImage(0)
            self.lbltaskDesc.attributedText = self.task?.getTaskNoTaskImageDesc(.center, font: 24)
            self.lbltaskDesc.sizeToFit()
            let heig = (self.lbltaskDesc.sizeThatFits(CGSize(width: (screenWidth*0.8), height: screenHeight)).height ) + 16 + 24
            self.lbltaskDesc.removeFromSuperview()
            self.itemscrollerview.addSubview(self.lbltaskDesc)
            self.lbltaskDesc.snp.makeConstraints { (maker) in
                maker.centerX.equalToSuperview()
                maker.width.equalToSuperview()
                maker.height.equalTo(heig)
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
            }
            lbltaskDesc.textAlignment = .center
            lbltaskDesc.numberOfLines = 0
            self.itemscrollerview.contentSize = CGSize.init(width:0, height: heig + 5)
            self.scrollerHeight.constant = heig < 200 ? heig:200
        }
    }
    
    
    func setInfo(){
        configDisplayDesc()
        if let sendtasktype = self.task?.type {
            
            switch sendtasktype {
            case .photo:
                self.updateBackImage(0)
                break
            case .voice:
                self.updateBackImage(2)
                break
            case.video:
                self.updateBackImage(1)
                break
            default:
                self.updateBackImage(0)
                break
                
            }
            //必须加一点延时才能显示 不知是个啥情况
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.bannerView.scrollToItem(at: self.avatarselectIndex, animated: true)
            }
        }
        else{
            inputvalidSuccess.onNext(false)
            self.updateBackImage(0)
        }
    }
    
    func actiondealWith(){
        //        if self.txtinput.text.isEmpty {
        //            MBProgressHUD.showError("Input Your Task Description".localiz())
        //            return
        //        }
        //        if self.txtinput.text.count > maxcount {
        //            self.toastTip("Input Text Should be limited  charaters " + " \(maxcount)")
        //            return
        //        }
        guard let taskid = self.task?.taskId else {
            return
        }
        let taskprovider = MatchTaskGreetingProvider.init()
        MBProgressHUD.showStatusInfo("release...".localiz())
        taskprovider.addTask(taskid, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                MBProgressHUD.showSuccess("Create greetingTask Success".localiz())
                if self.firstCompleReload {
                    var  info = UserManager.manager.currentUser
                    info?.additionalInfo?.isCreateTask = true
                    UserManager.manager.saveUserInfo(info)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        AppDelegate.reloadRootVC()
                    }
                }
                else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        NotificationCenter.default.post(name: kNotifyRefresh, object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            },onError: { (err) in
                MBProgressHUD.showError("Relase  task failed".localiz())
            }).disposed(by: self.rx.disposeBag)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.inputformView.setRoundCorners([.topLeft,.topRight], radius: 30)
        self.inputformView.layoutIfNeeded()
    }
}
extension  ReleaseTaskViewController:FSPagerViewDelegate,FSPagerViewDataSource{
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        let img = taskavatarimgs[index]
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 50
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = img.1.NewtaskImageIcon()
        return cell
    }
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return  taskavatarimgs.count
    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.avatarselectIndex = targetIndex
        randomTaskValue()
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        UIView.animate(withDuration: 0.6) {
            self.ovallayer.transform = CGAffineTransform.init(scaleX:0.5, y: 0.5)
            self.ovallayer.transform = CGAffineTransform.identity
        }
        self.avatarselectIndex = index
        randomTaskValue()
    }
    fileprivate func updateBackImage(_ index: Int) {
        if taskavatarimgs.count > 0 {
            let img = taskavatarimgs[index]
            self.topbackimg.backgroundColor = img.1.taskNewVersionColor()
            self.avatarselectIndex = index
            self.titleLblTip.text = img.1.typeTitle()
            self.btncommit.backgroundColor = img.1.taskNewVersionColor()
        }
    }
}



//extension  ReleaseTaskViewController {
//    fileprivate func keyboardStateSubscribe() {
//
//
//        _ = NotificationCenter.default.rx
//            .notification(UIResponder.keyboardWillHideNotification)
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
//            .subscribe(onNext:{
//                [weak self] _ in
//                guard let `self` = self else {return}
//                self.sanjiaobottom.constant  = 35
//                UIView.animate(withDuration: 0.2) {
//                    self.sanjiaoView.layoutIfNeeded()
//                    self.sanjiaoView.alpha = 1
//                }
//                self.keyBoardShowSomeView()
//            })
//
//        _ = NotificationCenter.default.rx
//            .notification(UIResponder.keyboardWillShowNotification)
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
//            .subscribe(onNext:{ [weak self]
//                 _  in
//                guard let `self` = self  else {return }
//                // 精确的算是需要顶到 箭头下面一点点
//                self.sanjiaobottom.constant  = -230
//                UIView.animate(withDuration: 0.2) {
//                    self.sanjiaoView.layoutIfNeeded()
//                    self.sanjiaoView.alpha = 0
//                }
//                self.keyBoardhideSomeView()
//            })
//
//    }
//    func   keyBoardhideSomeView(){
//        lblstrikeup.isHidden = true
//        lbltasklib.isHidden = true
//        lbldestip.isHidden = true
//        titleLblTip.isHidden = false
//    }
//
//    func  keyBoardShowSomeView(){
//        lblstrikeup.isHidden = false
//        lbltasklib.isHidden = false
//        lbldestip.isHidden = false
//        titleLblTip.isHidden = true
//
//    }
//
//}
//extension  ReleaseTaskViewController:UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//          if text == "\n"{
//              // 点击完成
//              textView.resignFirstResponder()
//              return false
//          }
//        if textView.text.count >= maxcount,text != "" {
//              return false
//          }
//          return true
//      }
//      func textViewDidChange(_ textView: UITextView) {
//         var currentCount = 0
//          if textView.markedTextRange == nil || textView.markedTextRange?.isEmpty == true {
//              currentCount = textView.text.count
//              if currentCount <= maxcount {
//
//              }else{
//                  textView.text = String(textView.text.prefix(maxcount))
//
//              }
//          }
//      }
//}
