//
//  MessageEditView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/10.
//

import UIKit
import KMPlaceholderTextView
import RxSwift
import ZLPhotoBrowser

typealias MessageEditBtnActionBlock = ()->Void
typealias MessageSendBtnActionBlock = ()->Void

class MessageEditView: UIView, NibLoadable {
    let disposeBag = DisposeBag()
    var messageEditBtnActionBlock: MessageEditBtnActionBlock?
    var messageSendBtnActionBlock: MessageSendBtnActionBlock?
    var textIsMoreThanMax:Bool = false
    let textMaxLength:Int = 5000
    let textMaxHeight:CGFloat = 149.0
    let textMinHeight:CGFloat = 42.0
    
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var sendBtn: UIButton!

    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var emojiBtn: UIButton!
    
    @IBOutlet weak var moreView: UIView!
    
    @IBOutlet weak var moreViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    var selectView:MediaResourceSelectView? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textView.placeholder = "type_something".localiz()
        self.textView.font = UIFont.systemFont(ofSize: 18)
        self.textView.placeholderFont = UIFont.systemFont(ofSize: 18)
        self.textView.delegate = self
        self.textView.textContainerInset = .init(top: 10, left: 8, bottom: 10, right: 8)
        self.textViewBottom.constant = 40 + safeBottomH
    }
    
    private func resetBtnSelected(_ btnTag:Int) {
        self.audioBtn.isSelected = self.audioBtn.tag == btnTag
        self.imageBtn.isSelected = self.imageBtn.tag == btnTag
        self.cameraBtn.isSelected = self.cameraBtn.tag == btnTag
        self.emojiBtn.isSelected = self.emojiBtn.tag == btnTag
        
        if btnTag >= 0 {
            self.textView.resignFirstResponder()
            self.messageEditBtnActionBlock?()
        }
    }
    
    private func clearMoreView() {
        for tempView in self.moreView.subviews.reversed() {
            tempView.removeFromSuperview()
        }
    }
    
    func showMoreView() {
        self.textView.text = ""
        self.textViewHeight.constant = self.textMinHeight
        self.moreView.isHidden = false
    }
    
    private func hiddenMoreView(_ hiddenMore:Bool) {
        self.clearMoreView()
        self.audioBtn.isSelected = false
        self.imageBtn.isSelected = false
        self.cameraBtn.isSelected = false
        self.emojiBtn.isSelected = false
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            if hiddenMore {
                self.textViewBottom.constant = 40 + safeBottomH
            }
            self.superview?.layoutIfNeeded()
        } completion: { (isOk) in
            self.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        self.messageSendBtnActionBlock?()
    }
    
    @IBAction func audioBtnAction(_ sender: UIButton) {
        self.clearMoreView()
        if !sender.isSelected {
            if self.textView.isFirstResponder {
                self.resetBtnSelected(sender.tag)
                self.showMoreView()
                self.setupAudioView()
            } else {
                self.showMoreView()
                self.setupAudioView()
                self.resetBtnSelected(sender.tag)
            }
        } else {
            self.resetBtnSelected(-1)
            self.hiddenMoreView(true)
        }
    }
    
    @IBAction func imageBtnAction(_ sender: UIButton) {
        self.clearMoreView()
        if !sender.isSelected {
            if self.textView.isFirstResponder {
                self.resetBtnSelected(sender.tag)
                self.showMoreView()
                self.setupImageView()
            } else {
                self.showMoreView()
                self.setupImageView()
                self.resetBtnSelected(sender.tag)
            }
        } else {
            self.resetBtnSelected(-1)
            self.hiddenMoreView(true)
        }
    }
    
    @IBAction func cameraBtnAction(_ sender: UIButton) {
        self.clearMoreView()
        if !sender.isSelected {
            self.resetBtnSelected(sender.tag)
            self.showMoreView()
        } else {
            self.resetBtnSelected(-1)
            self.hiddenMoreView(true)
        }
    }
    
    @IBAction func emojiBtnAction(_ sender: UIButton) {
        self.clearMoreView()
        if !sender.isSelected {
            if self.textView.isFirstResponder {
                self.resetBtnSelected(sender.tag)
                self.moreView.isHidden = false
                self.setupEmojiView()
            } else {
                self.moreView.isHidden = false
                self.setupEmojiView()
                self.resetBtnSelected(sender.tag)
            }
        } else {
            self.resetBtnSelected(-1)
            self.hiddenMoreView(true)
        }
    }
    
    private func setupAudioView() {
        self.moreViewHeight.constant = 260 + safeBottomH
        
        let recordView = MessageEditRecordView.loadNibView() ?? MessageEditRecordView()
        recordView.frame = CGRect(x: 0, y: 0, width: self.moreView.mj_w, height: 260)
        self.moreView.addSubview(recordView)
        recordView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(260)
        }
        
        self.sendBtn.isEnabled = false
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.textViewBottom.constant = 44 + 260 + safeBottomH
            self.superview?.layoutIfNeeded()
        } completion: { (isOk) in
            self.isUserInteractionEnabled = true
        }
    }
    
    private func setupImageView() {
        self.moreViewHeight.constant = 260 + safeBottomH
        self.selectView = MediaResourceSelectView.loadNibView() ?? MediaResourceSelectView()
        self.selectView?.mediaType = .unknown
        self.selectView?.frame = CGRect(x: 0, y: 0, width: self.moreView.mj_w, height: 260)
        self.moreView.addSubview(self.selectView!)
        self.selectView?.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(260)
        }
        
        let itemWH = (screenWidth - 17.0) / 3.0
        self.selectView?.layout.itemSize = CGSize(width: itemWH, height: itemWH)
        self.selectView?.requestMediaResource(type: .all)
        self.textView.text = ""
        
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.textViewBottom.constant = 44 + 260 + safeBottomH
            self.superview?.layoutIfNeeded()
        } completion: { (isOk) in
            self.isUserInteractionEnabled = true
        }
        
        self.sendBtn.isEnabled = false
        MediaResourceManager.shared.allselectedMedia.subscribe(onNext: { [weak self] value in
            guard let `self` = self  else {return }
            if self.imageBtn.isSelected {
                self.sendBtn.isEnabled = value.count > 0
            }
        }).disposed(by: self.selectView?.rx.disposeBag ?? self.rx.disposeBag)
    }
    
    private func setupEmojiView() {
        let emojiView = MessageEditSelectEmojiView.loadNibView() ?? MessageEditSelectEmojiView()
        emojiView.frame = CGRect(x: 0, y: 0, width: self.moreView.mj_w, height: 260)
        self.moreView.addSubview(emojiView)
        self.sendBtn.isEnabled = !(self.textView.attributedText.length <= 0)
        
        emojiView.emojiSelectBlock = { [weak self] (text, imagePath) in
            guard let emojiImage = UIImage(contentsOfFile: imagePath) else {
                return
            }
            
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.image = emojiImage
            attachment.emojiKey = text
            attachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
            let attachmentStr = NSMutableAttributedString(attachment: attachment)
            let attributedText:NSMutableAttributedString = NSMutableAttributedString(attributedString: self?.textView.attributedText ?? attachmentStr)
            attributedText.append(attachmentStr)
            attributedText.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)], range: NSRange(location: 0, length: attributedText.length))
            self?.textView.attributedText = attributedText
            self?.textView.font = UIFont.systemFont(ofSize: 18)
            guard let didChangeTextView = self?.textView else {
                return
            }
            
            self?.textViewDidChange(didChangeTextView)
        }
        
        self.moreViewHeight.constant = 260 + safeBottomH
        
        emojiView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(260)
        }
        
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.textViewBottom.constant = 44 + 260 + safeBottomH
            self.superview?.layoutIfNeeded()
        } completion: { (isOk) in
            self.isUserInteractionEnabled = true
        }
    }
    
    func resetSendedView() {
        self.textView.text = ""
        self.textViewHeight.constant = self.textMinHeight
        self.textIsMoreThanMax = false
        self.sendBtn.isEnabled = false
    }
    
    func resetInitView(_ clearText:Bool = true) {
        self.textView.resignFirstResponder()
        self.textViewHeight.constant = self.textMinHeight
        self.textIsMoreThanMax = false
        self.hiddenMoreView(true)
        if clearText {
            self.textView.text = ""
        }
        
        self.sendBtn.isEnabled = !(self.textView.attributedText.length <= 0)
    }
    
    func exportTextView() -> String {
        let resultAttrText:NSMutableAttributedString = NSMutableAttributedString.init(attributedString: self.textView.attributedText)
        
        self.textView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange.init(location: 0, length: textView.attributedText.length), options: .reverse) { (obj, range, point) in
            guard let tempAttachment = obj as? NSTextAttachment, let emojiKey = tempAttachment.emojiKey else {
                return
            }
            
            resultAttrText.replaceCharacters(in: range, with: emojiKey)
        }
        
        return resultAttrText.string
    }
}

extension MessageEditView : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let constrainSize = CGSize(width:textView.frame.size.width, height:CGFloat(MAXFLOAT))
        let size:CGSize = textView.sizeThatFits(constrainSize)
        let textViewH = min(max(size.height, self.textMinHeight), self.textMaxHeight)
        self.textViewHeight.constant = textViewH
        
        let willSendText = self.exportTextView()
        self.sendBtn.isEnabled = (willSendText.count > 0 && willSendText.count < textMaxLength)
        
        if willSendText.count >= textMaxLength {
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.messageSendBtnActionBlock?()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.resetBtnSelected(-1)
        self.hiddenMoreView(false)
        self.sendBtn.isEnabled = !(self.textView.attributedText.length <= 0)
        return true
    }
}



