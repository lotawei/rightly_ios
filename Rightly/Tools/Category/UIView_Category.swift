//
//  UIView_Category.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/1.
//

import Foundation
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = newValue
         
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
   
}

extension UIView {
    func snapViewImage(_ targetRect:CGRect? = nil) -> UIImage {
        var  targerec:CGRect
        if targetRect != nil {
            targerec = targetRect!
        }else{
            targerec = bounds
        }
        let renderer = UIGraphicsImageRenderer(bounds:targerec)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}




extension  UIView {
    
    /// 业务耦合的
    /// - Parameters:
    ///   - selectDate:
    ///   - resultBlock: 
    func  showDatePicker(selectDate:Date?,resultBlock:@escaping(_ date:Date)->Void){
        let pickerView = BRDatePickerView.init()
        pickerView.pickerMode = .YMD
        pickerView.minDate = Date.init(timeIntervalSince1970: 0)
        pickerView.maxDate = Date.init(timeIntervalSinceNow: 0)
        pickerView.selectDate = selectDate ?? NSDate.br_setYear(2018)
        pickerView.isAutoSelect = false
        pickerView.keyView = self
        pickerView.resultBlock = {
            [weak self] (resultdate,selectValue) in
           guard let date = resultdate else {return }
            var   fixDate:NSDate =  date as NSDate
            let zone = NSTimeZone.system
            let second = zone.secondsFromGMT()
            fixDate = fixDate.addingTimeInterval(TimeInterval(second))
            resultBlock(fixDate as Date)
        }
        let style = BRPickerStyle.init()
        style.pickerColor = UIColor.white
        style.selectRowTextColor = themeBarColor
        style.doneTextColor  = UIColor.black
        style.cancelBtnTitle = ""
        style.doneBtnTitle = "Done".localiz()
        style.pickerTextFont = UIFont.systemFont(ofSize: 16)
        style.selectRowTextFont = UIFont.systemFont(ofSize: 21)
        style.pickerTextColor =  UIColor.gray
        style.hiddenTitleLine = true
        style.separatorColor = .white
        style.language = LanguageManager.shared.currentLanguage.rawValue
        pickerView.pickerStyle = style
        pickerView.show()
        pickerView.timeZone = NSTimeZone.system
    }
}
