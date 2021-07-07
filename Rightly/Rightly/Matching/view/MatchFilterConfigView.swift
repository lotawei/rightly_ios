//
//  MatchFilterConfigView.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/22.
//

import Foundation
import UIKit
class MatchFilterConfigView:UIView, NibLoadable ,VMBinding {
    var  applyAction:(() -> Void)?=nil
    @IBOutlet weak var lblgender: UILabel!
    @IBOutlet weak var genderTip: UILabel!
    @IBOutlet weak var btnreset: UIButton!
    @IBOutlet weak var lblfilter: UILabel!
    @IBOutlet weak var lbltasktype: UILabel!
    var viewModel: MatchTaskFilterViewModel = MatchTaskFilterViewModel.init()
    @IBOutlet weak var btndone: UIButton!
    @IBOutlet var genderCollectionBtn: [UIButton]!
    @IBOutlet var taskTypeCollectionBtn: [UIButton]!
    override  func awakeFromNib() {
        super.awakeFromNib()
        for btn  in genderCollectionBtn {
            btn.layoutButton(style: .Left, imageTitleSpace: 8)
            btn.setTitle(btn.title(for: .normal)?.localiz(), for: .normal)
            btn.setTitle(btn.title(for: .selected)?.localiz(), for: .selected)
            btn.setTitleColor(UIColor.gray, for: .normal)
            btn.setTitleColor(UIColor.black, for: .selected)
        }
        for btn  in taskTypeCollectionBtn {
            btn.layoutButton(style: .Left, imageTitleSpace: 8)
            btn.setTitle(btn.title(for: .normal)?.localiz(), for: .normal)
            btn.setTitle(btn.title(for: .selected)?.localiz(), for: .selected)
            btn.setTitleColor(UIColor.gray, for: .normal)
            btn.setTitleColor(UIColor.black, for: .selected)
        }
        lblgender.text = "Gender".localiz()
        genderTip.text = "\("Male".localiz()),\("Female".localiz())"
        btnreset.setTitle("Reset".localiz(), for: .normal)
        lblfilter.text = "Filter".localiz()
        lbltasktype.text = "Task Type".localiz()
        
        self.btndone.setTitle("Done".localiz(), for: .normal)
        self.btndone.setTitle("Done".localiz(), for: .selected)
        bindViewModel(to: self.viewModel)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    @IBAction func resetaction(_ sender: Any) {
        self.viewModel.input.resetAction.onNext({}())
    }
    func bindViewModel(to model: MatchTaskFilterViewModel) {
        
        for btn in self.genderCollectionBtn {
            self.viewModel.output.filtermodel.map { (model) -> Bool in
                return    model.gender.contains(Gender.init(rawValue: btn.tag + 1) ?? .male)
            }.bind(to: btn.rx.isSelected)
            .disposed(by: self.rx.disposeBag)
            
        }
        for btn in self.taskTypeCollectionBtn {
            self.viewModel.output.filtermodel.map { (model) -> Bool in
                return    model.taskType.contains(TaskType.init(rawValue: btn.tag) ?? .photo)
            }.bind(to: btn.rx.isSelected)
            .disposed(by: self.rx.disposeBag)
        }
        self.viewModel.output.validSuccess.asObservable().bind(to: self.btndone.rx.isSelected).disposed(by: self.rx.disposeBag)
        self.viewModel.output.validSuccess.asObservable().subscribe(onNext: { [weak self] (isenable) in
            guard let `self` = self  else {return }
            self.enableBtnDoneStyle(isenable)
        }).disposed(by: self.rx.disposeBag)
    }
    func enableBtnDoneStyle(_ enable:Bool)  {
        self.btndone.backgroundColor = enable ? themeBarColor:themeBarDisableColor
        self.btndone.isEnabled = enable
    }
    func setUpview(){
        
    }
    
    
    @IBAction func doneSuccess(_ sender: Any) {
        //保存设置
        self.viewModel.input.doneApplyAction.onNext({}())
        self.applyAction?()
        self.dismissFromWindow()
    }
    
    @IBAction func genderAction(_ sender:UIButton)  {
     
        
        if sender.isSelected {
            self.viewModel.input.genderDeselectAction.onNext(sender.tag + 1)
        }else{
            self.viewModel.input.genderSelectAction.onNext(sender.tag + 1)
        }
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            sender.transform = CGAffineTransform.init(scaleX:1, y:1)
            sender.transform = .identity
        }
        
    }
    @IBAction func taskAction(_ sender:UIButton)  {
        if sender.isSelected {
            self.viewModel.input.taskDelectAction.onNext(sender.tag)
        }else{
            self.viewModel.input.taskselectAction.onNext(sender.tag )
        }
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            sender.transform = CGAffineTransform.init(scaleX:1, y:1)
            sender.transform = .identity
        }
        
    }
    
}

