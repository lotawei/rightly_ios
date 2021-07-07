//
//  SignInputInfoViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/15.
//

import Foundation
import UIKit
import FSPagerView
import RxSwift
import MBProgressHUD
import RxCocoa
import Kingfisher


class CustomLinearTransformer: FSPagerViewTransformer {
    override func proposedInteritemSpacing() -> CGFloat {
        return  10
    }
}

class SignInputInfoViewController:BaseViewController{
    var  shouldSet:Bool = false
    @IBOutlet weak var lblinfotip: UILabel!
    var  nameselectedValid:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var  birthselectedValid:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var  locationselectedvalid:BehaviorRelay<Bool> = BehaviorRelay.init(value: true)
    var  lng:Double?=nil
    var  lat:Double?=nil
    let locationmanager = LocationManager.init()
    var  validSuccess:Observable<Bool>?=nil
    @IBOutlet weak var birthpickClick: UIButton!
    @IBOutlet weak var locationpickClick: UIButton!
    @IBOutlet weak var btnnameicon: UIButton!
    @IBOutlet weak var btnbirthicon: UIButton!
    @IBOutlet weak var btnloctationicon: UIButton!
    var  publishValidSend:PublishSubject<Bool> = PublishSubject.init()
    var  avatarselectIndex:Int = 0
    @IBOutlet weak var topbackimg: UIImageView!
    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var locationtxt: UITextField!
    @IBOutlet weak var birthtxt: UITextField!
    @IBOutlet weak var genderview: UIView!
    @IBOutlet weak var centerOffy: NSLayoutConstraint!
    var  selectSex:BehaviorRelay<Int> = BehaviorRelay.init(value: -1)
    @IBOutlet weak var btnfemale: UIButton!
    @IBOutlet weak var btnmale: UIButton!
    @IBOutlet weak var sexwidth: NSLayoutConstraint!
    @IBOutlet weak var ovallayer: UIImageView!
    var  originalavatars:[SysAvatarInfo] = [SysAvatarInfo]()
    var  avatars:[SysAvatarInfo] = [SysAvatarInfo]()
    @IBOutlet weak var btncommit: UIButton!
    @IBOutlet weak var inputformView: UIView!
    @IBOutlet weak var selectBannerView: UIView!
    lazy var bannerView:FSPagerView = {
        let bannerview = FSPagerView.init()
        bannerview.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        bannerview.decelerationDistance = FSPagerView.automaticDistance
        return  bannerview
    }()
    fileprivate func setupView() {
        
        self.btncommit.setBackgroundImage(UIImage.init(named: "normalback")!.resizeImage(), for: .normal)
        self.btncommit.setBackgroundImage(UIImage.init(named: "selectedback")!.resizeImage(), for: .selected)
        lblinfotip.text = lblinfotip.text?.localiz()
        nametxt.placeholder = "Your Name".localiz()
        birthtxt.placeholder = "Birthday".localiz()
        locationtxt.placeholder = "location".localiz()
        self.selectBannerView.addSubview(self.bannerView)
        self.bannerView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalToSuperview()
        }
        bannerView.transformer = CustomLinearTransformer(type:.linear)
        bannerView.itemSize = CGSize.init(width: 100, height: 100)
        bannerView.isInfinite = true
        self.bannerView.delegate = self
        self.bannerView.dataSource = self
        
