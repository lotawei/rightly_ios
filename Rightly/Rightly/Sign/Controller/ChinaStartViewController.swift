//
//  ChinaStartViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/13.
//

import UIKit
import AuthenticationServices
import Bugly
import RxSwift

class ChinaStartViewController: UIViewController {
    let signProvider = SignProvider()
    var  isSendVertify:Bool = false
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var otherLoginView: UIView!
    @IBOutlet weak var lblotherlogintip: UILabel!
    @IBOutlet weak var lblsigntip: UILabel!
    @IBOutlet weak var lblservice: UIButton!
    @IBOutlet weak var lblprivacy: UIButton!
    
    @IBOutlet weak var areaLabel: UILabel!
    
    @IBOutlet weak var heatLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLogoWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heatLogoWidth.constant = (screenHeight < 700) ? 72 : 108
        self.titleLogoWidth.constant = (screenHeight < 700) ? 145 : 218
        self.fd_prefersNavigationBarHidden = true
        self.phoneTextField.attributedPlaceholder = NSAttributedString.init(string: "Input your phone".localiz(), attributes: [NSAttributedString.Key.foregroundColor : UIColor(white: 1, alpha: 0.67), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)])
        self.verificationTextField.attributedPlaceholder = NSAttributedString.init(string: "Input your verify code".localiz(), attributes: [NSAttributedString.Key.foregroundColor : UIColor(white: 1, alpha: 0.67), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)])
        let sendNorBgImage = UIImage.createSolidImage(color: .white, size: CGSize(width: 68, height: 48))
        let sendDisBgImage = UIImage.createSolidImage(color: .init(white: 1, alpha: 0.4), size: CGSize(width: 68, height: 48))
        self.sendBtn.setBackgroundImage(sendNorBgImage, for: .normal)
        self.sendBtn.setBackgroundImage(sendDisBgImage, for: .selected)
        self.sendBtn.setBackgroundImage(sendDisBgImage, for: .disabled)
        let loginNorBgImage = UIImage.createSolidImage(color: .white, size: CGSize(width: 68, height: 48))
        let loginDisBgImage = UIImage.createSolidImage(color: .init(white: 1, alpha: 0.6), size: CGSize(width: 68, height: 48))
        self.loginBtn.setBackgroundImage(loginNorBgImage, for: .normal)
        self.loginBtn.setBackgroundImage(loginDisBgImage, for: .disabled)
        self.sendBtn.setTitle("Get Verify".localiz(), for: .normal)
        self.loginBtn.setTitle("Login".localiz(), for: .normal)
        self.lblotherlogintip.text = "── Other Login Channel ──".localiz()
        self.lblsigntip.text =  "By signing up you agree to the ".localiz()
