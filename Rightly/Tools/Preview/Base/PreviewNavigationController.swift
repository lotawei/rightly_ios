//
//  PreviewNavigationController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/28.
//

import UIKit

enum PreviewType {
    case video
    case image
}

class PreviewNavigationControllerPresentTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var presentViewCtrl:PreviewBaseViewController? = nil
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toNavCtrl = transitionContext.viewController(forKey: .to), let toViewCtrl = self.presentViewCtrl else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toNavCtrl.view)
        
        toViewCtrl.bgView.alpha = 0.0
        toViewCtrl.view.setNeedsLayout()
        toViewCtrl.view.layoutIfNeeded()
        
        let animateDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: animateDuration) {
            toViewCtrl.bgView.alpha = 1
            toViewCtrl.contentView.snp.updateConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            toViewCtrl.view.setNeedsLayout()
            toViewCtrl.view.layoutIfNeeded()
        } completion: { (ok) in
            transitionContext.completeTransition(true)
        }
    }
}

class PreviewNavigationControllerDismissTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var presentViewCtrl:PreviewBaseViewController? = nil
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewCtrl = self.presentViewCtrl else {
            transitionContext.completeTransition(false)
            return
        }
        
        let animateDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: animateDuration) {
            toViewCtrl.bgView.alpha = 0
            toViewCtrl.contentView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(screenWidth / 2.0)
                make.height.equalTo(screenHeight / 2.0)
            }
            
            toViewCtrl.view.setNeedsLayout()
            toViewCtrl.view.layoutIfNeeded()
        } completion: { (ok) in
            if toViewCtrl.view.superview != nil {
                toViewCtrl.view.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
    }
}

//MARK: - 控制器
class PreviewNavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    var previewType:PreviewType = .image
    var rootViewCtrl:PreviewBaseViewController
    let presentTransitionAnimation = PreviewNavigationControllerPresentTransitionAnimation.init()
    let dismissTransitionAnimation = PreviewNavigationControllerDismissTransitionAnimation.init()
    
    init(_ type:PreviewType) {
        self.previewType = type
        if type == .image {
            self.rootViewCtrl = PreviewImageViewController.init()
        } else {
            self.rootViewCtrl = PreviewVideoViewController.init()
        }
        
        super.init(rootViewController: self.rootViewCtrl)
        self.presentTransitionAnimation.presentViewCtrl = self.rootViewCtrl
        self.dismissTransitionAnimation.presentViewCtrl = self.rootViewCtrl
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissTransitionAnimation
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.presentTransitionAnimation
    }
}

