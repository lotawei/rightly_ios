//
//  RTNavgationViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
class RTNavgationViewController: UINavigationController,UINavigationControllerDelegate {
    var popDelegate:UIGestureRecognizerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationBar字体颜色设置
        self.navigationBar.barTintColor = UIColor.white
        //navigationBar字体颜色设置
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self
        customNavbarLine()
    }
    func customNavbarLine() {
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage.init(named: "shadowline")
    }
    //MARK: - UIGestureRecognizerDelegate代理
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //实现滑动返回的功能
        //清空滑动返回手势的代理就可以实现
        if viewController == self.viewControllers.first{
            self.interactivePopGestureRecognizer?.delegate = self.popDelegate
        } else {
            self.interactivePopGestureRecognizer?.delegate = nil;
        }
    }
    //拦截跳转事件
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.resetNextViewController(viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    func resetNextViewController(_ viewController: UIViewController) {
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "arrow_left_black")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(leftClick))
            //添加文字
    //        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(leftClick))
        }
    }
    
    //返回上一层控制器
    @objc func leftClick()  {
        popViewController(animated: true)
    }
    
    
    
}
//😭扩展处理下划线的
extension  UIViewController {
        
    ///消除导航栏下划线
       func clearNavigationBarLine() {
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           self.navigationController?.navigationBar.shadowImage = UIImage()
       }
    
    func setupNavigationBarLine() {
        self.navigationController?.navigationBar.shadowImage = UIImage.init(named: "shadowline")
    }
      
       ///消除标签栏下划线
       func clearTabBarLine() {
           let image_w = creatColorImage(.white)
           if #available(iOS 13.0, *) {
               let appearance = UITabBarAppearance()
               appearance.backgroundImage = image_w
               appearance.shadowImage = image_w
               self.tabBarController?.tabBar.standardAppearance = appearance
           } else {
               self.tabBarController?.tabBar.backgroundImage = image_w
               self.tabBarController?.tabBar.shadowImage = image_w
           }
       }
       ///用颜色创建一张图片
       func creatColorImage(_ color:UIColor,_ ARect:CGRect = CGRect.init(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
           let rect = ARect
           UIGraphicsBeginImageContext(rect.size)
           let context = UIGraphicsGetCurrentContext()
           context?.setFillColor(color.cgColor)
           context?.fill(rect)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return image!
       }
}
