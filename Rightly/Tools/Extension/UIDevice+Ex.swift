//
//  UIDevice+Ex.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/6/11.
//

import Foundation
extension UIDevice{
    /// 获取当前设备uuid
    /// - Returns:
    public func  getDeviceUUID() -> String?{
        return  UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    //iphone model
    func getdeviceModel () -> String? {
        let name = UnsafeMutablePointer<utsname>.allocate(capacity: 1)
        
        uname(name)
        
        let machine = withUnsafePointer(to: &name.pointee.machine, { (ptr) -> String? in
            
            
            
            let int8Ptr = unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)
            
            return String.init(cString: int8Ptr)
            
            // return String.fromCString(int8Ptr)
            
        })
        
        name.deallocate()
        
        if let deviceString = machine {
            switch deviceString {
            //iPhone
            
            case "iPhone1,1":                 return "iPhone 1G"
                
            case "iPhone1,2":                 return "iPhone 3G"
                
            case "iPhone2,1":                 return "iPhone 3GS"
                
            case "iPhone3,1", "iPhone3,2":    return "iPhone 4"
                
            case "iPhone4,1":                 return "iPhone 4S"
                
            case "iPhone5,1", "iPhone5,2":    return "iPhone 5"
                
            case "iPhone5,3", "iPhone5,4":    return "iPhone 5C"
                
            case "iPhone6,1", "iPhone6,2":    return "iPhone 5S"
                
            case "iPhone7,1":                 return "iPhone 6 Plus"
                
            case "iPhone7,2":                 return "iPhone 6"
                
            case "iPhone8,1":                 return "iPhone 6s"
                
            case "iPhone8,2":                 return "iPhone 6s Plus"
                
            case "iPhone9,1":                 return "iPhone 7"
                
            case "iPhone9,2":                 return "iPhone 7 Plus"
                
            case "iPhone10,1", "iPhone10,4":  return "iPhone 8"
                
            case "iPhone10,2", "iPhone10,5":  return "iPhone 8 Plus"
                
            case "iPhone10,3", "iPhone10,6":  return "iPhone X"
                
            default:                          return deviceString
                
            }
            
        } else {
            return nil
            
        }
        
    }
    
    //MARK: APP相关信息
    public  func getAppInfo() -> [String:Any]?{
        return Bundle.main.infoDictionary
    }
    //MARK: 获取APP version
    public  func getAppVersion() -> String?{
        return getAppInfo()?["CFBundleShortVersionString"] as? String ?? ""
    }
    
}
