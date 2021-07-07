//
//  CommentEditView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/10.
//

import UIKit
import KMPlaceholderTextView

class CommentEditView: UIView, NibLoadable {
    let textMinHeight:CGFloat = 42.0
    let textMaxHeight:CGFloat = 150.0
    let textMaxLength:Int = 100
    var textIsMoreThanMax:Bool = false
    
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
        self.textViewBottom.constant = 8 + safeBottomH
        self.textView.placeholder = "Post a comment".localiz()
    }
}

extension CommentEditView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.sendBtn.isEnabled = (textView.text.count > 0 && textView.text.count < self.textMaxLength)
        
        let constrainSize = CGSize(width:textView.frame.size.width, height:CGFloat(MAXFLOAT))
        let size:CGSize = textView.sizeThatFits(constrainSize)
        let textViewH = min(max(size.height, self.textMinHeight), self.textMaxHeight)
        self.textViewHeight.constant = textViewH
        
        if textView.text.count >= textMaxLength {
            self.textView.textColor = .red
            if !self.textIsMoreThanMax {
                self.textIsMoreThanMax = true
                MBProgressHUD.showError("The maximum number of characters is exceeded".localiz())
            }
        } else {
            self.textView.textColor = .black
            self.textIsMoreThanMax = false
        }
    }
}
