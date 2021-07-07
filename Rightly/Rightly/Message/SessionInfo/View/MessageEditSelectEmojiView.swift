//
//  MessageEditSelectEmojiView.swift
//  Rightly
//
//  Created by qichen jiang on 2021/3/22.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

typealias EmojiSelectBlock = (_ text:String, _ imagePath:String)->Void

class EmojiCollectionCell: UICollectionViewCell {
    let imageView:UIImageView = UIImageView.init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 36, height: 36))
        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageEditSelectEmojiView: UIView, NibLoadable {
    @IBOutlet weak var collectionView: UICollectionView!
    var emojiSelectBlock: EmojiSelectBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let emojiWH = screenWidth / 8.0
        self.collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "emojiId")
        let flowLayout:UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout ?? UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 0.1
        flowLayout.minimumInteritemSpacing = 0.1
        flowLayout.itemSize = CGSize(width: emojiWH, height: emojiWH)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
}

extension MessageEditSelectEmojiView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmojiManager.shared().emojiKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiId", for: indexPath) as! EmojiCollectionCell
        let emojiKey = EmojiManager.shared().emojiKeys[indexPath.row]
        let emojiPath = EmojiManager.shared().emojiDatas[emojiKey] ?? ""
        cell.imageView.image = UIImage.init(contentsOfFile: emojiPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emojiKey = EmojiManager.shared().emojiKeys[indexPath.row]
        let emojiPath = EmojiManager.shared().emojiDatas[emojiKey] ?? ""
        
        self.emojiSelectBlock?(emojiKey, emojiPath)
    }
}

