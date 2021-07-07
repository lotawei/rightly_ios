//
//  HotTaskCollectionViewCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/19.
//

import Foundation


import Foundation
import Kingfisher
import Reusable
class HotTaskCollectionViewCell: UICollectionViewCell,NibReusable{
    
    
    @IBOutlet weak var backimg: UIImageView!
    @IBOutlet weak var taskimgView: UIImageView!
    @IBOutlet weak var taskdes: UILabel!
    @IBOutlet weak var taskdescription: UILabel!
    @IBOutlet weak var lbltask: UILabel!
    
    override  func awakeFromNib() {
        super.awakeFromNib()

        
    }
    func  updateTask(_ task:TaskBrief) {
        let tasktype = task.type
        if let str = task.descriptionField {
            self.taskdescription.text =   str
        }
        var taskde:String = ""
        var  taskimg:UIImage?
        let task:TaskType =  tasktype
        switch task {
        case .photo:
         
            taskimgView.image = taskimg
            taskde = "Photo task".localiz()
        case .text:
            taskimg = nil
            taskde = "Text task".localiz()
            taskimgView.image = nil
        case .voice:
            
            taskde = "Voice task".localiz()
            taskimgView.image = taskimg
        case .video:
            
            taskde = "Video task".localiz()
            taskimgView.image = taskimg
        default:
            taskimg = UIImage.init()
            taskde = "None".localiz()
            taskimgView.image = taskimg
        }
        taskimgView.image = nil // 新版本不要了 哪天要弄回来就用上面
        self.taskdes.text = taskde
        self.backimg.image = task.typeCenterTaskIconImage()
        self.contentView.backgroundColor = task.taskNewVersionColor()
    }
}
