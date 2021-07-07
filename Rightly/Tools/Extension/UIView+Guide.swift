//
//  UIView+Guide.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/30.
enum GuideEnter:String {
    case MacthOtherDisLikeTip = "MacthOtherDisLikeTip",
         MacthOtherLikeTip = "MacthOtherLikeTip",
         MatchViewFilter = "MatchViewFilter",
         TopicDetailGuide = "TopicDetailGuide"
}

let  guideConfigKeys = "guideconfig"
/// 引导配置管理
class GuideConfig {
    
    static   func guideConfig() -> [[String:Any]] {
        let guideconfig = UserDefaults.standard.value(forKey:guideConfigKeys)
        if guideconfig == nil {
            let   guide_1 =  ["guide_id":GuideEnter.MacthOtherDisLikeTip.rawValue,"isend":false] as [String : Any]
            let  guide_2 =   ["guide_id":GuideEnter.MacthOtherLikeTip.rawValue,"isend":false] as [String:Any]
            let  guide_3 =   ["guide_id":GuideEnter.MatchViewFilter.rawValue,"isend":false] as [String:Any]
            let  guide_4 =   ["guide_id":GuideEnter.TopicDetailGuide.rawValue,"isend":false] as [String:Any]
            return    [guide_1,guide_2,guide_3,guide_4]
        }else{
            let   arr = guideconfig as! [[String:Any]]
            return  arr
        }
    }
    static  func  savenewGuideConfig( _ config:[[String:Any]] ){
        UserDefaults.standard.set(config, forKey: guideConfigKeys)
        UserDefaults.standard.synchronize()
    }
    
    public static  func   loadGuideConfig(){
        UserDefaults.standard.set(guideConfig(), forKey: guideConfigKeys)
        UserDefaults.standard.synchronize()
    }
    public  static  func   checkGuideend(_ gid:String) -> Bool{
        let   config = guideConfig()
        for guide in  config {
            let  guideid = guide["guide_id"] as! String
            if  guideid == gid {
                let   isend = guide["isend"]  as! Bool
                return  isend
            }
        }
        return false
    }
    static  func updateGuide(_ gid:String ,_ isend:Bool)  {
        let   config = guideConfig()
        var  newconfig = [[String:Any]]()
        for var guide in  config {
            let  guideid = guide["guide_id"] as!  String
            if  guideid == gid{
                guide["isend"] = isend
                debugPrint("guide --- \(guide)")
            }
            newconfig.append(guide)
        }
        savenewGuideConfig(newconfig)
    }
    
    static func checkStep() -> Int {
        let guideconfig = UserDefaults.standard.value(forKey:guideConfigKeys) as? [[String:Any]]
        guard let localGuideInfo = guideconfig else {
            return 0
        }
        var index = 0
        for dic in localGuideInfo  {
            
            if let end = dic["isend"] as? Bool, end != true{
                return index
            }
            index = index + 1
        }
        return  -1 //-1 则都引导完了
    }
}



extension UIView {
   static func stackViewEffect(view: UIView, offsetY: CGFloat, duration: TimeInterval) {
        view.transform = CGAffineTransform(translationX: 0, y: offsetY)
        UIView.animate(withDuration: duration, animations:{
            view.transform = .identity
        })
    }
}
