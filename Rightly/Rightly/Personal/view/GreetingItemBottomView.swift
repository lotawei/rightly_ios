//
//  GreetingItemBottomView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/30.
//

import Foundation

enum ItemSelectType:Int {
    case  itembeTop = 0,
          itemPrivacy = 1,
          itemDelete = 2,
          itemReport = 3,
          itemFollow = 4,
          itemCancelTop = 5
}
enum GreetingItemSelectType {
    case  itemResult(_ type:ItemSelectType,result:Any?)
}

class GreetingItemBottomView:UIView,NibLoadable {
    var  selectItemBlock:((_ item:GreetingItemSelectType)->Void)?=nil
    var  selectItem:Any?=nil
    var  reportIssuesBlock:()
    @IBOutlet var btnsubViews: [UIButton]!
    
    @IBOutlet weak var btncancel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btncancel.setTitle("system_Cancel".localiz(), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for btn in btnsubViews {
            btn.setTitle(btn.title(for: .normal)?.localiz(), for: .normal)
            btn.layoutButton(style: .Top, imageTitleSpace: 10)
            btn.layoutIfNeeded()
            
        }
    }
    @IBAction func itemClick(_ sender: UIButton) {
        guard let item = self.selectItem else {
            return
        }
        var  result:GreetingItemSelectType
        switch sender.tag {
        case 0:
            result = GreetingItemSelectType.itemResult(.itembeTop, result: item)
        case 1:
            result = GreetingItemSelectType.itemResult(.itemPrivacy, result: item)
        case 2:
            result = GreetingItemSelectType.itemResult(.itemDelete, result: item)
        default:
            
             return
        }
        self.selectItemBlock?(result)
        self.removeFromWindow()
        

    }
  
    @IBAction func cancelclick(_ sender: Any) {
        self.removeFromWindow()
    }
}
