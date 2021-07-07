//
//  UserGenderSelectViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources
class UserGenderSelectViewController:BaseViewController {
    
    @IBOutlet weak var btnmale: UIButton!
    @IBOutlet weak var btnfemale: UIButton!
    @IBOutlet weak var lbltip: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lbltip.text = lbltip.text?.localiz()
        btnmale.setTitle(btnmale.title(for: .normal)?.localiz(), for: .normal)
        btnfemale.setTitle(btnfemale.title(for: .normal)?.localiz(), for: .normal)
        btnmale.setTitle(btnmale.title(for: .selected)?.localiz(), for: .selected)
        btnfemale.setTitle(btnfemale.title(for: .selected)?.localiz(), for: .selected)
        self.title = "Gender".localiz()
        guard let gender = UserManager.manager.currentUser?.additionalInfo?.gender else {
            return
        }
        if gender == .male {
            btnmale.isSelected = true
            btnfemale.isSelected = false
        }
        if  gender == .female {
            btnfemale.isSelected = true
            btnmale.isSelected = false
        }
        
    }
    
}