//        lblservice.setTitle("Terms of Service".localiz(), for: .normal)
        let attribute =  [NSAttributedString.Key.foregroundColor : UIColor.white,NSAttributedString.Key.underlineStyle:1] as [NSAttributedString.Key : Any]
        self.lblservice.setAttributedTitle(NSAttributedString.init(string: "Terms of Service".localiz(), attributes:attribute), for: .normal)
        self.lblprivacy.setAttributedTitle(NSAttributedString.init(string: "Privacy Policy".localiz(), attributes:attribute), for: .normal)
        self.sendBtn.setTitle("Get Verify".localiz(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendBtn.isUserInteractionEnabled = true
    }
    
    func checkBtnState() {
        if !self.sendBtn.isSelected {
            self.sendBtn.isEnabled = (self.phoneTextField.text!.count >= 6 && self.phoneTextField.text!.count <= 11)
            var  title = ""
            if isSendVertify {
                title = "Get Verify Again".localiz()
            } else{
                title = "Get Verify".localiz()
            }
            self.sendBtn.setTitle(title, for: .normal)
        }
        
        self.loginBtn.isEnabled = (self.phoneTextField.text!.count >= 6 && self.phoneTextField.text!.count <= 11 && self.verificationTextField.text!.count == 6)
    }

    func startCountdownTime() {
        SignCountdownManager.shared().dispatchTimer(timeInterval: 1, repeatCount: 60) { (timer, count) in
            self.sendBtn.setTitle("\(count)s", for: .selected)
            self.sendBtn.isEnabled = count > 0
            self.sendBtn.isSelected = count > 0
            self.sendBtn.isUserInteractionEnabled = count <= 0
            if count <= 0 {
                self.checkBtnState()
            }
        }
    }
    
    @IBAction func areaBtnAction(_ sender: UIButton) {
        let viewCtrl = SelectAreaCodeViewController.init { areaCode in
            self.areaLabel.text = areaCode
        }
        
        let navCtrl = RTNavgationViewController.init(rootViewController: viewCtrl)
        self.present(navCtrl, animated: true, completion: nil)
    }
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        self.phoneTextField.resignFirstResponder()
        self.verificationTextField.resignFirstResponder()
        let phone = self.phoneTextField.text!
        
        MBProgressHUD.showStatusInfo("Login...".localiz())
        self.signProvider.sendTestSMSCode(self.areaLabel.text ?? "", phone, 1, self.rx.disposeBag)
            .subscribe(onNext: {(result) in
                debugPrint("验证码发送成功")
                MBProgressHUD.dismiss()
                self.isSendVertify = true
                let code = result.data as? Int ?? 0
                MBProgressHUD.showSuccess("Verify".localiz() + ": \(code)")
                self.startCountdownTime()
                self.verificationTextField.text = String(code)
                self.checkBtnState()
            }, onError: { (error) in
                debugPrint("Failed to send a verification code".localiz())
                MBProgressHUD.showError("Failed to send a verification code".localiz())
                Bugly.reportError(NSError.init(domain: "sendTestSMSCode:\(error.localizedDescription)", code: -1, userInfo: nil))
            }).disposed(by: self.rx.disposeBag)
        
//        if isTestApp {
//            self.signProvider.sendTestSMSCode(self.areaLabel.text ?? "", phone, 1, self.rx.disposeBag)
//                .subscribe(onNext: {(result) in
//                    debugPrint("验证码发送成功")
//                    self.isSendVertify = true
//                    let code = result.data as? Int ?? 0
//                    MBProgressHUD.showSuccess("Verify".localiz() + ": \(code)")
//                    self.startCountdownTime()
//                    self.verificationTextField.text = String(code)
//                    self.checkBtnState()
//                }, onError: { (error) in
//                    debugPrint("验证码发送失败")
//                    Bugly.reportError(NSError.init(domain: "sendTestSMSCode:\(error.localizedDescription)", code: -1, userInfo: nil))
//                }).disposed(by: self.rx.disposeBag)
//        } else {
//            self.signProvider.sendSMSCode(self.areaLabel.text ?? "", phone, 1, self.rx.disposeBag)
//                .subscribe(onNext: {(result) in
//                    debugPrint("验证码发送成功")
//                    self.isSendVertify = true
//                    let code = result.data as? Int ?? 0
//                    MBProgressHUD.showSuccess("Verify".localiz() + ": \(code)")
//                    self.startCountdownTime()
//                    self.verificationTextField.text = String(code)
//                    self.checkBtnState()
//                }, onError: { (error) in
//                    debugPrint("验证码发送失败")
//                    Bugly.reportError(NSError.init(domain: "sendTestSMSCode:\(error.localizedDescription)", code: -1, userInfo: nil))
//                }).disposed(by: self.rx.disposeBag)
//        }
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        self.phoneTextField.resignFirstResponder()
        self.verificationTextField.resignFirstResponder()
        
        let phone = self.phoneTextField.text!
        let verCode = self.verificationTextField.text!
        
        MBProgressHUD.showStatusInfo("Login...".localiz())
        self.signProvider.userPhoneLogin(self.areaLabel.text ?? "", phone, verCode, self.rx.disposeBag)
            .subscribe(onNext: { (result) in
                debugPrint("手机号登录成功")
                MBProgressHUD.dismiss()
                var userInfo:UserInfo? = result.dicData?.kj.model(UserInfo.self)
                UserManager.manager.saveUserInfo(userInfo)
                AppDelegate.reloadRootVC()
            }, onError: { (error) in
                MBProgressHUD.dismiss()
                self.toastTip("Verify Code Error".localiz())
                Bugly.reportError(NSError.init(domain: "userPhoneLogin:\(error.localizedDescription)", code: -1, userInfo: nil))
                debugPrint("手机号登录失败")
            }).disposed(by: self.rx.disposeBag)
    }
    
    @IBAction func termsBtnTUI(_ sender: UIButton) {
        GlobalRouter.shared.jumpByUrl(url: "http://cc.channelthree.tv/privacy.html")
    }
    
    @IBAction func privacyBtnTUI(_ sender: UIButton) {
        GlobalRouter.shared.jumpByUrl(url: "http://cc.channelthree.tv/privacy.html")
    }
    
    @IBAction func phoneTextChanged(_ sender: UITextField) {
        self.checkBtnState()
    }
    
    @IBAction func verificationTextChanged(_ sender: UITextField) {
        self.checkBtnState()
    }
    
    @IBAction func mockBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "提示", message: "请输入自定义mock token", preferredStyle: .alert)
        alert.addTextField{(usernameText) ->Void in
            usernameText.placeholder = "自定义token"
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let login = UIAlertAction(title: "Create", style: .default, handler: {
            ACTION in
            guard let  text1 = alert.textFields?.first?.text else {return }
            self.thirdpartLogin(.mock, token: text1)
        })
        
        alert.addAction(cancel)
        alert.addAction(login)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func appleBtnAction(_ sender: UIButton) {
        if #available(iOS 13.0.0, *) {
            let appleIDProvider:ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
            let appleIDRequest:ASAuthorizationAppleIDRequest = appleIDProvider.createRequest()
            appleIDRequest.requestedScopes = [.fullName, .email]
            
            let authorizationController:ASAuthorizationController = ASAuthorizationController.init(authorizationRequests: [appleIDRequest])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            MBProgressHUD.showError("The system version is not available for Apple login".localiz())
        }
    }
    
    /// 第三方登录
    /// - Parameters:
    ///   - thirdPartType: 登录渠道
    ///   - token: token
     func thirdpartLogin(_ thirdPartType:ThirdPartAuthType, token:String) {
        UserProVider.init().thirdPartLogin(thirdPartType.rawValue, token: token, self.rx.disposeBag)
            .subscribe(onNext:{ (result) in
                debugPrint(result)
                if let dicData = result.data as? [String:Any] {
                    let modeInfo = dicData.kj.model(UserInfo.self)
                    UserManager.manager.saveUserInfo(modeInfo)
                }
            }).disposed(by: self.rx.disposeBag)
    }
}

//MARK: - apple登录
extension  ChinaStartViewController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // MARK: - ASAuthorizationControllerDelegate & ASAuthorizationControllerPresentationContextProviding
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if authorization.credential.isKind(of: ASAuthorizationAppleIDCredential.self) {
            let appleIDCredential:ASAuthorizationAppleIDCredential = authorization.credential as! ASAuthorizationAppleIDCredential
            let identityTokenData:Data = appleIDCredential.identityToken!
            let normalString:String = String.init(data: identityTokenData, encoding: .utf8)!
            self.thirdpartLogin(.apple, token: normalString)
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Bugly.reportError(error)
    }
}





