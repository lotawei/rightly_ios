//
//  UserNickNameEditorViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//
import MBProgressHUD
import Foundation
import KMPlaceholderTextView
class UserNickNameEditorViewController:BaseViewController {
    lazy var saveBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(saveCommit), for: .touchUpInside)
        button.setTitleColor(UIColor.init(hex: "24D3D0"), for: .normal)
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 20)
        button.setTitle("Save".localiz(), for: .normal)
        return button
    }()
    var maxcount = 16
    @IBOutlet weak var txtcontent: KMPlaceholderTextView!
    
    @IBOutlet weak var lblbytes: UILabel!
    @IBOutlet weak var editorimg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NickName".localiz()
        self.txtcontent.placeholder = "nickname...".localiz()
//        editorimg.image = UIImage.init(named: "editor_black")?.withTintColor(.green, renderingMode: .)
        let  rightbtn = UIBarButtonItem.init(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = rightbtn
        guard let currentNickname = UserManager.manager.currentUser?.additionalInfo?.nickname else {
            return
        }
        self.txtcontent.text = currentNickname
        self.lblbytes.text  = "\(currentNickname.count) " + "bytes".localiz()
        self.txtcontent.rx.text.subscribe(onNext: { [weak self] (result) in
            guard let `self` = self  else {return }
            self.lblbytes.text = "\(result?.count ?? 0) " + "bytes".localiz()
             
        }).disposed(by: self.rx.disposeBag)
        txtcontent.delegate = self
    }
    @objc func  saveCommit(){
        if self.txtcontent.text.isEmpty {
            
            MBProgressHUD.showError("Please Input NickName".localiz())
            return
        }
        let userproVider = UserProVider.init()
        userproVider.editUser(nickname: self.txtcontent.text,self.rx.disposeBag)
            .subscribe(onNext: { [weak self] (res) in
                guard let `self` = self  else {return }
                MBProgressHUD.showSuccess("Update Success".localiz())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.navigationController?.popViewController(animated: true)
                }
//                switch res {
//                case .success(let info):
//                    MBProgressHUD.showSuccess("Update Success".localiz())
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                    break
//                case .failed(let err):
//                    MBProgressHUD.showError("Update Failed".localiz())
//                }
                
            },onError: { (err) in
                MBProgressHUD.showError("Update Failed".localiz())
            }).disposed(by: self.rx.disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
        
    
    
}

extension  UserNickNameEditorViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          if text == "\n"{
              // 点击完成
              textView.resignFirstResponder()
              return false
          }
        if textView.text.count >= maxcount,text != "" {
              return false
          }
          return true
      }
      func textViewDidChange(_ textView: UITextView) {
         var currentCount = 0
          if textView.markedTextRange == nil || textView.markedTextRange?.isEmpty == true {
              currentCount = textView.text.count
              if currentCount <= maxcount {
                
              }else{
                  textView.text = String(textView.text.prefix(maxcount))
                    
              }
          }
      }
}
