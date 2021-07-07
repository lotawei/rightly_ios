//
//  UserChooseAvatarViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import FSPagerView
import Kingfisher
class UserChooseAvatarViewController:BaseViewController{
    @IBOutlet weak var lblchooseAvatar: UILabel!
    @IBOutlet weak var selectimg: UIImageView!
    var  avatars:[SysAvatarInfo] = [SysAvatarInfo]()
    var  originalAvatars:[SysAvatarInfo] = [SysAvatarInfo]()
    var  avatarselectIndex:Int = 0
    var  genderLimit:Gender?=nil
    @IBOutlet weak var backimg: UIImageView!
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize.init(width: 76, height: 76)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = (screenWidth - 16.0 - 76.0 * 4) / 3.0 - 1.0
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: AvatarSelectCollectionView.self)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    @IBOutlet weak var btnsavev: UIButton!
    @IBOutlet weak var ovalyerimg: UIImageView!
    
    @IBOutlet weak var sanjiaoimg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genderLimit = UserManager.manager.currentUser?.additionalInfo?.gender
        self.lblchooseAvatar.text = "Choose a Avatar".localiz()
        self.btnsavev.setTitle(self.btnsavev.title(for: .normal)?.localiz(), for: .normal)
        self.fd_prefersNavigationBarHidden = true
        self.view.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(self.sanjiaoimg.snp.bottom)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        
        gainSystemAvatar()
    }
    
    func gainSystemAvatar(){
        UserProVider.init().systemChooseAvatarInfos(self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                if let dicData = res.data as? [String:Any] {
                    self.originalAvatars = dicData.kj.model(SystemAvatarInfos.self).values ?? []
                    if let gender = self.genderLimit  {
                        self.avatars = self.originalAvatars.filter({ (info) -> Bool in
                            return info.gender == gender
                        })
                    }else{
                        self.avatars = self.originalAvatars
                    }
                    if self.avatars.count > 0 {
                        let selectindex =  Int.random(lower: 0, self.avatars.count)
                        if selectindex < self.avatars.count {
                            self.avatarselectIndex = selectindex
                            self.collectionView.reloadData()
                            self.updateBackImage(selectindex)
                        }
                    }
                }
            },onError: { (err) in
                MBProgressHUD.showError("Network Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
        
       
    }
    
    @IBAction func popclick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAvatar(_ sender: Any) {
        if avatars.count == 0 {
            return
        }
        
        let img = self.avatars[self.avatarselectIndex]
        UserProVider.init().editUser(avatar: img.url, self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.dismiss()
                MBProgressHUD.showSuccess("Update Success".localiz())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                       self.navigationController?.popViewController(animated: true)
                }
//                switch res {
//                case .success(let info):
//                    guard let resinfo = info else {
//                        return
//                    }
//
//                    MBProgressHUD.showSuccess("Update Success".localiz())
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                    break
//                case .failed(let err):
//                    MBProgressHUD.showError("Update Failed".localiz())
//                }
            },onError: { (err) in
                    MBProgressHUD.showError("Update Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
    
}
extension  UserChooseAvatarViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatars.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:AvatarSelectCollectionView = collectionView.dequeueReusableCell(for: indexPath, cellType: AvatarSelectCollectionView.self)
        let  isselect = self.avatarselectIndex == indexPath.row
        let info = self.avatars[indexPath.row]
        cell.updateSelect(isselect, avtarInfo: info, indexpath: indexPath)
        cell.itemIndexPathBlock = { [weak self]
            indexpath in
            guard let `self` = self  else {return }
            
            self.avatarselectIndex = indexpath.row
            self.updateBackImage(indexpath.row)
            self.collectionView.reloadData()
        }
        return cell
    }
    fileprivate func updateBackImage(_ index: Int) {
        if avatars.count > 0  {
            let img = avatars[index]
            self.backimg.kf.setImage(with: URL.init(string: img.backgroundUrl?.dominFullPath() ?? ""), placeholder: placehodlerImg)
            self.selectimg.kf.setImage(with:  URL.init(string: img.url?.dominFullPath() ?? ""), placeholder: placehodlerImg)
        }
        UIView.animate(withDuration: 0.6) {
            self.ovalyerimg.transform = CGAffineTransform.init(scaleX:0.5, y: 0.5)
            self.ovalyerimg.transform = CGAffineTransform.identity
        }
    }
    
}
//extension  UserChooseAvatarViewController:FSPagerViewDelegate,FSPagerViewDataSource{
//    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
//        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
//        let img = avatars[index]
//        cell.imageView?.layer.masksToBounds = true
//        cell.imageView?.layer.cornerRadius = 50
//
//        cell.imageView?.kf.setImage(with: URL.init(string: img.url?.dominFullPath() ?? ""), placeholder: UIImage.init(named: "placehodler"),options: [
//                                                     .processor(DownsamplingImageProcessor(size: CGSize(width: 100, height:100 ))),
//                                                     .scaleFactor(UIScreen.main.scale),
//                                                     .cacheOriginalImage
//                                           ])
//
//        return cell
//    }
//
//
//    func numberOfItems(in pagerView: FSPagerView) -> Int {
//        return  avatars.count
//    }
//
//
//    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
//        pagerView.deselectItem(at: index, animated: true)
//        pagerView.scrollToItem(at: index, animated: true)
//
////        UIView.animate(withDuration: 0.6) {
////            self.ovallayer.transform = CGAffineTransform.init(scaleX:0.5, y: 0.5)
////            self.ovallayer.transform = CGAffineTransform.identity
////        }
//        updateBackImage(index)
//
//    }
//
//    fileprivate func updateBackImage(_ index: Int) {
//        let img = avatars[index]
//        self.backimg.kf.setImage(with: URL.init(string: img.backgroundUrl?.dominFullPath() ?? ""), placeholder: UIImage.init(named: "placehodler"))
//        self.avatarselectIndex = index
//    }
//}


