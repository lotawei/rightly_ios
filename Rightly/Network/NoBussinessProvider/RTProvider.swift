//
//  HDProvider.swift
//  
//
//  Created by apple on 2020/3/15.
//  Copyright © 2020 lotawei. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import MBProgressHUD
import NVActivityIndicatorView
let networkPlugin = NetworkActivityPlugin { (type,_)  in
  switch type {
  case .began:
    DispatchQueue.main.async {
        NVActivityIndicatorView.showLoading()
    }
   
  case .ended:
    DispatchQueue.main.async {
        NVActivityIndicatorView.dismissLoading()
    }
  }
}

let Provider = CustomProvider<NetAPIManager>(requestClosure: requestClosure,plugins: [RTPublicHeaderPlugin(tokenClosure: {
      return UserManager.manager.currentUser?.accessToken
})])
class CustomProvider<T: TargetType>: MoyaProvider<T>{
    
    // 重写MoyaProvider的初始化方法，在初始化方法里做相应的判断
    @discardableResult
    open override func request(_ target: T,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               completion: @escaping Completion) -> Cancellable {
        
        return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: { response in
            switch response {
            case .success(let result):
            do {
                var  anycodares = result.data.dictionary
                if let dic = anycodares {
                    RTPrint(message: "response  \(String.convertDictionaryToJSONString(dic))")
                    if let code = dic["code"] as? Int {
                        if code == -4  {
                            DispatchQueue.main.async {
                                MBProgressHUD.showError("token invalid should relogin")
                                UserManager.manager.cleanUser()
                                AppDelegate.jumpLogin()
                            }
                        }
                        else{
                            completion(response)
                        }
                    }
                    
                }
                else{
                    completion(response)
                }
           
            } catch  {
                // 如果调用原来的接口返回401，token过期
                if result.statusCode == 401 {
                    DispatchQueue.main.async {
                        AppDelegate.jumpLogin()
                    }
                }
                else{
                    completion(response)
                }
            }

            case .failure(_):
                // 如果不是401，是请求超时啊，断网啊之类的错误，直接回调completion，不去刷新token
                completion(response)
            }
        })
    }
    
}




extension NVActivityIndicatorView {
    static func  showLoading(){
        guard let  window = keyWindow else {
            return
        }
        let  loadView = NVActivityIndicatorView.init(frame: .zero)
        window.addSubview(loadView)
        loadView.tag = -10001
        loadView.color = .black
        loadView.type = .lineSpinFadeLoader
        loadView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(30)
        }
        loadView.startAnimating()
    }
    
    static func dismissLoading(){
        guard let  window = keyWindow else {
            return
        }
        let  subvloadingview = window.viewWithTag(-10001) as? NVActivityIndicatorView
        subvloadingview?.stopAnimating()
        subvloadingview?.removeFromSuperview()
    }
}
