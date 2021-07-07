//
//  FilterViewModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/8.
//

import Foundation
import KakaJSON

enum Gender:Int,Codable,ConvertibleEnum{
    case none = 0,
         male = 1,
         female = 2
}

extension Gender {
    var  desGender:String {
        switch self {
        case .female:
            return "Female".localiz()
        case .male:
            return "Male".localiz()
        default:
            return "Secret".localiz()
        }
    }
    
    var defHeadName : String {
        switch self {
        case .female:
            return "head_girl"
        case .male:
            return "head_boy"
        default:
            return "default_head_image"
        }
    }
}



enum ViewType:Int,Codable, ConvertibleEnum {
    case  Private = 1,
          `Public` = 2
}
extension ViewType {
    func descShow() -> String {
        switch self {
        case .Private:
            return "Private".localiz()
        default:
            return "Public".localiz()
        }
    }
}
enum TaskType:Int ,CaseIterable ,Codable, ConvertibleEnum {
    case noLimit = 0,
         text = 1,
         voice = 2,
         photo = 3,
         video = 4
}

/// 发布任务必须传的
enum ReleaseType:Int ,CaseIterable,Codable{
    case  greeting = 1 , //打招呼入口
          morechance = 2, //积分
          tag = 3 ,// 基于标签
          topic = 4, //基于话题
          simple = 5 //简易动态 普通的动态 无话题 无标签 的
}

extension TaskType {
    func typeDes() -> String {
        switch self {
        case .text:
            return "Text".localiz()
        case .photo:
            return "Photo".localiz()
        case .video:
            return "Video".localiz()
        case .voice:
            return "Voice".localiz()
        default:
            return ""
        }
    }
    ///个人主页的背景
    func  tasktypeColor() -> UIColor {
        switch self {
        case .voice:
            return  UIColor.init(hex: "E0FFE5")
        case .text:
            return   UIColor.init(hex: "FFF2F4")
        case .photo:
            return  UIColor.init(hex: "FFF2F4")
        default:
            return   UIColor.init(hex: "F0EDF9")
        }
    }
    ///最新版本颜色投票
    func  taskNewVersionColor() -> UIColor {
        switch self {
        case .voice:
            return  UIColor.init(hex: "46D1AC")
        case .photo:
            return   UIColor.init(hex: "FFAF22")
        case .video:
            return  UIColor.init(hex: "AB36FF")
        default:
            return   UIColor.init(hex: "FFAF22")
        }
    }
    
    //新版有阴影的底图按钮
    func taskBtnBackGroundImage() -> UIImage? {
        var  imageName = "photo_button_background"
        switch self {
        case .voice:
            imageName =  "voice_button_background"
        case .photo:
            imageName = "photo_button_background"
        case .video:
            imageName = "video_button_background"
        default:
            imageName = "photo_button_background"
            break
        }
        return UIImage.init(named: imageName)
    }
    
    
    
    /// 粉丝关注和游客模式的显示
    /// - Returns:
    func taskTipdisplay() -> String {
        switch self {
        case .text:
            return "[Text task]".localiz()
        case .photo:
            return "[Photo task][Photo]".localiz()
        case .video:
            return "[Video task][Video]".localiz()
        case .voice:
            return "[Voice task][Voice]".localiz()
        default:
            return ""
        }
    }
    func typeTitle() -> String {
        switch self {
        case .text:
            return "Text task".localiz()
        case .photo:
            return "Photo task".localiz()
        case .video:
            return "Video task".localiz()
        case .voice:
            return "Voice task".localiz()
        default:
            return ""
        }
    }
    
    func typeTitleIconName() -> String {
        switch self {
        case .photo:
            return "task_image_icon"
        case .video:
            return "task_video_play_icon"
        case .voice:
            return "task_audio_play_icon"
        default:
            return ""
        }
    }
    //最新版本  带背景色和中间图标的
    func typeCenterTaskIconImage() -> UIImage? {
        var imageName = "centerPhoto"
        switch self {
        case .photo:
            imageName = "centerPhoto"
        case .video:
            imageName = "centerVideo"
        case .voice:
            imageName = "centerVoice"
        default:
            imageName = "centerPhoto"
        }
        return UIImage.init(named: imageName)
    }
    
