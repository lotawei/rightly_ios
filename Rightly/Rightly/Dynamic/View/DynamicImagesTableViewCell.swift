//
//  DynamicImagesTableViewCell.swift
//  Rightly
//
//  Created by qichen jiang on 2021/5/26.
//

import UIKit

class DynamicImagesTableViewCell: DynamicBaseTableViewCell {
    
    @IBOutlet weak var collectionView: DynamicImagesCollectionView!
    override func bindingViewModel(_ viewModel:DynamicDataViewModel, _ listType:DynamicListType, _ isLastCell:Bool) {
        super.bindingViewModel(viewModel, listType, isLastCell)
        self.customContentViewHeight.constant = viewModel.customViewSize.height
        self.collectionView.itemSize = viewModel.imageItemSize
        self.collectionView.itemDatas = viewModel.imageURLList
        self.collectionView.itemIndexOfSession = viewModel.imageIndexOfSession
        self.collectionView.reloadData()
    }
}
