//
//  CSStickerView.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSStickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, CSStickerDelegate {
    var originalRect = CGRect.zero
    var selectedStickerCollection: Int = 0
    weak var delegate: CSStickerDelegate?
    
    var stickerList: CSStickerListModel! {
        didSet {
            collectionView?.reloadData()
            categoryCollectionView?.reloadData()
            if (stickerList.stickers.count > 0) {
                selectedStickerCollection = 0
                let selection = IndexPath(item: selectedStickerCollection, section: 0)
                categoryCollectionView?.selectItem(at: selection, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!

    @IBAction func onCancel(_ sender: Any) {
        animateHide()
    }
    
    init(parentView: UIView!, delegate: CSStickerDelegate?, stickers: CSStickerListModel!) {
        self.stickerList = stickers
        self.delegate = delegate

        super.init(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(parentView.frame.size.width), height: CGFloat(parentView.frame.size.height)))
        
        initFromNib()

        parentView.addSubview(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFromNib()
    }
    
    func initFromNib()  {
        let view: UIView! = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view!)
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        originalRect = backgroundView.frame
        collectionView?.register(UINib(nibName: String(describing: CSStickerPageCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "page")
        categoryCollectionView.register(UINib(nibName: String(describing: CSStickerCategoryCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "cell")
        categoryCollectionView.allowsSelection = true
        collectionView?.allowsSelection = false
        if (stickerList != nil && stickerList.stickers.count > 0) {
            selectedStickerCollection = 0
            let selection = IndexPath(item: selectedStickerCollection, section: 0)
            categoryCollectionView.selectItem(at: selection, animated: false, scrollPosition: .centeredHorizontally)
        }
        animateOpen()
   }

    
    func animateOpen() {
        backgroundView.alpha = 0.3
        backgroundView.frame = CGRect(x: -originalRect.size.width, y: originalRect.size.height + originalRect.origin.y, width: CGFloat(0), height: CGFloat(0))
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
            self.backgroundView.frame = self.originalRect
            self.backgroundView.alpha = 1.0
        }, completion: {(_ success: Bool) -> Void in
        })
    }

    func animateHide() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
            self.backgroundView.alpha = 0.3
            self.backgroundView.frame = CGRect(x: -(self.backgroundView.frame.size.width + self.backgroundView.frame.origin.x), y: self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height, width: CGFloat(0), height: CGFloat(0))
        }, completion: {(_ success: Bool) -> Void in
            self.removeFromSuperview()
        })
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerList.stickers.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 0) {
            let cell: CSStickerPageCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! CSStickerPageCollectionViewCell
            let sticker: CSStickerPageModel! = stickerList.stickers[indexPath.row]
            cell.delegate = self
            cell.model = sticker
            return cell!
        } else if (collectionView.tag == 1) {
            let cell: CSStickerCategoryCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CSStickerCategoryCollectionViewCell
            let sticker: CSStickerPageModel! = stickerList.stickers[indexPath.row]
            cell.imageView.sd_setImage(with: URL(string: sticker.mainPic))
            return cell
        }

        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0) {
            return collectionView.frame.size
        } else if (collectionView.tag == 1) {
            return CGSize(width: CGFloat(50), height: CGFloat(50))
        }

        return CGSize(width: CGFloat(60), height: CGFloat(60))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 1) {
            collectionView.scrollToItem(at: IndexPath(row: indexPath.row, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.tag == 0) {
            selectedStickerCollection = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
            let selection = IndexPath(item: selectedStickerCollection, section: 0)
            categoryCollectionView.selectItem(at: selection, animated: false, scrollPosition: .centeredHorizontally)
        }
    }

    func onSticker(_ stickerUrl: String) {
        delegate?.onSticker(stickerUrl)
        animateHide()
    }
}
