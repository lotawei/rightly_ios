//
//  DynamicTopicTableView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/9.
//

import UIKit

class DynamicTopicTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var cellDatas:[TopicsDataViewModel] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transform = CGAffineTransform(rotationAngle: (.pi / -2.0))
    }
    
    func setupView() {
        self.separatorStyle = .none
        self.dataSource = self
        self.delegate = self
        
        self.register(UINib.init(nibName: "DynamicTopicTableViewCell", bundle: nil), forCellReuseIdentifier: "topicId")
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tempViewModel = self.cellDatas[indexPath.row]
        return tempViewModel.topicStrSize.width + 8.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicId", for: indexPath) as! DynamicTopicTableViewCell
        
        let tempViewModel = self.cellDatas[indexPath.row]
        cell.topicLabel.text = tempViewModel.topicStr
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentvc = self.getCurrentViewController() else {
            return
        }
        
        let tempViewModel = self.cellDatas[indexPath.row]
        let detailVc = DisCoverTopicDetailViewController.init()
        detailVc.topicId.accept(Int64(tempViewModel.topicId))
        currentvc.navigationController?.pushViewController(detailVc, animated: true)
    }
}
