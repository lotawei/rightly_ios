//
//  UIView+GradientLayer.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
extension UIView {
    
    public func addGradientLayer(
        start: CGPoint = CGPoint(x: 0, y: 0), //渐变起点
        end: CGPoint = CGPoint(x: 1, y: 1), //渐变终点
        frame: CGRect,
        colors: [CGColor]
    ) {
        layoutIfNeeded()
        removeGradientLayer()
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public func removeGradientLayer() {
        guard let layers = self.layer.sublayers else { return }
        for layer in layers {
            if layer.isKind(of: CAGradientLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    //设置部分圆角
    func setRoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.frame = self.bounds
        self.layer.mask = mask
   }
    
    
    func SetBorderWithView(top:Bool,left:Bool,bottom:Bool,right:Bool,width:CGFloat,color:UIColor)
    
    {
        
        if top
        
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
            
            layer.backgroundColor = color.cgColor
            
            self.layer.addSublayer(layer)
            
        }
        
        if left
        
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
            
            layer.backgroundColor = color.cgColor
            
            self.layer.addSublayer(layer)
            
        }
        
        if bottom
        
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: self.frame.size.height - width, width: width, height: width)
            
            layer.backgroundColor = color.cgColor
            
            self.layer.addSublayer(layer)
            
        }
        
        if right
        
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
            
            layer.backgroundColor = color.cgColor
            
            self.layer.addSublayer(layer)
            
        }
        
    }
    
}
extension UIView {
    enum ShadowType: Int {
        case all = 0 ///四周
        case top  = 1 ///上方
        case left = 2///左边
        case right = 3///右边
        case bottom = 4///下方
    }
    ///默认设置：黑色阴影
    func shadow(_ type: ShadowType,radius:CGFloat  = 3) {
        shadow(type: type, color: .gray, opactiy: 0.1, shadowSize: 10,radius: radius)
    }
    ///常规设置
    func shadow(type: ShadowType, color: UIColor,  opactiy: Float, shadowSize: CGFloat,radius:CGFloat = 3) -> Void {
        layer.masksToBounds = false;//必须要等于NO否则会把阴影切割隐藏掉
        layer.shadowColor = color.cgColor;// 阴影颜色
        layer.shadowOpacity = opactiy;// 阴影透明度，默认0
        layer.shadowOffset = .zero;//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        layer.shadowRadius = radius  //阴影半径，默认3
        var shadowRect: CGRect?
        switch type {
        case .all:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .top:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .bottom:
            shadowRect = CGRect.init(x: -shadowSize, y: bounds.size.height - shadowSize, width: bounds.size.width + 2 * shadowSize, height: 2 * shadowSize)
        case .left:
            shadowRect = CGRect.init(x: -shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        case .right:
            shadowRect = CGRect.init(x: bounds.size.width - shadowSize, y: -shadowSize, width: 2 * shadowSize, height: bounds.size.height + 2 * shadowSize)
        }
        layer.shadowPath = UIBezierPath.init(rect: shadowRect!).cgPath
    }
    
    
}

@IBDesignable
class StackView: UIStackView {
    @IBInspectable private var corner: CGFloat = 0
    
   @IBInspectable private var color: UIColor?
    override var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            self.setNeedsLayout()
        }
    }
    override var cornerRadius: CGFloat{
        get { return corner }
        set {
            corner = newValue
            self.setNeedsLayout()
        }
    }
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(rect: self.bounds).cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
        backgroundLayer.cornerRadius = self.corner
    }
}

