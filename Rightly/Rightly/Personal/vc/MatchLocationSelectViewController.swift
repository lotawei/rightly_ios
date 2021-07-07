//
//  MatchLocationSelectViewController.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/7/5.
//

import Foundation

enum LocationSelectType:Int{
    case  School, //学校
          Nouns , //小区
          Office //办区
}

import Foundation
import Reusable
class ItemLocationPOICell: UITableViewCell,Reusable {
    lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = themeBarColor
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.mainLabel)
        self.mainLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(10)
            maker.bottom.equalToSuperview().offset(-10)
            maker.height.equalTo(30)
        }
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class MatchLocationSelectViewController: BaseViewController {
    var  searchResultPois:[MAPointAnnotation] = []
    var  locationCreateType:LocationSelectType = .School
    @IBOutlet weak var searchBar: UISearchBar!
    var  search:AMapSearchAPI!
    lazy var mapV:MAMapView = {
        let mapV = MAMapView.init()
        mapV.showsUserLocation = true
        mapV.userTrackingMode = .follow
        return mapV
    }()
    fileprivate lazy var  tableView:UITableView = {
        let  tableview =  UITableView.init(frame: .zero, style: .plain)
        tableview.backgroundColor = UIColor.white
        tableview.estimatedRowHeight =    85
        tableview.rowHeight =  UITableView.automaticDimension
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.register(cellType: ItemLocationPOICell.self)
        return tableview
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_prefersNavigationBarHidden = true
        
        initalMapV()
        
        initalSearchTable()
    }
    func initalMapV()  {
        self.view.addSubview(self.mapV)
        self.mapV.snp.makeConstraints { (maker) in
            maker.height.equalTo(240)
            maker.left.right.equalToSuperview()
            maker.top.equalTo(self.searchBar.snp.bottom).offset(20)
        }
        search = AMapSearchAPI.init()
        search.delegate = self
        searchBar.delegate = self
    }
    func initalSearchTable()  {
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(self.searchBar.snp.bottom)
        }
        showTableView(false)
    }
    func showTableView(_ isshow:Bool) {
        self.tableView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha =  isshow ? 1:0
        }
    }
    
}
//MARK-- poi搜索结果
extension MatchLocationSelectViewController:AMapSearchDelegate {
    func searchPOI(searchKeyWord keyword:String?) {
        guard let searchKey = keyword else {
            return
        }
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keyword
        request.requireExtension = true
        search.aMapPOIKeywordsSearch(request)
    }
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        DispatchQueue.main.async {
            self.toastTip("Network failed".localiz())
        }
    }
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            return annotationView!
        }
        
        return nil
    }
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        mapV.removeAnnotations(mapV.annotations)
        if response.count == 0  {
            return
        }
        var  anos = [MAPointAnnotation]()
        for aPoi in response.pois {
            let  cor = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(aPoi.location.latitude), longitude: CLLocationDegrees(aPoi.location.longitude))
            let  ano = MAPointAnnotation()
            ano.coordinate = cor
            ano.title = aPoi.name
            ano.subtitle = aPoi.address
            anos.append(ano)
        }
        mapV.addAnnotations(anos)
        mapV.showAnnotations(anos, animated: true)
        if let first = anos.first  {
            mapV.selectAnnotation(first, animated: true)
        }
        searchResultPois  = anos
        self.showTableView(true)
        self.tableView.reloadData()
    }
}
//MARK-- searchbar 代理回调
extension MatchLocationSelectViewController:UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showTableView(false)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPOI(searchKeyWord: searchBar.text)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchPOI(searchKeyWord: searchBar.text)
    }
    
}
//MARK-- 表视图代理
extension MatchLocationSelectViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultPois.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anos = self.searchResultPois[indexPath.row]
        let cell:ItemLocationPOICell = tableView.dequeueReusableCell(for: indexPath, cellType: ItemLocationPOICell.self)
        cell.mainLabel.text = anos.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let anos = self.searchResultPois[indexPath.row]
        self.showTableView(false)
        self.mapV.selectAnnotation(anos, animated: true)
    }
    
}
