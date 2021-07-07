//
//  GuideCreateHotTaskViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/19.
//
import Foundation
import UIKit
import FSPagerView
import RxSwift
import MBProgressHUD
import RxCocoa
import Kingfisher

struct ItemLayout: RTWaterLayoutModelable {
    var size: CGSize
}

class GuideCreateHotTaskViewController:BaseViewController{
    var  isFirstLoad:Bool = false
    var  selectedTaskBlock:((_ task:TaskBrief?) -> Void)?=nil
    var datas: [RTWaterLayoutModelable] = [RTWaterLayoutModelable]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: RTWaterFlowLayout!
    var  avatars:[SysAvatarInfo] = [SysAvatarInfo]()
    @IBOutlet weak var btneditor: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var lblDesTip: UILabel!
    @IBOutlet weak var lbltip: UILabel!
    @IBOutlet weak var lblbottomtip: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        dataInital()
        lbltip.text = "Task library".localiz()
        lblDesTip.text = "Select a greeting task ".localiz()
        lblbottomtip.text = "No one you like? Customzie one!".localiz()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearNavigationBarLine()
        self.backBtn.isHidden = self.isFirstLoad
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setupNavigationBarLine()
    }
    
    func dataInital()  {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView?.register(UINib.init(nibName: "HotTaskCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        self.layout.delegate = self
        layout.sectionInset = UIEdgeInsets.init(top: scaleHeight(12), left: 8, bottom: scaleHeight(12), right: 8)
        self.layout.layoutDirection = .horizontal
        updataInfo()
    }
    
    func updataInfo()  {
        let  userporvider = MatchTaskGreetingProvider.init()
        userporvider.getRecommendTask(10, self.rx.disposeBag)
        .subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let resultdata = res.modeDataKJTypeSelf(typeSelf:HotResultData.self)?.results {
                    self.datas = resultdata
                    self.collectionView.reloadData()
            }
//            switch res {
//            case .success(let response):
//                guard let datas = response else {
//                    return
//                }
//                self.datas = datas ?? []
//                self.collectionView.reloadData()
//            case .failed(let err):
//                MBProgressHUD.showError("request failed".localiz())
//            }

        },onError: { (err) in
            MBProgressHUD.showError("request failed".localiz())
        }).disposed(by: self.rx.disposeBag)
        
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createRleaseAction(_ sender: Any) {
        customTaskCreat()
    }
    
    func customTaskCreat()  {
        if selectedTaskBlock != nil {
            self.selectedTaskBlock?(nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let releaseVc = ReleaseTaskViewController.loadFromNib()
        releaseVc.firstCompleReload = true
        self.navigationController?.pushViewController(releaseVc, animated: false)
    }
}

extension GuideCreateHotTaskViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let t = self.datas[indexPath.item] as? TaskBrief
        if selectedTaskBlock != nil {
            self.selectedTaskBlock?(t)
            self.navigationController?.popViewController(animated: true)
            return
        }
        let releaseVc = ReleaseTaskViewController.loadFromNib()
        releaseVc.firstCompleReload = true
        releaseVc.task = t
        self.navigationController?.pushViewController(releaseVc, animated: false)
    }
}

extension GuideCreateHotTaskViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HotTaskCollectionViewCell
        let task = datas[indexPath.item] as? TaskBrief
        guard let t = task else {
            return cell
        }
        cell.updateTask(t)
        return cell
    }
    
    
}
extension GuideCreateHotTaskViewController: RTWaterLayoutDelegate {
    
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: RTWaterFlowLayout,
                         ratioForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: datas[indexPath.item].size.width, height: datas[indexPath.item].size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout, waterCountForSection section: Int) -> Int {
         return  3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout, waterWidthForSection section: Int, at index: Int) -> CGFloat {
        return  sizehottaskHeight
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout,
                         minimumWaterSpacingForSection section: Int) -> CGFloat {
        return scaleHeight(40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout, minimumItemSpacingForSection section: Int) -> CGFloat {
        return scaleHeight(52)
    }
}



