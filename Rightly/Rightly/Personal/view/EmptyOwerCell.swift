//
//  EmptyOwerCell.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/14.
//

import Foundation
import Foundation
import Reusable
import RxSwift
import RxCocoa
import BonMot
class EmptyOwerCell: UITableViewCell,NibReusable,NibLoadable {
    
    @IBOutlet weak var displaylbl: UILabel!
    override  func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        //        let blacattr = [NSAttributedString.Key.foregroundColor : UIColor.black]
        //        var  newstr = NSMutableAttributedString.init(string: "No content.\nfinish".localiz(), attributes: blacattr)
        //        let lightlstr  = [NSAttributedString.Key.foregroundColor : UIColor.init(hex: "27D3CF"),NSAttributedString.Key.underlineStyle:1] as [NSAttributedString.Key : Any]
        //        var  ligstr = NSAttributedString.init(string: "  chat up task ".localiz(), attributes: lightlstr)
        //        newstr.append(ligstr)
        //        let endstr =  NSAttributedString.init(string: "Let friends know you better by".localiz(), attributes: blacattr)
        //        newstr.append(endstr)
        //        self.displaylbl.attributedText = newstr
        //
        //妈的富文本在这里 有时能生效 有时不行放在layoutsubView 始终没问题 猜测是xib  原来是个uiview的 改造成uitableivewcell 的 时候有问题
    }
    @IBAction func spaceActionClick(_ sender: Any) {
        let  controllers =    self.getCurrentViewController()?.tabBarController?.viewControllers
        if (controllers?.count ?? 0) > 0 {
            self.getCurrentViewController()?.tabBarController?.selectedIndex = 0
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let style = StringStyle(
            .font(UIFont.systemFont(ofSize: 17)),
            .paragraphSpacingAfter(12.0),
            .adapt(.body),
            .alignment(.center),
            .xmlRules([
                .style("high-pitch", StringStyle(.color(UIColor.black))),
                .style("low-pitch", StringStyle(
                        .color(UIColor.init(hex: "27D3CF")),
                        .underline(.single, UIColor.init(hex: "27D3CF")))),
            ]))
        let  newstr  = "<high-pitch>No content.\n finish  </high-pitch><low-pitch>chat up task </low-pitch><high-pitch>Let friends know you better by</high-pitch>".localiz().styled(with: style)
        self.displaylbl.attributedText = newstr.adapted(to: traitCollection)
             
    }
    
}

