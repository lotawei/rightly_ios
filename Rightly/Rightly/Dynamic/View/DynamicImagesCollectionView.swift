//
//  DynamicImagesCollectionView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/27.
//

import UIKit

class DynamicImagesCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var itemSize:CGSize = .zero
    var itemDatas:[URL] = []
    var itemIndexOfSession:[[Int]] = []

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.register(UINib.init(nibName: "DynamicImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "dynamicImageId")
        self.delegate = self
        self.dataSource = self
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.itemIndexOfSession.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section < self.itemIndexOfSession.count ? self.itemIndexOfSession[section].count : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dynamicImageId", for: indexPath) as! DynamicImageCollectionViewCell
    
        let index = self.itemIndexOfSession[indexPath.section][indexPath.row]
        let imageURL = self.itemDatas[index]
        cell.contentImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? .zero : CGSize.init(width: self.mj_w, height: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = self.itemIndexOfSession[indexPath.section][indexPath.row]
        if index < self.itemDatas.count {
//            self.jumpPreViewResource(resources: self.itemDatas, selectindex: index)
            self.jumpNewPreViewResource(resources: self.itemDatas,selectindex: indexPath,collectionView: collectionView)
        }
    }
}
