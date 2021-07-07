//
//  UserTagsManager.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MBProgressHUD

//标签管理流程
typealias successTagBlock = (_ tags:[ItemTag]) -> Void
typealias successCategoryBlock = (_ categories:[ItemTagCategory]) -> Void
class UserTagsManager:NSObject{
    let  maxTagChoose:Int = 20 //可允许最大标签限制
    var enablePubSave:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var enableSave:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var useroriginaltags:BehaviorSubject<[ItemTag]> = BehaviorSubject.init(value: []) //原有的用户自己的标签 不会做更改操作
    var usertags:BehaviorRelay<[ItemTag]?> = BehaviorRelay.init(value: nil) //用户标签  只会更改selected 和 公开属性
    var othertags:BehaviorRelay<[ItemTag]?> = BehaviorRelay.init(value:nil) //其它人的用户标签 方便区分是他人的标签
    var  addlisttag:Set<ItemTag> = Set<ItemTag>.init()  //添加数组标签
    var  removelisttag:Set<ItemTag> = Set<ItemTag>.init()  //
    var  publiclisttag:Set<ItemTag> = Set<ItemTag>.init()
    var  privatelisttag:Set<ItemTag> = Set<ItemTag>.init()
    static let  shared:UserTagsManager =  UserTagsManager.init()
    func saveTagConfig(){
        MBProgressHUD.showStatusInfo("Saving...".localiz())
        let  addtags = self.addlisttag.map { (va) -> Int64 in
            return va.tagId
        }
        let  removetags = self.removelisttag.map { (va) -> Int64 in
            return va.tagId
        }
        debugPrint("-----\(addtags) .. \(removetags)")
        self.editTags(addtags, removetags) { (finish) in
            MBProgressHUD.dismiss()
            if   finish {
                self.clearSet()
                self.updateTags()
                NotificationCenter.default.post(name: kNotifyRefresh, object: nil)
                self.getCurrentViewController()?.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    func savePubAndPrivateConfig(){
        MBProgressHUD.showStatusInfo("Saving...".localiz())
        let  pubtags = self.publiclisttag.map { (va) -> Int64 in
            return va.tagId
        }
        let  prtag = self.privatelisttag.map { (va) -> Int64 in
            return va.tagId
        }
        debugPrint("-----\(pubtags) .. \(prtag)")
        self.tagViewType(pubtags, prtag) { (finish) in
            MBProgressHUD.dismiss()
            if   finish {
                self.clearSet()
                self.updateTags()
                self.getCurrentViewController()?.navigationController?.popViewController(animated: false)
                NotificationCenter.default.post(name: kNotifyRefresh, object: nil)
            }
        }
    }
    func clearSet()  {
        self.addlisttag.removeAll()
        self.removelisttag.removeAll()
        self.publiclisttag.removeAll()
        self.privatelisttag.removeAll()
        self.enablePubSave.accept(false)
        self.enableSave.accept(false)
        self.usertags.accept(nil)
        self.useroriginaltags.onNext([])
    }
    /// 更新用户原始标签
    func updateTags(_ userid:Int64? = nil)  {
        var  uid:Int64? = userid
        if uid == nil {
            uid = UserManager.manager.currentUser?.additionalInfo?.userId
        }
        guard let uuid = uid else {
            return
        }
        UserTagsManager.shared.requestUserItemTags(uuid) { (tags) in
            //刷新
        }
    }
    /// 请求用户标签
    /// - Parameters:
    ///   - userid: userid
    ///   - tagsuccessBlock: <#tagsuccessBlock description#>
    func requestUserItemTags(_ userid:Int64, _ tagsuccessBlock:@escaping successTagBlock )  {
        //        UserProVider.init().userTagLists(userid: userid, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
        //            guard let `self` = self  else {return }
        //            switch res {
        //            case .success(let tags):
        //                let  newtags = tags?.map({ (tag) -> ItemTag in
        //                    var newite = tag
        //                    newite.isselected = true
        //                    return newite
        //                })
        //                tagsuccessBlock(newtags ?? [])
        //                if UserManager.isOwnerMySelf(userid) {
        //                    self.usertags.accept(newtags ?? [])
        //                    self.useroriginaltags.onNext(newtags ?? [])
        //                }
        //                else
        //                {
        //                    self.othertags.accept(tags ?? [])
        //                }
        //                break
        //            case .failed(let err):
        //                tagsuccessBlock([])
        //                MBProgressHUD.showError("Get tags Failed".localiz())
        //            }
        //        }).disposed(by: self.rx.disposeBag)
        let userProvider = UserProVider.init()
        var requestOb:Observable<ReqResult>
        if  UserManager.isOwnerMySelf(userid) {
            requestOb = userProvider.otherTagList(userid, self.rx.disposeBag)
        } else {
            requestOb = userProvider.myTagList(self.rx.disposeBag)
        }
        
        requestOb.subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            var tags = [ItemTag]()
            if let datas = res.data as? [[String: Any]] {
                for tempData in datas {
                    let tempModel = tempData.kj.model(ItemTag.self)
                    tags.append(tempModel)
                }
                let  newtags = tags.map({ (tag) -> ItemTag in
                    let newite = tag
                    newite.isselected = true
                    return newite
                })
                tagsuccessBlock(newtags)
                if UserManager.isOwnerMySelf(userid) {
                    self.usertags.accept(newtags)
                    self.useroriginaltags.onNext(newtags)
                }
                else
                {
                    self.othertags.accept(tags)
                }
            }
            
        }).disposed(by: self.rx.disposeBag)
        
    }
    /// 请求标签分类
    /// - Parameters:
    ///   - categorysuccessBlock: categorysuccessBlock
    func requestUserCategoryList(_ categorysuccessBlock:@escaping successCategoryBlock )  {
        UserProVider.init().userCategoryList( self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let category = res.modelArrType(ItemTagCategory.self) {
                categorysuccessBlock(category)
            }else{
                categorysuccessBlock([])
            }
        },onError: { (err) in
            categorysuccessBlock([])
            MBProgressHUD.showError("Get system category Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// 根据分类id获取标签列表
    /// - Parameters:
    ///   - userid: userid
    ///   - tagsuccessBlock: <#tagsuccessBlock description#>
    func requestCategoryItemTags(_ categortId:Int64, _ tagsuccessBlock:@escaping successTagBlock )  {
        UserProVider.init().categorTagList(categortId, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            if let categorytags = res.modelArrType(ItemTag.self){
                              var  tags = categorytags
                              let  filtertags =  self.filterCategoryTags(tags)
                              tagsuccessBlock(filtertags)
            }else{
                tagsuccessBlock([])
            }
//            switch res {
//            case .success(let categorytags):
//                var  tags = categorytags ?? []
//                let  filtertags =  self.filterCategoryTags(tags)
//                tagsuccessBlock(filtertags)
//                break
//            case .failed(let err):
//                tagsuccessBlock([])
//                MBProgressHUD.showError("Get tags Failed".localiz())
//            }
        },onError: { (err) in
                            tagsuccessBlock([])
                           MBProgressHUD.showError("Get tags Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// 编辑标签
    /// - Parameters:
    ///   - userid: userid
    ///   - tagsuccessBlock: <#tagsuccessBlock description#>
    func editTags(_ addList:[Int64], _ removeList:[Int64],_ editorResult: ((_ saveSuccess:Bool)->Void)?)  {
        UserProVider.init().editTag(addList, removeList: removeList, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            editorResult?(true)
        },onError: { (err) in
            editorResult?(false)
            MBProgressHUD.showError("Save Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    
    /// 公开
    /// - Parameters:
    func tagViewType(_ publictags:[Int64], _ privatetags:[Int64],_ editorResult: ((_ saveSuccess:Bool)->Void)?)  {
        
        UserProVider.init().editViewTagType(publictags, privateList: privatetags, self.rx.disposeBag).subscribe(onNext: { [weak self] (res) in
            guard let `self` = self  else {return }
            editorResult?(true)
        },onError: { (err) in
            editorResult?(false)
            MBProgressHUD.showError("Save Failed".localiz())
        }).disposed(by: self.rx.disposeBag)
    }
    //添加标签
    @discardableResult
    func tagSelected(_ itemTag:ItemTag) -> Bool {
        var  newitemtag = itemTag
        if var  usertags =  self.usertags.value {
            if usertags.filter({ (tag) -> Bool in
                return tag.isselected
            }).count == maxTagChoose {
                self.getCurrentViewController()?.toastTip("Max tag choose limited by ".localiz().replacingOccurrences(of: "$-$", with: "\(maxTagChoose)"))
                return false
            }
            if usertags.contains(newitemtag) {
                newitemtag.isselected = true
                var index = usertags.firstIndex { (tag) -> Bool in
                    return tag.tagId == itemTag.tagId
                }
                if let index = index  {
                    usertags[index] = newitemtag
                }
                self.usertags.accept(usertags)
                usertagsAddListState(newitemtag)
                return  true
            }
            else{
                newitemtag.isselected = true
                usertags.append(newitemtag)
                self.usertags.accept(usertags)
                usertagsAddListState(newitemtag)
                return true
            }
        }
        return false
    }
    //删除标签
    @discardableResult
    func untagSelect(_ itemTag:ItemTag) -> Bool {
        var  newitemtag = itemTag
        if var  usertags = self.usertags.value {
            if usertags.contains(newitemtag) {
                newitemtag.isselected = false
                var index = usertags.firstIndex { (tag) -> Bool in
                    return tag.tagId == itemTag.tagId
                }
                if let index = index  {
                    usertags[index] = newitemtag
                }
                self.usertags.accept(usertags)
                usertagsRemoveListState(newitemtag)
                return true
            }
        }
        return false
    }
    
    //公开标签
    @discardableResult
    func pubSelectTag(_ itemTag:ItemTag) -> Bool {
        var  newitemtag = itemTag
        if var  usertags =  self.usertags.value {
            if usertags.filter({ (tag) -> Bool in
                return  ((tag.viewType ?? ViewType.Private) == ViewType.Public )
            }).count == maxTagChoose {
                self.getCurrentViewController()?.toastTip("Max tag choose limited by ".localiz().replacingOccurrences(of: "$-$", with: "\(maxTagChoose)"))
                return false
            }
            if usertags.contains(newitemtag) {
                newitemtag.viewType = .Public
                var index = usertags.firstIndex { (tag) -> Bool in
                    return tag.tagId == itemTag.tagId
                }
                if let index = index  {
                    usertags[index] = newitemtag
                }
                self.usertags.accept(usertags)
                usertagsPubListState(newitemtag)
                return  true
            }
            else{
                newitemtag.viewType = .Public
                usertags.append(newitemtag)
                self.usertags.accept(usertags)
                usertagsPubListState(newitemtag)
                return true
            }
        }
        return false
    }
    //不公开标签
    @discardableResult
    func unpubSelectTag(_ itemTag:ItemTag) -> Bool {
        var  newitemtag = itemTag
        if var  usertags = self.usertags.value {
            if usertags.contains(newitemtag) {
                newitemtag.viewType = .Private
                var index = usertags.firstIndex { (tag) -> Bool in
                    return tag.tagId == itemTag.tagId
                }
                if let index = index  {
                    usertags[index] = newitemtag
                }
                self.usertags.accept(usertags)
                usertagsPrivateListState(newitemtag)
                return true
            }
        }
        return false
    }
    
}

extension UserTagsManager {
    //过滤用户已添加的标签 [1,2,3 ] 处理数组交集 结果并替换
    func filterCategoryTags(_ itemtags:[ItemTag]) -> [ItemTag] {
        var  newItemTag = itemtags
        if let usertags =  self.usertags.value {
            //取交集
            let  addtagarr = Set.init(usertags)
            let  categroyarr = Set.init(itemtags)
            let insection =  addtagarr.intersection(itemtags)
            for item in insection.enumerated() {
                var index =  newItemTag.firstIndex(where: {(tag) -> Bool in
                    return tag.tagId == item.element.tagId
                })
                if let index = index {
                    var  newitem = item.element
                    newitem.isselected = item.element.isselected
                    newItemTag[index] = newitem
                }
            }
            return newItemTag
        }
        return  newItemTag
    }
    
    func usertagsAddListState(_ tag:ItemTag)  {
        if let orignalTags = try? self.useroriginaltags.value() {
            removelisttag.remove(tag)
            if !orignalTags.contains(tag) {
                //添加则原始数组肯定没有
                addlisttag.insert(tag)
            }
            checkSaveState()
        }
    }
    func usertagsRemoveListState(_ tag:ItemTag)  {
        if let orignalTags = try? self.useroriginaltags.value() {
            if orignalTags.contains(tag) {
                removelisttag.insert(tag)
            }
            addlisttag.remove(tag)
            checkSaveState()
        }
    }
    func usertagsPubListState(_ tag:ItemTag)  {
        if let orignalPrivateTags = try?  self.useroriginaltags.value().filter({ (tag) -> Bool in
            return ((tag.viewType ??  .Private ) == .Private)
        }) {
            
            if  orignalPrivateTags.contains(tag) {
                privatelisttag.remove(tag)
                publiclisttag.insert(tag)
            }else{
                publiclisttag.insert(tag)
            }
            checkPubSaveState()
        }else{
            publiclisttag.insert(tag)
            checkPubSaveState()
        }
    }
    func usertagsPrivateListState(_ tag:ItemTag)  {
        if let orignalPublicTags =  try?  self.useroriginaltags.value().filter({ (tag) -> Bool in
            return ((tag.viewType ??  .Private ) == .Public)
        }) {
            
            if orignalPublicTags.contains(tag) {
                privatelisttag.insert(tag)
                publiclisttag.remove(tag)
            }else{
                privatelisttag.insert(tag)
            }
            checkPubSaveState()
        }else{
            privatelisttag.insert(tag)
            checkPubSaveState()
        }
    }
    func checkSaveState()  {
        if addlisttag.count > 0 || removelisttag.count > 0 {
            self.enableSave.accept(true)
        }else{
            self.enableSave.accept(false)
        }
        
    }
    
    func checkPubSaveState()  {
        if publiclisttag.count > 0 || privatelisttag.count > 0 {
            self.enablePubSave.accept(true)
        }else{
            self.enablePubSave.accept(false)
        }
    }
    
    
}
