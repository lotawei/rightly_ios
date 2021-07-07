//
//  GreetInfoStartSendView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/29.
//

import UIKit

class GreetInfoStartSendView: UIView, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = "say_hello_to_him".localiz()
        self.sendBtn.setTitle("Send_btn".localiz(), for: .normal)
        let norBgImage = UIImage.createSolidImage(color: .init(hex: "24D3D0"), size: CGSize(width: 215.0, height: 48.0))
        let disBgImage = UIImage.createSolidImage(color: .init(hex: "24D3D0", alpha: 0.3), size: CGSize(width: 215.0, height: 48.0))
        self.sendBtn.setBackgroundImage(norBgImage, for: .normal)
        self.sendBtn.setBackgroundImage(disBgImage, for: .disabled)
        self.textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
    }
    
    func hiddenFromSupper() {
        self.textView.resignFirstResponder()
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
    
    @IBAction func bgBtnTUI(_ sender: UIButton) {
        self.hiddenFromSupper()
    }
}

extension GreetInfoStartSendView:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.sendBtn.isEnabled = textView.text.count > 0
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension GreetInfoStartSendView {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard   let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return 
        }
        UIView.animate(withDuration: 0.3) {
            self.centerY.constant = -keyboardHeight / 2.0
            self.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.centerY.constant = 0
            self.layoutIfNeeded()
        } completion: { (isOk) in
        }
    }
}

