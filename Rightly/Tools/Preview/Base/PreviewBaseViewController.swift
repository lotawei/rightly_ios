//
//  PreviewBaseViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/28.
//

import UIKit
import RxSwift
import RxCocoa

class PreviewBaseViewController: UIViewController {
    var originalFrame:CGRect? = nil
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let resultGR = UIPanGestureRecognizer.init(target: self, action: #selector(panGRAction(_:)))
        resultGR.maximumNumberOfTouches = 1
        return resultGR
    }()
    
    lazy var bgView: UIView = {
        let resultView = UIView.init()
        resultView.backgroundColor = .black
        return resultView
    }()
    
    lazy var contentView: UIView = {
        let resultView = UIView.init()
        resultView.backgroundColor = .clear
        return resultView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBaseView()
    }
    
    func setupBaseView() {
        self.navigationController?.navigationBar.isHidden = true
        self.view.tag = 101
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        self.view.addSubview(self.bgView)
        self.view.addSubview(self.contentView)
        
        self.bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenHeight)
        }
    }
    
    enum PreviewPanState {
        case normal
        case effective
        case invalid
    }
    
    var panState:BehaviorRelay<PreviewPanState> = BehaviorRelay<PreviewPanState>(value: .normal)
    var panStartPoint:CGPoint? = nil
    let maxDistance:CGFloat = 200.0
    let disDistance:CGFloat = 150.0
    @objc func panGRAction(_ gr:UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            self.panState.accept(.normal)
            self.panStartPoint = gr.location(in: self.view)
        case .changed:
            if self.panState.value == .invalid {
                return
            }
            
            let currPoint = gr.location(in: self.view)
            
            if let startPoint = self.panStartPoint {
                let distance = hypot(startPoint.x - currPoint.x, startPoint.y - currPoint.y)
                if (self.panState.value == .normal) && (distance >= 10) {
                    if (Double(currPoint.y - startPoint.y) > fabs(Double(currPoint.x - startPoint.x))) {
                        self.panState.accept(.effective)
                    } else {
                        self.panState.accept(.invalid)
                        self.panGestureRecognizer.isEnabled = false
                    }
                }
                
                if self.panState.value == .effective {
                    let panScale = min(distance / self.maxDistance, 1.0)
                    self.bgView.alpha = 1.0 - panScale * 0.7
                    let changeX = currPoint.x - startPoint.x
                    let changeY = currPoint.y - startPoint.y
                    self.contentView.transform = CGAffineTransform.init(scaleX: (1.0 - panScale * 0.5), y: (1.0 - panScale * 0.5))
                    self.contentView.snp.updateConstraints { make in
                        make.centerX.equalToSuperview().offset(changeX)
                        make.centerY.equalToSuperview().offset(changeY)
                    }
                    
                    self.contentView.setNeedsLayout()
                    self.contentView.layoutIfNeeded()
                }
            }
        case .ended:
            let currPoint = gr.location(in: self.view)
            if let startPoint = self.panStartPoint {
                let distance = hypot(startPoint.x - currPoint.x, startPoint.y - currPoint.y)
                if self.panState.value == .effective && distance >= self.disDistance {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
            }
            self.recoveryView()
        default:
            self.recoveryView()
            self.panStartPoint = nil
        }
    }
    
    func recoveryView() {
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = 1
            self.contentView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.contentView.snp.updateConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } completion: { ok in
            self.view.isUserInteractionEnabled = true
            self.panStartPoint = nil
            self.panGestureRecognizer.isEnabled = true
        }
    }
}

