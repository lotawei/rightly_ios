//
//  PreviewImageViewController.swift
//  Rightly
//
//  Created by qichen jiang on 2021/6/28.
//

import UIKit

class PreviewImageViewController: PreviewBaseViewController {
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize(width: screenWidth, height: screenHeight)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = .zero
        let resultView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: flowLayout)
        resultView.register(UINib.init(nibName: "PreviewImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageId")
        resultView.isPagingEnabled = true
        resultView.delegate = self
        resultView.dataSource = self
        return resultView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        self.setupView()
    }
    
    func setupView() {
        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupData() {
        self.panState.subscribe(onNext: { (state) in
            self.collectionView.isScrollEnabled = state != .effective
        }).disposed(by: self.rx.disposeBag)
    }
}

extension PreviewImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageId", for: indexPath) as? PreviewImageCollectionViewCell ?? PreviewImageCollectionViewCell.init()
        
        switch indexPath.row {
        case 0:
            cell.imageView.backgroundColor = .red
        case 1:
            cell.imageView.backgroundColor = .yellow
        case 2:
            cell.imageView.backgroundColor = .blue
        default:
            cell.imageView.backgroundColor = .green
        }
        
        return cell
    }
    
    
}
