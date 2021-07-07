//
//  UserSettingViewModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/28.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources



struct UserSettingViewModel:RTViewModelType {
    typealias Input = UserSettingResultInput
    
    typealias Output = UserSettingResultOutput
    var input:Input
    var output:Output
    struct UserSettingResultInput {
        
    }
    struct UserSettingResultOutput {
        var  dataSource:RxTableViewSectionedReloadDataSource<SectionModel<String,String>>
        var  sampleDatas:Observable<[SectionModel<String,String>]>
    }
    init() {
        
        self.input = UserSettingResultInput.init()
        let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String,String>>.init { (datasource, tableview, indexpath, item) -> UITableViewCell in
            var  title = datasource[indexpath]
            if title != "Notice".localiz() {
                let cell:UserSettingCell = tableview.dequeueReusableCell(for: indexpath, cellType: UserSettingCell.self)
                cell.lbltxt.text = title
                return cell
            }else{
                let cell:UserSwitchSettingCell = tableview.dequeueReusableCell(for: indexpath, cellType: UserSwitchSettingCell.self)
                cell.lbltxt.text = title
                return cell
            }
            
        }
        
        
        let obserVable = Observable<[SectionModel<String,String>]>.create { (observer) -> Disposable in
            observer.onNext([SectionModel.init( model: "",items:["Notice".localiz(),"Help".localiz(),"About".localiz()])])
            observer.onCompleted()
            return  Disposables.create()
        }
        self.output = UserSettingResultOutput.init(dataSource: datasource, sampleDatas: obserVable)
    }
    
    
}
struct   OwerModelInfo {
    var  image:String = ""
    var  name:String = ""
}
enum OwerItem {
    case infoitem(_ info:OwerModelInfo)
}
struct OwerItemListSection {
    var items:[OwerItem]
    var header:String = ""
}
extension OwerItemListSection:SectionModelType{
    typealias Item = OwerItem
    init(original: OwerItemListSection, items: [OwerItem]) {
        self = original
        self.items = items
    }
}

struct UserOwerSettingViewModel:RTViewModelType {
    typealias Input = UserOwerSettingViewModelInput
    
    typealias Output = UserOwerSettingViewModelOutput
    var input:Input
    var output:Output
    struct UserOwerSettingViewModelInput {
        
    }
    struct UserOwerSettingViewModelOutput {
        var  dataSource:RxTableViewSectionedReloadDataSource<OwerItemListSection>
        var  sampleDatas:Observable<[OwerItemListSection]>
    }
    
    init() {
        self.input = UserOwerSettingViewModelInput.init()
        let datasource = RxTableViewSectionedReloadDataSource<OwerItemListSection>.init { (datasource, tableview, indexpath, item) -> UITableViewCell in
            let info = datasource[indexpath]
            let cell:OwerPersonalCell = tableview.dequeueReusableCell(for: indexpath, cellType: OwerPersonalCell.self)
            switch info {
            case .infoitem(let model):
                cell.updateDisplay(model.image, model.name)
            default:
                return cell
            }
            return cell
        }
        
        
        let obserVable = Observable<[OwerItemListSection]>.create { (observer) -> Disposable in
            var sestions = [OwerItemListSection]()
            let item1 = OwerItem.infoitem(OwerModelInfo.init(image: "editor_black", name: "My profile".localiz()))
            let item2 = OwerItem.infoitem(OwerModelInfo.init(image: "设置", name: "Setting".localiz()))
            let section1 = OwerItemListSection.init(items: [item1,item2])
            sestions.append(section1)
            observer.onNext(sestions)
            observer.onCompleted()
            return  Disposables.create()
        }
        self.output = UserOwerSettingViewModelOutput.init(dataSource: datasource, sampleDatas: obserVable)
    }
    
    
}
