//
//  UserFollowCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import Reusable
import RxSwift
import RxCocoa
class UserFollowCell: UITableViewCell,NibReusable {
    var  refreshBlock:(()->Void)?=nil
    var bag = DisposeBag()
    var  resultdata:BehaviorRelay<UserFollowResult?> = BehaviorRelay.init(value: nil)
    @IBOutlet weak var userimg: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    
    @IBOutlet weak var biolbl: UILabel!
    
    @IBOutlet weak var followBtn: FollowUIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag.init()
    }
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.resultdata.asObservable().subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            guard let  result = res else {
                return
            }
            self.updateCell(result)
            
        }).disposed(by: self.rx.disposeBag)
        
    }
    
    fileprivate  func updateCell(_ result:UserFollowResult ){
        if UserManager.isOwnerMySelf(result.user?.userId)  {
            self.followBtn.isHidden = true
        }else{
            self.followBtn.isHidden = false
        }
        self.followBtn.isSelected = result.user?.isfocused ?? false
        self.nickname.text = result.user?.nickname
        let inbundleimg = placehodlerImg
        if let ownerAvatarUrl = result.user?.avatar?.dominFullPath(), !ownerAvatarUrl.isEmpty {
            userimg.kf.setImage(with: URL(string:ownerAvatarUrl), placeholder: inbundleimg)
        }else{
            userimg.image = inbundleimg
        }
//        if let content = result.user?.greeting?.content ,!content.isEmpty{
//            self.biolbl.text =  "[New post]".localization + "\(content)"
//        }else{
            guard let tastktype = result.user?.greeting?.taskType else {
                return
            }
            self.biolbl.text  = tastktype.taskTipdisplay()
//        }
        
    }
    @IBAction func focusactionClick(_ sender: UIButton) {
        if  let  userid = self.resultdata.value?.user?.userId {
            if UserManager.manager.currentUser == nil {
                AppDelegate.jumpLogin()
                return
                
            }
            UserProVider.focusUser(self.followBtn.isSelected, userid: userid, self.rx.disposeBag) {[weak self] (isfocus) in
                guard let `self` = self  else {return }
                self.followBtn.isSelected =  isfocus
            }
            
        }
    }
    
    
    
}

