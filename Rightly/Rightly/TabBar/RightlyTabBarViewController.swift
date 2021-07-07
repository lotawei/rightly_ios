//
//  RightlyTabBarViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/2.
//

import UIKit
import RxSwift

class RightlyTabBarViewController: UITabBarController {
    fileprivate var lrPadding:CGFloat = 20
    var  customBarView:UIView = UIView.init()
    override var selectedIndex: Int {
        didSet{
            if selectedIndex == 0 {
                self.tabBar.backgroundColor = .clear
            }else{
                self.tabBar.backgroundColor = .white
            }
            updateSelectState()
        }
    }
    
    var itemsbtn:[UIButton] = [UIButton]()
    let onece = Once()
    
    lazy var lineView:UIView = {
        let lineView = UIView.init()
        lineView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 1)
        lineView.backgroundColor = UIColor.init(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0,alpha: 1)
        
        return lineView
    }()
    
    lazy var spacerBtn:UIButton = {
        let spacerbtn:UIButton = UIButton.init(type: .custom)
        spacerbtn.tag = 0
        spacerbtn.setImage(UIImage.init(named: "tabbar_match"), for: .normal)
        spacerbtn.setImage(UIImage.init(named: "tabbar_match_selected"), for: .selected)
        return spacerbtn
    }()
    lazy var discoverBtn:UIButton = {
        let discoverBtn:UIButton = UIButton.init(type: .custom)
        discoverBtn.tag = 1
        discoverBtn.setImage(UIImage.init(named: "tabbar_discover"), for: .normal)
        discoverBtn.setImage(UIImage.init(named: "tabbar_discover_selected"), for: .selected)
        return discoverBtn
    }()
