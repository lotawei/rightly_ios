//
//  SelectAreaCodeViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/4/26.
//

import UIKit

class SelectAreaCodeViewController: UIViewController {
    typealias SelectBlock = (_ areaCode:String)->Void;
    
    private var selectBlock : SelectBlock?
    private var viewModel:CountryInfoViewModel = CountryInfoViewModel()
    
    lazy var tableView:UITableView = {
        let resultView = UITableView()
        resultView.separatorStyle = .none
        resultView.rowHeight = 156.0
        let footerH = isIphoneX ? safeBottomH : 10.0
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: footerH))
        resultView.tableFooterView = footerView
        
        resultView.delegate = self
        resultView.dataSource = self
        
        resultView.register(CountryCategoryView.self, forHeaderFooterViewReuseIdentifier: "headerId")
        resultView.register(.init(nibName: "CountryInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "countryId")
        return resultView
    }()
    
    init(_ block:@escaping SelectBlock) {
        super.init(nibName: nil, bundle: nil)
        self.selectBlock = block
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearNavigationBarLine()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setupNavigationBarLine()
    }
    
    func setupView() {
        self.title = "Choose the country".localiz()
        
        let leftItemBtn = UIButton.init(type: .custom)
        leftItemBtn.setTitleColor(.black, for: .normal)
        leftItemBtn.setTitle("system_Cancel".localiz(), for: .normal)
        leftItemBtn.titleLabel?.font = .systemFont(ofSize: 12)
        leftItemBtn.addTarget(self, action: #selector(cancelItemAction), for: .touchUpInside)
        
        let leftBarBtnItem = UIBarButtonItem.init(customView: leftItemBtn)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func cancelItemAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectAreaCodeViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.firstKeyDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempKey = self.viewModel.firstKeyDatas[section]
        let tempArray = self.viewModel.countryDatas[tempKey]
        return tempArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryId", for: indexPath) as? CountryInfoTableViewCell ?? CountryInfoTableViewCell.init(style: .default, reuseIdentifier: "countryId")
        let tempModel = self.viewModel.getInfoModel(indexPath)
        cell.bindingModel(tempModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId") as? CountryCategoryView
        let firstKey = self.viewModel.getFirstKey(section)
        if firstKey == "0000" {
            headerView?.categoryLabel.text = "Common".localiz()
        } else {
            headerView?.categoryLabel.text = self.viewModel.getFirstKey(section)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tempModel = self.viewModel.getInfoModel(indexPath) {
            self.selectBlock?(tempModel.areaCodeStr)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titleArray = self.viewModel.firstKeyDatas
        titleArray[0] = "Common".localiz()
        return titleArray
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
    }
}
