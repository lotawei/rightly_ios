//
//  SpacerFirstWelcomeView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/14.
//

import Foundation
fileprivate let  localWelcomeKeys = "localWelcomeKeys"
class SpacerFirstWelcomeView:UIView,NibLoadable {
    @IBOutlet weak var lbldes: UILabel!
    @IBOutlet weak var lblwecomle: UILabel!
    @IBOutlet weak var btngotit: UIButton!
    var  doneSuccessBlock:SuresuccessBlock?=nil
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        lblwecomle.text = "WelCome".localiz()
        lbldes.text  = "Welcome to the Right.ly community! Finish the chat up task and start chatting with new friends!".localiz()
        btngotit.setTitle("Got it".localiz(), for: .normal)
    }
    
    @IBAction func doneclick(_ sender: Any) {
        let   userid = UserManager.manager.currentUser?.additionalInfo?.userId  ?? -123123
        let  userHasClick = true
        SpacerFirstWelcomeView.insertNewUserStorage(userid, userHasClick)
        self.removeFromWindow()
        self.doneSuccessBlock?()
    }
    static func  insertNewUserStorage(_ userid:Int64,_ userhasclick:Bool){
        var  locvalues =  loadDatas()
        if locvalues == nil {
            locvalues  =  ["datas":[["userid":userid,"userhasclick":userhasclick]]]
            UserDefaults.standard.setValue(locvalues!, forKey: localWelcomeKeys)
            UserDefaults.standard.synchronize()
        }
        else{
            if var  datas = locvalues?["datas"] as? Array<[String:Any]> {
                var  issexistUser =  datas.filter { (dic) -> Bool in
                    return  ((dic["userid"] as? Int64) == userid)
                }
                //存在
                if issexistUser.count > 0  {
                    datas.removeAll { (dic) -> Bool in
                        ((dic["userid"] as? Int64) == userid)
                    }
                    datas.append(["userid":userid,"userhasclick":userhasclick])
                }else{
                    datas.append(["userid":userid,"userhasclick":userhasclick])
                }

                locvalues?["datas"] = datas
                if let newlocvalues = locvalues {
                    UserDefaults.standard.setValue(newlocvalues, forKey: localWelcomeKeys)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    static func loadDatas() -> [String:Any]?{
        if let  dic =  UserDefaults.standard.object(forKey: localWelcomeKeys) as? [String:Any] {
            return dic
        }
        return nil
    }
    @discardableResult
    static func  showWelcomeSpacerView(_ doneCompeletion:@escaping SuresuccessBlock) -> Bool{
        if UserManager.manager.currentUser == nil {
            return  false
        }
        var  displayed = false
        if let  dic =  UserDefaults.standard.object(forKey: localWelcomeKeys) as? [String:Any] {
            if let  arrdatas = dic["datas"] as? Array<Any> {
                for itemdic in arrdatas {
                    if let item = itemdic as? [String:Any] {
                        guard let  userid = item["userid"] as? Int else {
                                
                            continue
                        }
                        if userid == (UserManager.manager.currentUser?.additionalInfo?.userId ?? -123123) {
                            displayed = (item["userhasclick"] as? Bool ) ?? false
                        }
                    }
                }
            }
        }
        if displayed  {
            return false
        }
        else{
            let  aview = SpacerFirstWelcomeView.loadNibView()
            aview?.frame = CGRect.init(x: 0, y: 0, width: 295, height: 344)
            aview?.showOnWindow( direction: .center, enableclose: false)
            aview?.doneSuccessBlock = {
                doneCompeletion()
            }
            return true
        }
    }
}
