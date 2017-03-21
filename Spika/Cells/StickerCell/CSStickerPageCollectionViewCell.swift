//
//  CSStickerPageCollectionViewCell.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSStickerPageCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var delegate: CSStickerDelegate?
    
    var model: CSStickerPageModel! {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: CSStickerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.list!.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CSStickerCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CSStickerCollectionViewCell
        let sticker: CSStickerModel! = model.list![indexPath.row]
        cell?.imageView?.sd_setImage(with: URL(string: (sticker.smallPic)!))
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(60), height: CGFloat(60))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sticker: CSStickerModel! = model.list![indexPath.row]
        delegate?.onSticker(sticker!.fullPic)
    }
}