        self.btnmale.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self  else {return }
            self.updateSex(selectTag: 0)
            
        }).disposed(by: self.rx.disposeBag)
        self.btnfemale.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self  else {return }
            self.updateSex(selectTag: 1)
            
            
        }).disposed(by: self.rx.disposeBag)
        self.genderview.clipsToBounds = false
        
        
    }
    
    func  updateSex(selectTag:Int){
        if selectSex.value == -1 {
            self.btnfemale.isHidden = true
            if selectTag == 0 {
                self.btnmale.setImage(UIImage.init(named: "maleselected"), for: .normal)
                selectSex.accept(1)
            }
            else{
                self.btnmale.setImage(UIImage.init(named: "femaleselected"), for: .normal)
                selectSex.accept(2)
            }
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3) {
                self.sexwidth.constant = 70
                self.view.layoutIfNeeded()
            }
            
        }
        else  {
            let backimage = (selectSex.value == 1 ) ? UIImage.init(named: "femaleselected") : UIImage.init(named: "maleselected")
            self.btnmale.setImage(backimage, for: .normal)
            self.centerOffy.constant = -50
            self.btnmale.alpha = 0.3
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.centerOffy.constant = 0
                self.btnmale.alpha = 1
                self.view.layoutIfNeeded()
            }
            selectSex.accept((selectSex.value == 1 ) ? 2:1)
        }
        let selectGender = Gender.init(rawValue: selectSex.value )
        
        self.avatars = self.originalavatars.filter({ (info) -> Bool in
            return info.gender == selectGender
        })
        self.avatarselectIndex = 0
        self.bannerView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fd_prefersNavigationBarHidden = true
        setupView()
        dataInital()
        
    }
    
    func setKillInfo()  {
        guard let info = UserManager.manager.currentUser?.additionalInfo else {
            return
        }
        self.nametxt.text = info.nickname
        self.nameselectedValid.accept(!(info.nickname?.isEmpty ??  true))
        if let birth = info.birthday {
            self.birthtxt.text = Date.formatTimeStamp(time:birth , format: "yyyy-MM-dd")
            
        }
        birthselectedValid.accept(!(self.birthtxt.text?.isEmpty ?? true))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inputformView.setRoundCorners([.topLeft,.topRight], radius: 30)
        inputformView.layoutIfNeeded()
    }
    func dataInital()  {
        
        self.nameselectedValid.asDriver().drive(self.btnnameicon.rx.isSelected)
            .disposed(by: self.rx.disposeBag)
        self.nametxt.rx.text.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self  else {return }
            self.nameselectedValid.accept(!(text?.isEmpty ?? true))
        }).disposed(by: self.rx.disposeBag)
        
        self.birthselectedValid.asDriver().drive(self.btnbirthicon.rx.isSelected)
            .disposed(by: self.rx.disposeBag)
        self.birthtxt.rx.text.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self  else {return }
            self.birthselectedValid.accept(!(text?.isEmpty ?? true))
        }).disposed(by: self.rx.disposeBag)
        self.locationselectedvalid.asDriver().drive(self.btnloctationicon.rx.isSelected)
            .disposed(by: self.rx.disposeBag)
        self.locationtxt.rx.text.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self  else {return }
            //            self.locationselectedvalid.accept(!(text?.isEmpty ?? true))
            self.locationselectedvalid.accept(true)
        }).disposed(by: self.rx.disposeBag)
        self.birthpickClick.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.showDatePicker()
        }).disposed(by: self.rx.disposeBag)
        
        self.locationmanager.city
            .subscribe(onNext: { [weak self] (city) in
                guard let `self` = self  else {return }
                self.locationtxt.text = city
                self.locationselectedvalid.accept(true)
        }).disposed(by: self.rx.disposeBag)
        
        self.locationmanager.curlocationinfo.asObserver().subscribe(onNext: { [weak self] (location) in
            guard let `self` = self  else {return }
            self.lng = location.coordinate.longitude
            self.lat = location.coordinate.latitude
        }).disposed(by: self.rx.disposeBag)
        validSuccess  =   Observable.combineLatest(nameselectedValid.asObservable(),selectSex.asObservable(), birthselectedValid.asObservable(),locationselectedvalid.asObservable()).map { (namevalid,selectindex,birthvalid,selectlocation) -> Bool in
            return namevalid && birthvalid && selectindex != -1
        }
        validSuccess?.bind(to: self.btncommit.rx.isSelected).disposed(by: self.rx.disposeBag)
        self.btncommit.rx.tap.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.actiondealWith()
        }).disposed(by: self.rx.disposeBag)
        UserProVider.init().systemChooseAvatarInfos(self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if  let dicData = res.data as? [String:Any]{
                    self.originalavatars = dicData.kj.model(SystemAvatarInfos.self).values ?? []
                    self.avatars = self.originalavatars
                    if self.avatars.count > 0 {
                        self.updateBackImage(0)
                        self.avatarselectIndex = 0
                        self.bannerView.reloadData()
                    }else{
                        MBProgressHUD.showError("No avatar setting".localiz())
                    }
                }
            },onError: { (err) in
                MBProgressHUD.showError("Network Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
    
    @IBAction func clickLocation(_ sender: Any) {
        
        locationmanager.startOnceLocation{
            [weak self]
            status in
            guard let `self` = self  else {return }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldSet {
            //            self.setKillInfo()
        }
        locationmanager.startOnceLocation{
            [weak self]
            status in
            guard let `self` = self  else {return }
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationmanager.stopLocation()
    }
    func actiondealWith(){
        if nameselectedValid.value == false {
            MBProgressHUD.showError("Input Your Name".localiz())
            return
        }
        if selectSex.value == -1 {
            MBProgressHUD.showError("Choose Your Gender".localiz())
            return
        }
        if birthselectedValid.value == false {
            MBProgressHUD.showError("Choose Your BirthDay".localiz())
            return
        }
        let userprovider = UserProVider.init()
        let img = self.avatars[self.avatarselectIndex]
        MBProgressHUD.showStatusInfo("Editing.....".localiz())
        var birthdaytimeval:TimeInterval?
        if let birthday = self.birthtxt.text {
            birthdaytimeval  =  String.dateTransformtimeStamp(birthday)
        }
        userprovider.editUser(nickname: self.nametxt.text, gender: self.selectSex.value, birthday: birthdaytimeval, avatar: img.url,address: locationtxt.text,lng: lng,lat: lat,self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                MBProgressHUD.dismiss()
                MBProgressHUD.showSuccess("Update Success".localiz())
                AppDelegate.reloadRootVC()
//                switch res {
//                case .success(let info):
//                    MBProgressHUD.showSuccess("Update Success".localiz())
//                    AppDelegate.reloadRootVC()
//                    break
//                case .failed(let err):
//                    MBProgressHUD.showError("Update Failed".localiz())
//                }
            },onError: { (err) in
                MBProgressHUD.showError("Update Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
        
        
    }
}
extension  SignInputInfoViewController:FSPagerViewDelegate,FSPagerViewDataSource{
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        updateBackImage(targetIndex)
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        let img = avatars[index]
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 50
        
        cell.imageView?.kf.setImage(with: URL.init(string: img.url?.dominFullPath() ?? ""), placeholder: UIImage.init(named: "userpersonal"),options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height:100 ))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        return cell
    }
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return  avatars.count
    }
    fileprivate func updateBackImage(_ index: Int) {
        let img = avatars[index]
        self.topbackimg.kf.setImage(with: URL.init(string: img.backgroundUrl?.dominFullPath() ?? ""), placeholder: UIImage.init(named: "images"))
        self.avatarselectIndex = index
        //        if let gender = img.gender {
        //            self.updateSex(selectTag: gender.rawValue - 1)
        //        }
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        
        UIView.animate(withDuration: 0.6) {
            self.ovallayer.transform = CGAffineTransform.init(scaleX:0.5, y: 0.5)
            self.ovallayer.transform = CGAffineTransform.identity
        }
        updateBackImage(index)
        
    }
    
}

extension  SignInputInfoViewController {
    func showDatePicker(){
        self.nametxt.resignFirstResponder()
        //        let  birthdayPic = BirthdayPickerView.init(frame: .zero)
        //        let dateNow = Date.init(timeIntervalSinceNow:24*60*60) //往后一天
        //        birthdayPic.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: 350)
        //        birthdayPic.compeletedSelectedDate = { (date) in
        //
        //            if date > Date.init(timeIntervalSince1970: 0) && date <  dateNow {
        //                let formatter = DateFormatter()
        //                formatter.dateFormat = "yyyy-MM-dd"
        //                self.birthtxt.text = formatter.string(from: (date < Date.init(timeIntervalSince1970: 0)) ? Date.init(timeIntervalSince1970: 0):date)
        //                self.birthselectedValid.accept ( !(self.birthtxt.text?.isEmpty ?? true))
        //            }else{
        //                self.toastTip("Birthday should limited by 1970 ~ Now".localiz())
        //            }
        //
        //        }
        //        birthdayPic.show(v: self.view)
        let dateNow = Date.init(timeIntervalSinceNow:24*60*60)
        self.view.showDatePicker(selectDate:nil) { (date) in
            //            if date > Date.init(timeIntervalSince1970: 0) && date <  dateNow {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.birthtxt.text = formatter.string(from: (date < Date.init(timeIntervalSince1970: 0)) ? Date.init(timeIntervalSince1970: 0):date)
            self.birthselectedValid.accept ( !(self.birthtxt.text?.isEmpty ?? true))
            //            }
            //            else{
            //                self.toastTip("Birthday should limited by 1970 ~ Now".localiz())
            //            }
        }
        
    }
    
    
}
