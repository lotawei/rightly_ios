////
////  BaseViewController.swift
////  Rightly
////
////  Created by qichen jiang on 2021/2/25.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//import SnapKit
//import NSObject_Rx
//class NavigationView: UIView {
//    var titleLabel: UILabel!
//    var backBtn: UIButton!
//    var lineView: UIView!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupView() {
//        self.backgroundColor = .white
//
//        titleLabel = UILabel()
//        titleLabel.font = .boldSystemFont(ofSize: 18)
//        titleLabel.textColor = .black
//        titleLabel.textAlignment = .center
//        self.addSubview(titleLabel)
//
//        backBtn = UIButton.init(type: .custom)
//        backBtn.setImage(UIImage(named: "arrow_left_black"), for: .normal)
//        self.addSubview(backBtn)
//
//        lineView = UIView()
//        lineView.backgroundColor = UIColor.init(white: 0.8, alpha: 0.8)
//        self.addSubview(lineView)
//
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(88)
//            make.right.equalTo(-88)
//            make.bottom.equalTo(-2)
//            make.height.equalTo(40)
//        }
//
//        backBtn.snp.makeConstraints { (make) in
//            make.left.equalTo(5)
//            make.bottom.equalTo(-2)
//            make.size.equalTo(CGSize(width: 40, height: 40))
//        }
//
//        lineView.snp.makeConstraints { (make) in
//            make.left.bottom.right.equalTo(0)
//            make.height.equalTo(1)
//        }
//    }
//}
//
//class BaseViewController: UIViewController {
//    var contentView = UIView()
//    var navView = NavigationView()
//
//    init() {
//        super.init(nibName: nil, bundle: nil)
////        self.hidesBottomBarWhenPushed = true
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = .white
//        self.view.clipsToBounds = true
//
//        if (self.navigationController != nil) {
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
//            self.navigationController?.navigationBar.isHidden = true
//        }
//
//        self.view.addSubview(contentView)
//        self.view.addSubview(navView)
//
//        navView.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(0)
//            make.height.equalTo(navBarH)
//        }
//
//        contentView.snp.makeConstraints { (make) in
//            make.top.equalTo(navView.snp.bottom)
//            make.left.bottom.right.equalTo(0)
//        }
//
//        navView.backBtn.rx.tap.bind { [weak self] in
//            self?.navigationController?.popViewController(animated: true)
//        }.disposed(by: self.rx.disposeBag)
//
//        navView.rx.methodInvoked(#selector(setter: navView.isHidden))
//            .subscribe ( onNext: {[weak self] (isHidden) in
//                let changedValue:NSNumber = isHidden.first as! NSNumber
//                let navTop = changedValue.boolValue == true ? -navBarH : 0
//                self?.navView.snp.updateConstraints({ (make) in
//                    make.top.equalTo(navTop)
//                })
//            })
//            .disposed(by: self.rx.disposeBag)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        navView.backBtn.isHidden = (self.navigationController?.viewControllers.count)! <= 1
//    }
//}
import UIKit
import NSObject_Rx
open class BaseViewController:UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(forceRefresh(notification:)), name: kNotifyRefresh, object: nil)
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationToolManager.forceOrientationPortrait()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("----(\(self) deinit ---")
    }
    @objc open func forceRefresh(notification: NSNotification? = nil){
        debugPrint("----")
    }
}

import RxSwift
/// 首次加载逻辑拆分 用于diffinish lauch 要做很多事 后的处理
class  FirstLoadEmptyViewController:BaseViewController,NetProViderReloadProtocol {
    override func viewDidLoad() {
        super.viewDidLoad()
        NetProviderStatusManager.shared.netsatussubject.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (status) in
            guard let `self` = self  else {return }
            switch   status {
            case .notReachable ,.unknown:
                self.toastTip("NetWork Failed".localiz())
            default:
                self.reloadNetWorkData()
                break
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    func reloadNetWorkData() {
        AppDelegate.reloadRootVC()
    }
}

