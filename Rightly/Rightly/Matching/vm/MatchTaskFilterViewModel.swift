//
//  MatchTaskFilterViewModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/8.
//

import Foundation
import RxSwift
import RxCocoa
fileprivate let  filterSetting = "filterSetting"

class MatchTaskFilterViewModel:NSObject,RTViewModelType {
    
    var input: FilterTaskModelInput
    var output: FilterTaskModelOutput
    typealias Input = FilterTaskModelInput
    
    typealias Output = FilterTaskModelOutput
    struct FilterTaskModelInput {
        var  genderSelectAction:PublishSubject<Int> =  PublishSubject.init() //性别选择
        var  genderDeselectAction:PublishSubject<Int> =  PublishSubject.init()
        var  resetAction:PublishSubject<Void>//resetAction
        var  taskselectAction:PublishSubject<Int>  =  PublishSubject.init()
        var  taskDelectAction:PublishSubject<Int>  =  PublishSubject.init()
        var  doneApplyAction:PublishSubject<Void> = PublishSubject.init()
    }
    struct FilterTaskModelOutput {
        var  filtermodel:BehaviorRelay<FilterModel>
        var  validSuccess:BehaviorRelay<Bool>
    }
    
    override init() {
        let  resetaction:PublishSubject<Void> = PublishSubject.init()
        self.input = FilterTaskModelInput.init(resetAction:resetaction)
        let  model = MatchTaskFilterViewModel.loadDefaultConfig()
        let  outdata = BehaviorRelay<FilterModel>.init(value: model)
        var  valid:Bool = false
        if model.gender.count > 0 || model.taskType.count > 0  {
            valid = true
        }
        self.output = FilterTaskModelOutput.init(filtermodel: outdata, validSuccess: BehaviorRelay.init(value: valid))
        super.init()
        resetaction.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.resetConfig()
            let  resetModel = MatchTaskFilterViewModel.loadDefaultConfig()
            self.output.filtermodel.accept(resetModel)
            self.output.validSuccess.accept(false)
        }).disposed(by: self.rx.disposeBag)
        self.input.genderSelectAction.subscribe(onNext: { [weak self] (value) in
            guard let `self` = self  else {return }
            var datamodel = self.output.filtermodel.value
            if  value == 0 {
                datamodel.gender = []
            }
            else{
                datamodel.gender.insert(Gender(rawValue: value) ?? .male)
            }
//            self.saveFilterSpacerConfig(datamodel)
            self.output.filtermodel.accept(datamodel)
            self.validSuccess(model: datamodel)
            
            
        }).disposed(by: self.rx.disposeBag)
        
        self.input.genderDeselectAction.subscribe(onNext: { [weak self] (value) in
            guard let `self` = self  else {return }
            var datamodel = self.output.filtermodel.value
            let   gender = Gender.init(rawValue: value) ?? .male
            if  datamodel.gender.contains(gender) {
                datamodel.gender.remove(gender)
            }
//            self.saveFilterSpacerConfig(datamodel)
            self.output.filtermodel.accept(datamodel)
            self.validSuccess(model: datamodel)
            
        }).disposed(by: self.rx.disposeBag)
        
        
        self.input.taskselectAction.subscribe(onNext: { [weak self] (tasktype) in
            guard let `self` = self  else {return }
            var datamodel = self.output.filtermodel.value
            if tasktype == 0 {
                datamodel.taskType = []
            }else{
                datamodel.taskType.insert(TaskType(rawValue: tasktype) ?? .text)
            }
//            self.saveFilterSpacerConfig(datamodel)
            self.output.filtermodel.accept(datamodel)
            self.validSuccess(model: datamodel)
            
        }).disposed(by: self.rx.disposeBag)
        
        self.input.taskDelectAction.subscribe(onNext: { [weak self] (tasktype) in
            guard let `self` = self  else {return }
            var datamodel = self.output.filtermodel.value
            let   task = TaskType.init(rawValue: tasktype) ?? .text
            if  datamodel.taskType.contains(task) {
                datamodel.taskType.remove(task)
            }
//            self.saveFilterSpacerConfig(datamodel)
            self.output.filtermodel.accept(datamodel)
            self.validSuccess(model: datamodel)
            
        }).disposed(by: self.rx.disposeBag)
        
        self.input.doneApplyAction.subscribe(onNext: { [weak self]  in
            guard let `self` = self  else {return }
            self.saveFilterSpacerConfig(self.output.filtermodel.value)
        }).disposed(by: self.rx.disposeBag)
        
    }
}
extension MatchTaskFilterViewModel {
    
    static func loadDefaultConfig() -> FilterModel  {
        let  userDefault = UserDefaults.standard.object(forKey:filterSetting)
        var  model = FilterModel.init()
        if let  filterModel = userDefault as? [String:Any]  {
            model = filterModel.kj.model(FilterModel.self)
        }
        return model
    }
    fileprivate  func  saveFilterSpacerConfig(_ model:FilterModel?){
        guard let filterinfos = model?.kj.JSONObject() else {
            return
        }
        UserDefaults.standard.setValue(filterinfos, forKey: filterSetting)
        UserDefaults.standard.synchronize()
    }
    fileprivate  func  resetConfig(){
        
        UserDefaults.standard.removeObject(forKey: filterSetting)
        UserDefaults.standard.synchronize()
        
    }
    
    fileprivate func  validSuccess(model:FilterModel){
        var  valid:Bool = false
        if model.gender.count > 0 && model.taskType.count > 0  {
            valid = true
        }
        self.output.validSuccess.accept(valid)
//
            
    }
    
    
}
