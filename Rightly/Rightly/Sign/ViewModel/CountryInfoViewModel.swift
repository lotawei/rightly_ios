//
//  CountryInfoViewModel.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/28.
//

import Foundation
import KakaJSON

class CountryInfoViewModel {
    var countryDatas:Dictionary<String, [CountryInfoModel]> = Dictionary()
    var firstKeyDatas:[String] = []
    
    func getFirstKey(_ section:Int) -> String {
        if section < self.firstKeyDatas.count {
            return self.firstKeyDatas[section]
        }
        
        return ""
    }
    
    func getInfoModel(_ indexPath:IndexPath) -> CountryInfoModel? {
        if indexPath.section < self.firstKeyDatas.count {
            let firstKey = self.firstKeyDatas[indexPath.section]
            if indexPath.row < (self.countryDatas[firstKey]?.count ?? 0) {
                return self.countryDatas[firstKey]?[indexPath.row]
            }
        }
        
        return nil
    }
    
    init() {
        guard let countryJsonURL = Bundle.main.url(forResource: "country-iso3166", withExtension: "json") else {
            return
        }
        
        guard let countryJsonContent = try? String.init(contentsOf: countryJsonURL, encoding: .utf8) else {
            return
        }
        
        if let countryDic = countryJsonContent.convertJSONStringToDictionary() {
            for tempFirstC in countryDic.keys {
                guard let countryInfoArray = countryDic[tempFirstC] as? [Dictionary<String, Any>] else {
                    continue
                }
                
                var tempArray:[CountryInfoModel] = []
                for tempInfo in countryInfoArray {
                    let tempModel = tempInfo.kj.model(CountryInfoModel.self)
                    tempArray.append(tempModel)
                }
                
                if tempArray.count > 0 {
                    self.countryDatas[tempFirstC] = tempArray
                    self.firstKeyDatas.append(tempFirstC)
                }
            }
            
            self.firstKeyDatas.sort()
        }
    }
}