    //最新版本  带背景色和中间图标的 这种视图会被拉伸
    func typeBgImage() -> UIImage {
        var imageName = ""
        switch self {
        case .photo:
            imageName = "task_image_bg_image"
        case .video:
            imageName = "task_video_bg_image"
        case .voice:
            imageName = "task_audio_bg_image"
        default:
            imageName = ""
        }
        
        guard let resultImage = UIImage(named: imageName) else {
            return UIImage.init()
        }
        
        let tb = resultImage.size.height / 3.0
        let lr = resultImage.size.width / 3.0
        return resultImage.resizableImage(withCapInsets: UIEdgeInsets(top: tb, left: lr, bottom: tb, right: lr), resizingMode: .stretch)
    }
    
    func taskDescColor() -> UIColor {
        switch self {
        case .voice:
            return  UIColor.init(hex: "46D1AC")
        case .text:
            return   UIColor.init(hex: "000000")
        case .photo:
            return  UIColor.init(hex: "F3B347")
        default:
            return   UIColor.init(hex: "9E3EF6")
        }
    }
    
    func taskbackColor() -> UIColor? {
        var  image:UIImage? = nil
        switch self {
        case .text:
            return UIColor.white
        case .photo:
            image =  UIImage.init(named: "photoback")
            
        case .video:
            image =  UIImage.init(named: "videoback")
        case .voice:
            image =  UIImage.init(named: "voiceback")
        default:
            return UIColor.white
        }
        if let img = image {
            return UIColor.init(patternImage:img)
        }
        return UIColor.white
    }
    
//    func taskImageColor() -> UIColor {
//
//        switch self {
//        case .text:
//            return UIColor.white
//        case .photo:
//            return UIColor.init(hex: "A83B4D")
//        case .video:
//            return UIColor.init(hex: "4A38B5")
//        case .voice:
//            return UIColor.init(hex: "1D822F")
//        default:
//            return UIColor.black
//        }
//    }
    
    func  taskImageIcon() -> UIImage?{
        var taskimg:UIImage? = UIImage.init()
        switch self {
        case .photo:
            taskimg = UIImage.init(named: "phototask")
        case .text:
            taskimg = UIImage.init()
        case .voice:
            taskimg = UIImage.init(named: "voicetask")
        case .video:
            taskimg = UIImage.init(named: "videotask_selected")
        default:
            taskimg = UIImage.init()
        }
        return taskimg
    }
    //2021 5 -14加入
    func  NewtaskImageIcon() -> UIImage?{
        var taskimg:UIImage? = UIImage.init()
        switch self {
        case .photo:
            taskimg = UIImage.init(named: "newphototask")
        case .text:
            taskimg = UIImage.init()
        case .voice:
            taskimg = UIImage.init(named: "newvoicetask")
        case .video:
            taskimg = UIImage.init(named: "newvideotask_selected")
        default:
            taskimg = UIImage.init()
        }
        return taskimg
    }
    //2021 6 9号加入
    func NewTaskTipStyleTextColor() -> UIColor? {
        return self.taskNewVersionColor()
    }
    func NewTaskTipBackColor() -> UIColor? {
        switch self {
        case .voice:
            return UIColor(red: 213/255.0 , green: 245/255.0, blue: 235/255.0, alpha: 1)
        case .photo:
            return  UIColor(red: 253.0/255.0, green: 238/255.0, blue: 213/255.0, alpha: 1)
        case .video:
            return  UIColor(red: 233/255.0, green: 210/255.0, blue: 253/255.0, alpha: 1)
        default:
            return  UIColor(red: 253.0/255.0, green: 238/255.0, blue: 213/255.0, alpha: 1)
        }
    }
}

struct FilterModel:Convertible{
    var  gender:Set<Gender> = Set.init()
    var  taskType:Set<TaskType> = Set.init()
}


