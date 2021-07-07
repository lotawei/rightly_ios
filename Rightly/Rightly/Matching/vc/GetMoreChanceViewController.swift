//
//  GetMoreChanceViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/14.
//
import Foundation
import UIKit
import FSPagerView
import RxSwift
import MBProgressHUD
import RxCocoa
import Kingfisher


class GetMoreChanceViewController:BaseViewController{
    var  selectedTaskBlock:((_ task:TaskBrief?) -> Void)?=nil
    @IBOutlet weak var backBtn: UIButton!
    var datas: [RTWaterLayoutModelable] = [RTWaterLayoutModelable]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: RTWaterFlowLayout!
    var  avatars:[SysAvatarInfo] = [SysAvatarInfo]()
    @IBOutlet weak var btnrefresh: UIButton!
    @IBOutlet weak var lbltip: UILabel!
    @IBOutlet weak var lblbottomtip: UILabel!
    @IBOutlet weak var lbldestip: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        dataInital()
        lbltip.text = "Get More Chance!".localiz()
        lbldestip.text = "Complete the task, release the instant, and get 5 refresh opprtunities.".localiz()
        lblbottomtip.text = "No one you like? Change a batch!".localiz()
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
            if let  taskDatas = res.modeDataKJTypeSelf(typeSelf: HotResultData.self)?.results {
                self.datas = taskDatas ?? []
                self.collectionView.reloadData()
            }            
        },onError: { (err) in
            MBProgressHUD.showError("request failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearNavigationBarLine()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.setupNavigationBarLine()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func createEmptyUserPublishAction(_ sender: Any) {
            updataInfo()
    }
    func customUserPublish(_ task:TaskBrief)  {
        
        let userpublish = UserPublishViewController.loadFromNib()
        userpublish.tasktype = task.type
        userpublish.tipTaskDes = task.descriptionField
        userpublish.taskid = task.taskId
        userpublish.blockRefresh = {
            [weak self] in
            self?.updataInfo()
        }
        self.navigationController?.pushViewController(userpublish, animated: true)
    }
   
}
extension GetMoreChanceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let t = self.datas[indexPath.item] as? TaskBrief
        guard let task = t else {
            self.toastTip("miss task something go wrong")
            return
        }
        self.customUserPublish(task)
        
    }
}

extension GetMoreChanceViewController: UICollectionViewDataSource {
    
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
extension GetMoreChanceViewController: RTWaterLayoutDelegate {
    
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
        return scaleHeight(35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: RTWaterFlowLayout, minimumItemSpacingForSection section: Int) -> CGFloat {
        return scaleHeight(52)
    }
}



