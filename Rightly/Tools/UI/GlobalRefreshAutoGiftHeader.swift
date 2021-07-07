//
//  GlobalRefreshAutoGiftHeader.swift
//  Rightly
//
//  Created by lejing_lotawei on 2021/4/16.
//

import Foundation
import MJRefresh
public class GlobalRefreshAutoGiftHeader :MJRefreshGifHeader {
    
    func setNeedsReload() {
            loaddefaultGif()

    }
    
    public override func prepare(){
        super.prepare()
        setNeedsReload()
    }
    
    
    fileprivate func  loaddefaultGif(){
        var refreshimages:[UIImage] = [UIImage]()
        
        //遍历
        let  imgprefix = "loading"
        var  idleimg:[UIImage] = [UIImage]()
        let imgdefault = UIImage.init(named: String.init("\(imgprefix)\(1)"), in: Bundle.init(for:self.classForCoder), compatibleWith: nil)
        idleimg.append(imgdefault!)
        for i in 1..<13 {
            let img = UIImage.init(named: String.init("\(imgprefix)\(i)"), in: Bundle.init(for:self.classForCoder), compatibleWith: nil)
            refreshimages.append(img!)
        }
        setImages(idleimg, for: .idle)
        setImages(refreshimages, for: .pulling)
        setImages(refreshimages, for: .refreshing)
        lastUpdatedTimeLabel?.isHidden = true
        stateLabel?.isHidden = true
        mj_h = 50
    }
}
public class GlobalRefreshFooter :MJRefreshAutoNormalFooter {
    
    var useNomoreData:Bool = false {
        didSet {
            if useNomoreData == true {
                self.setTitle("NO_More_Data".localiz(), for: .noMoreData)
            }else{
                self.setTitle("".localiz(), for: .noMoreData)
            }
        }
    }
    public override func prepare(){
        super.prepare()
        self.setTitle("".localiz(), for: .idle)
        self.setTitle("".localiz(), for: .refreshing)
        //
        let  noreData = useNomoreData ?"NO_More_Data".localiz():""
        self.setTitle(noreData, for: .noMoreData)
    }
}
