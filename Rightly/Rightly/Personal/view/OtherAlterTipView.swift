//
//  OtherAlterTipView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/31.
//

import Foundation
import TagListView




class OtherAlterTipView:UIView,NibLoadable {
    @IBOutlet weak var btnreport: UIButton!
    @IBOutlet weak var btnfollow: UIButton!
    @IBOutlet weak var btncancel: UIButton!
    @IBOutlet weak var btnmore: UIButton!
    @IBOutlet weak var taglistView: TagListView!
    
    @IBOutlet weak var btnsWidth: NSLayoutConstraint!
    
    
    var  selectItemBlock:((_ item:ItemSelectType,_ issues:[String])->Void)?=nil
    
    fileprivate var  isExpand:Bool = false {
        didSet {
            self.taglistView.isHidden = !isExpand
        }
    }
    fileprivate var  issues:Set<String> = Set.init()
    @IBOutlet var btnsubViews: [UIButton]!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btnsWidth.constant = screenWidth * 2.0 / 3.0
        self.btnfollow.setTitle("Follow".localiz(), for: .normal)
        self.btnfollow.setTitle("UnFollow".localiz(), for: .selected)
        self.btnreport.setTitle("Report".localiz(), for: .normal)
        self.btncancel.setTitle("system_Cancel".localiz(), for: .normal)
        
        self.isExpand = false
        self.taglistView.addTags(String.reportIssues())
        self.taglistView.textColor = UIColor.gray
        self.taglistView.alignment = .left
        self.taglistView.delegate = self
        self.btnmore.isHidden = true
    }
    
    func hidefollow()  {
        self.btnfollow.isHidden = true
        self.btnsWidth.constant = screenWidth / 3.0
    }
    
    func showfollow()  {
        self.btnfollow.isHidden = false
        self.btnsWidth.constant = screenWidth * 2.0 / 3.0
    }
    
    @IBAction func expandClick(_ sender: Any) {
        if !isExpand {
            isExpand = true
            UIView.animate(withDuration: 0.5) {
                self.btnmore.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi))
                self.taglistView.alpha = 0
                self.taglistView.alpha = 1
            }
        }
        else{
            isExpand = false
            UIView.animate(withDuration: 0.5) {
                self.btnmore.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi*2))
                self.taglistView.alpha = 1
                self.taglistView.alpha = 0
            }
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for btn in btnsubViews {
            btn.layoutButton(style: .Top, imageTitleSpace: 12)
            btn.layoutIfNeeded()
        }
    }
    @IBAction func itemClick(_ sender: UIButton) {
        
        if sender.tag == 0  {
            self.selectItemBlock?(.itemFollow,[])
            self.removeFromWindow()
        }
        if sender.tag == 1  {
            
//          self.selectItemBlock?(.itemReport)
            if isExpand && issues.count > 0 {
                
            }
            else{
                isExpand = true
                UIView.animate(withDuration: 0.5) {
                    self.btnmore.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi))
                    self.taglistView.alpha = 0
                    self.taglistView.alpha = 1
                }
            }
        }
     
     
    }
  
    
    
    @IBAction func cancelclick(_ sender: Any) {
        self.removeFromWindow()
    }
}
extension OtherAlterTipView:TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        self.issues.insert(title)
        self.selectItemBlock?(.itemReport,self.issues.map({ (t) -> String in
            return t
        }))
        self.removeFromWindow()
    }
    
}


extension String  {
    
    /// 举报原因
    /// - Returns:
    static  func  reportIssues() -> [String]{
        return ["Inappropriate language".localiz(),"Sex or violence".localiz(),"Spam".localiz(),"Other".localiz()]
    }
    
    /// 举报类型
    /// - Returns:
    func  reportType() -> Int {
        let  reporissues = String.reportIssues()
        for i in 0..<reporissues.count {
            
            if self ==  reporissues[i] {
                
               return i + 1
            }
        }
        return 0
    }
}
