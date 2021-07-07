//
//  TagSelectView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
//标签 视图
class TagSelectView: UIView{
    private var tagh:CGFloat = 24
    private var tagpadding:CGFloat = 10
    var  radius:CGFloat = 12
    var  fontsize:CGFloat = 14
    var  titleColor:UIColor = .init(hex: "B2B2B2")
    var  titleSelectedColor:UIColor = .white
    var  normalBackColor:UIColor = .black
    var  backColor:UIColor = UIColor.black.withAlphaComponent(0.7)
    var  selectedBackColor:UIColor = .black
    var  contensizeWidth:CGFloat = 0
    var  tagIndexBlock:((_ index:Int) -> Void)?
    var showRemoveButton:Bool = false
    
    private var  tags = [String]() {
        didSet {
            self.reloadTags()
        }
    }
    private var  imgtagsView = [UIButton]()
    private var  tagWs = [CGFloat]()
    lazy var  tagscrollerview:UIScrollView = {
        let  scrollerview =  UIScrollView.init(frame: .zero)
        scrollerview.backgroundColor = UIColor.clear
        scrollerview.showsHorizontalScrollIndicator = false
        scrollerview.showsVerticalScrollIndicator = false
        return scrollerview
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.tagscrollerview)
        self.tagscrollerview.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    fileprivate func reloadTags()  {
        self.tagWs = tags.map({ (str) -> CGFloat in
            let  wth = String.getNormalStrW(str: str, strFont: fontsize, h: 24)
            return wth > 24 ?  wth + 30:24
        })
        setUpSubView(tagh)
    }
    
    private func  setUpSubView(_ h:CGFloat){
        var prefix:CGFloat = 16
        for item in imgtagsView {
            item.removeFromSuperview()
        }
        var  i:CGFloat = 0
        for t in tags {
            let w = tagWs[Int(i)]
            let tagBtn = UIButton.init(type: .custom)
            tagBtn.setTitle(t + (showRemoveButton ? "x":""), for: .normal)
            tagBtn.tag = Int(i)
            tagBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontsize)
            tagBtn.setTitleColor(titleColor, for: .normal)
            tagBtn.backgroundColor = .white
            tagBtn.cornerRadius = h / 2.0
            tagBtn.borderWidth = 0.5
            tagBtn.borderColor = .init(hex: "B2B2B2")
            imgtagsView.append(tagBtn)
            tagBtn.frame = CGRect.init(x: prefix, y: 0, width: w, height: h)
            tagBtn.addTarget(self, action: #selector(IndexClickSender(_:)), for: .touchUpInside)
            self.tagscrollerview.addSubview(tagBtn)
            prefix = prefix +  w + tagpadding
            i = i + 1
        }
        self.tagscrollerview.contentSize = CGSize.init(width: prefix + tagpadding , height: 0)
        self.contensizeWidth = prefix
    }
    @objc func IndexClickSender(_ sender:UIButton){
        self.tagIndexBlock?(sender.tag)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func  setTags(_ tags:[String]){
        self.tags = tags
        
    }
    
}

extension TagSelectView {
    func loadGrayStyle()  {
        backColor = UIColor.init(hex: "EDEDED")
        titleColor = UIColor.init(hex: "A3A3A3")
    }
}
