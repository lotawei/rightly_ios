//
//  LocationManager.swift
//  podinstall
//
//  Created by lejing_lotawei on 2021/6/29.
//

import Foundation
import RxCocoa
import  RxSwift
import CoreLocation


enum GPSStatus {
    case perfect
    case good
    case low
    case weak
    case lost
}
class   LocationManager:NSObject{
    let  disposebag = DisposeBag()
    var reverseAddressBlock:((_ result:String)->Void)?=nil //反编码结果
    var reverseCityBlock:((_ result:String)->Void)?=nil //反城市
    public  var   curlocationinfo:PublishSubject<CLLocation> = PublishSubject<CLLocation>() //当前经纬度结果
    public  var   gpsstatus:BehaviorSubject<GPSStatus> = BehaviorSubject<GPSStatus>(value:.lost) //当前信号强度
    public  var   city:BehaviorSubject<String> = BehaviorSubject.init(value: "") //反编码当前地理城市
    public  var   address:BehaviorSubject<String> = BehaviorSubject.init(value: "") //反编码 地址
    fileprivate var  baselocationManager:AMapLocationManager!
    fileprivate var search:AMapSearchAPI!
    fileprivate let   searchRequest = AMapReGeocodeSearchRequest.init()
    override init() {
        super.init()
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied {
            CLLocationManager.init().requestWhenInUseAuthorization()
        }
        search = AMapSearchAPI.init()
        search.delegate = self
        baselocationManager = AMapLocationManager()
        baselocationManager.allowsBackgroundLocationUpdates = true
        baselocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        baselocationManager.locationTimeout = 5
        baselocationManager.reGeocodeTimeout = 5
        baselocationManager.delegate = self
    }
    //单次定位的
    @objc public  func startOnceLocation(_ haspermission:((_ has:Bool) -> Void)? = nil){
        self.checkPermission {[weak self] (status) in
            guard let `self` = self  else {return }
            if status {
                self.baselocationManager.requestLocation(withReGeocode: true) {[weak self] (location, mapreverseRegCode, error) in
                    guard let `self` = self  else {return }
                    if error == nil {
                        self.locationCompleteHandler(location: location)
                    }
                    else{
                        debugPrint("-------\(error.debugDescription)")
                    }
                }
            }
        }
        
    }
    fileprivate func checkPermission(_ haspermission:((_ has:Bool) -> Void)? = nil){
        SystemPermission.checkLocation(alertEnable: true) { (status) in
            haspermission?(status)
        }
        //        haspermission?(true)
    }
    fileprivate func  locationCompleteHandler(location:CLLocation?){
        let curloc = location
        self.gpsstatus.onNext(self.getGps(curloc))
        guard let loc = location else {
            return
        }
        DispatchQueue.main.async {
            self.curlocationinfo.onNext(loc)
        }
        reverseAllGeocode(loc.coordinate.latitude, loc.coordinate.longitude)
    }
    
    //持续定位的
    @objc public  func startConstantlyLocation(_ haspermission:((_ has:Bool) -> Void)? = nil){
        self.stopLocation()
        self.checkPermission {[weak self] (status) in
            guard let `self` = self  else {return }
            if status {
                self.baselocationManager.startUpdatingLocation()
            }
        }
    }
    @objc public  func stopLocation(){
        self.baselocationManager.stopUpdatingLocation()
    }
}
extension LocationManager:AMapLocationManagerDelegate{
//    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
//        SystemPermission.checkLocation(alertEnable: true) { (status) in
//            if !status { locationManager.requestAlwaysAuthorization()}
//        }
//    }
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        self.locationCompleteHandler(location: location)
        debugPrint("-------\(reGeocode)")
    }
    func  getGps(_ loc:CLLocation?) -> GPSStatus {
        guard let  lo = loc else{
            return  .lost;
        }
        if(lo.horizontalAccuracy <= 10.0){
            return .perfect
        }
        else if(lo.horizontalAccuracy > 10.0 && lo.horizontalAccuracy <= 20){
            return .good
        }
        else if(lo.horizontalAccuracy > 20.0 && lo.horizontalAccuracy <= 50){
            return .low
        }
        else if(lo.horizontalAccuracy > 50.0 && lo.horizontalAccuracy <= 200){
            return .weak
        }
        return .lost;
        
    }
}
extension   LocationManager:AMapSearchDelegate{
    func reverseAllGeocode(_ lat:Double,_ lng:Double){
        self.requestMapRegCode(lat, lng)
    }
    func reverseAddressGeocode(_ lat:Double,_ lng:Double,reveseaddressBlock:@escaping ((_ result:String)->Void)){
        self.reverseAddressBlock = reveseaddressBlock
        self.requestMapRegCode(lat, lng)
    }
    func reverseCityGeocode(_ lat:Double,_ lng:Double,revesecityBlock:@escaping ((_ result:String)->Void)){
        self.reverseCityBlock = revesecityBlock
        self.requestMapRegCode(lat, lng)
    }
    fileprivate func requestMapRegCode(_ lat:Double,_ lng:Double){
        searchRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(lat), longitude: CGFloat(lng))
        searchRequest.requireExtension = true
        search.aMapReGoecodeSearch(searchRequest)
    }
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        let city = response.regeocode.addressComponent.city ?? ""
        let  address = response.regeocode.formattedAddress ?? ""
        self.reverseCityBlock?(city)
        self.reverseAddressBlock?(address)
        self.city.onNext(city)
        self.address.onNext(address)
    }
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        debugPrint("=====\(error.debugDescription)")
    }
    
}


