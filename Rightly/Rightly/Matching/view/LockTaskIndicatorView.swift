//
//  LockTaskIndicatorView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/5.
//

import Foundation
import SnapKit
class LockTaskIndicatorView: UIView,NibLoadable {
    fileprivate var pagepadding:CGFloat =  10
    fileprivate var  xleft:CGFloat = 22
    fileprivate var  pagecontrolW:CGFloat = 16
    fileprivate var  pagecontrolH:CGFloat = 16
    lazy var  horizaltalscrollerView:UIScrollView = {
        let scrollerview = UIScrollView.init()
        scrollerview.showsVerticalScrollIndicator = false
        scrollerview.showsHorizontalScrollIndicator = false
        scrollerview.isScrollEnabled = false
        return scrollerview
    }()
    fileprivate  var  stackWconstriat:Constraint?=nil
    lazy var  stackView:UIStackView = {
        let stackview = UIStackView.init()
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.distribution = .equalSpacing
        stackview.spacing = pagepadding
        return  stackview
    }()
    var  selectTypes:[PageControlResourceImg] = [PageControlResourceImg]() {
        didSet {
            
            updatePageType()
        }
    }
    var  pageviews:[PageControlView] =  [PageControlView]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.horizaltalscrollerView)
        self.horizaltalscrollerView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalToSuperview()
        }
        self.horizaltalscrollerView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.height.equalTo(pagecontrolH)
            maker.centerX.equalToSuperview()
            self.stackWconstriat = maker.width.equalTo(screenWidth).constraint
        }
        setUpSubviews()
    }
    func setUpSubviews()  {
        for pagecontrolView  in pageviews {
            pagecontrolView.removeFromSuperview()
        }
        var  index:Int = 0
        let  taskCount = self.selectTypes.count
        for item  in self.selectTypes {
            let frame = CGRect.init(x:xleft + CGFloat( index  )*(pagecontrolW + pagepadding ), y: 20, width:pagecontrolW , height: pagecontrolH)
            let  pagecontrolView = PageControlView.init(frame: frame)
            pagecontrolView.selectType = item
            index = index + 1
            self.stackView.addArrangedSubview(pagecontrolView)
            pagecontrolView.snp.makeConstraints { (make) in
                make.width.equalTo(pagecontrolW)
            }
            pageviews.append(pagecontrolView)
        }
        
        let  scrollerWidth = (xleft * 2) + CGFloat(taskCount-1)*pagepadding + CGFloat(taskCount)*pagecontrolW
        self.horizaltalscrollerView.contentSize = CGSize.init(width:scrollerWidth, height: 0)
        self.stackWconstriat?.update(offset:   CGFloat(taskCount-1)*pagepadding + CGFloat(taskCount)*pagecontrolW)
        
    }
    func updatePageType(){
        if self.pageviews.count > 0  {
            var i = 0
            for pageview in pageviews {
                pageview.selectType =  self.selectTypes[i]
                i += 1
            }
        }else{
            setUpSubviews()
        }
      
    }
}