//    //目前只有话题的类型入口
//    lazy var publishAddBtn:UIButton = {
//        let publishAddBtn:UIButton = UIButton.init(type: .custom)
//        publishAddBtn.tag = 2
//        publishAddBtn.setBackgroundImage(UIImage.init(named: "addblack") , for: .normal)
//        publishAddBtn.setBackgroundImage(UIImage.init(named: "addblack"), for: .selected)
//        return publishAddBtn
//    }()
    lazy var messageBtn:UIButton = {
        let messagebtn:UIButton = UIButton.init(type: .custom)
        messagebtn.tag = 3
        messagebtn.setImage(UIImage.init(named: "message") , for: .normal)
        messagebtn.setImage(UIImage.init(named: "message_selected"), for: .selected)
        return messagebtn
    }()
    lazy var  personalBtn:UIButton = {
        let personalBtn:UIButton = UIButton.init(type: .custom)
        personalBtn.tag = 4
        personalBtn.setImage(UIImage.init(named: "my_selected") , for: .selected)
        personalBtn.setImage(UIImage.init(named: "my"), for: .normal)
        return personalBtn
    }()
    
    let ctrlArray:Array<RTNavgationViewController> = { () -> Array<RTNavgationViewController> in
        let matchingCtrl = NewMatchingViewController.init()
        let discoverCtrl = DisCoverCenterViewController.init()
        let messageCtrl = SessionListViewController.init()
        let personalCtrl = NewPersonalOwerViewController.init()
        
        let matchingNav = RTNavgationViewController.init(rootViewController: matchingCtrl)
        let dicoverNav = RTNavgationViewController.init(rootViewController: discoverCtrl)
        let messageNav = RTNavgationViewController.init(rootViewController: messageCtrl)
        let personalNav = RTNavgationViewController.init(rootViewController: personalCtrl)
        
        
        let  fakeVc = RTNavgationViewController.init(rootViewController: UIViewController.init())
        return [matchingNav,dicoverNav,fakeVc,messageNav, personalNav]
    }()
    lazy var  currView:UIStackView = {
        let currView:UIStackView = UIStackView.init(frame: .zero)
        currView.axis = .horizontal
        currView.alignment = .center
        currView.spacing = 20
        currView.distribution = .equalSpacing
        return currView
    }()
    var customTabBarView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: (68 + safeBottomH)))
    
    fileprivate func tabbarInital() {
        self.tabBar.isTranslucent = true
        self.setViewControllers(self.ctrlArray, animated: false)
        setupCustomTabBar()
        let tabBarBgImage = UIImage.createSolidImage(color: .clear, size: CGSize.init(width: screenWidth, height: (68 + safeBottomH)))
        let tabBarLineImage = UIImage.createSolidImage(color: .clear, size: CGSize.init(width: screenWidth, height: 1))
        if #available(iOS 13.0, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.backgroundImage = tabBarBgImage
            appearance.shadowImage = tabBarLineImage
            appearance.configureWithTransparentBackground()
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.backgroundImage = tabBarBgImage
            self.tabBar.shadowImage = tabBarLineImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbarInital()
        MatchLimitCountManager.shared.updateFilterMatch()
        let createTaskKey = "created_task_" + String(UserManager.manager.currentUser?.additionalInfo?.userId ?? 0)
        UserDefaults.standard.setValue(true, forKey: createTaskKey)
        
    }
    
    private func setupCustomTabBar() {
        object_setClass(self.tabBar, RightlyTabBar.self)
        self.tabBar.addSubview(customTabBarView)
        currView.clipsToBounds = false
        customTabBarView.addSubview(currView)
        itemsbtn.append(self.spacerBtn)
        itemsbtn.append(self.discoverBtn)
//        itemsbtn.append(publishAddBtn)
        itemsbtn.append(messageBtn)
        itemsbtn.append(personalBtn)
        self.customBarView = currView
        currView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(lrPadding)
            maker.right.equalToSuperview().offset(-lrPadding)
            maker.top.bottom.equalToSuperview()
        }
        self.selectedIndex =  0
        self.arrangeSubViews()
        for button in itemsbtn {
          button.rx.tap.subscribe { [weak self] event in
            guard let `self` = self  else {return }
//            if button.tag == 2 {
//                self.selectTagOrPublishVc()
//            } else{
                self.selectedIndex = button.tag
//            }
  
          }.disposed(by: self.rx.disposeBag)
        }
        GreetingManager.shared().resetGreetingCount()
        //tabbar红点逻辑
        UserRedDotRecordManager.shared.systemPageUnreadCount.subscribe(onNext: { [weak self] systemCount in
            guard let `self` = self  else {return }
            if self.itemsbtn.count > 3 {
                
                if  systemCount > 0  {
                    //1 3 显示红点 //消息列表特殊涉及到im 系统的 推送的不管
                    self.itemsbtn[3].showViewBadgOn()
                }else{
                    self.itemsbtn[3].hideViewBadg()
                }
            }
        }).disposed(by: self.rx.disposeBag)
        self.tabBar.backgroundImage = UIImage.init()
        self.tabBar.shadowImage = UIImage.init()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserRedDotRecordManager.shared.checksystemUnread()
    }
    
    fileprivate func arrangeSubViews(){
        self.currView.addArrangedSubview(self.spacerBtn)
        self.currView.addArrangedSubview(self.discoverBtn)
//        self.currView.addArrangedSubview(self.publishAddBtn)
//        self.publishAddBtn.snp.makeConstraints { (maker) in
//            maker.width.height.equalTo(50)
//        }
        self.currView.addArrangedSubview(self.messageBtn)
        self.currView.addArrangedSubview(self.personalBtn)
    }
    func updateSelectState() {
//        GuideCheckTaskProcess.shared.pauseGuideCheck()
        for item in itemsbtn {
            if self.selectedIndex == item.tag {
                item.isSelected = true
            } else{
                item.isSelected = false
            }
        }
    }
    
    func selectTagOrPublishVc()  {
        let  usertagortopicVc = UserLightOrJoinTopicViewController.loadFromNib()
        usertagortopicVc.modalPresentationStyle = .fullScreen
        usertagortopicVc.processType = .joinTopic(nil)
        self.getCurrentViewController()?.navigationController?.present(usertagortopicVc, animated: true)
    }
}


