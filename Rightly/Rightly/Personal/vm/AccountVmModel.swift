//
//  AccountVmModel.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/3/29.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum AccountItem {
    case accountItem(_ accoutitem:IconItem)
}
struct AccountItemListSection {
    var items:[AccountItem]
    var header:String = ""
}
extension AccountItemListSection:SectionModelType{
    typealias Item = AccountItem
    init(original: AccountItemListSection, items: [AccountItem]) {
        self = original
        self.items = items
    }
}




class AccountVmModel:RTViewModelType {
    let disposeBag:DisposeBag = DisposeBag.init()
    typealias Input = UserSettingResultInput
    
    typealias Output = UserSettingResultOutput
    var input:Input
    var output:Output
    struct UserSettingResultInput {
        var  updateAction:BehaviorRelay<Void> = BehaviorRelay.init(value: {}())
    }
    struct UserSettingResultOutput {
        var  dataSource:RxTableViewSectionedReloadDataSource<AccountItemListSection>
        var  selectDate:BehaviorRelay<Date?> = BehaviorRelay.init(value: nil)
        var  sampleDatas:BehaviorRelay<[AccountItemListSection]> = BehaviorRelay.init(value: [])
    }
    init() {
        
        self.input = UserSettingResultInput.init()
        let datasource = RxTableViewSectionedReloadDataSource<AccountItemListSection>.init { (datasource, tableview, indexpath, item) -> UITableViewCell in
            switch datasource[indexpath] {
            case .accountItem(let item):
                let cell:IconTextImageMoreCell = tableview.dequeueReusableCell(for: indexpath, cellType: IconTextImageMoreCell.self)
                cell.updateItem(item:item)
                return cell
            }
            return UITableViewCell.init()
           
        }
        self.output = UserSettingResultOutput.init(dataSource: datasource)
        self.input.updateAction.startWith({}())
            .subscribe(onNext: { [weak self] (res) in
                    guard let `self` = self  else {return }
                    self.refreshData()
                
        }).disposed(by: self.disposeBag)
    }
    func refreshData(){
       var  sectdatas = [AccountItemListSection]()
        UserManager.manager.requestUserInfo(nil) {[weak self] (info) in
            guard let `self` = self  else {return }
            let userhead = info.avatar?.dominFullPath()
            let headitem =  AccountItem.accountItem(IconItem.item(userhead, "Head".localiz(), nil))
            
            let usernick = info.nickname
            let nickitem =  AccountItem.accountItem(IconItem.item(nil, "NickName".localiz(), usernick))
            
            let gender = info.gender  ?? .none
            
            let genderItem =  AccountItem.accountItem(IconItem.item(nil, "Gender".localiz(), gender.desGender))
            
            let birth = info.birthdayDisplay
            
            self.output.selectDate.accept(info.birthDayDate)
            let birthitem =  AccountItem.accountItem(IconItem.item(nil, "Birthday".localiz(), birth))
            //第三方
            let apitem =  AccountItem.accountItem(IconItem.item("apicon", "Apple".localiz(), nil))
            let fbitem =  AccountItem.accountItem(IconItem.item("fbicon", "FaceBook".localiz(), nil))
            let gooleitem =  AccountItem.accountItem(IconItem.item("glicon", "Google".localiz(), nil))
            let  section1 = AccountItemListSection.init(items: [headitem,nickitem,genderItem,birthitem])
            sectdatas.append(section1)
            self.output.sampleDatas.accept(sectdatas)
        }
      
    }

}
