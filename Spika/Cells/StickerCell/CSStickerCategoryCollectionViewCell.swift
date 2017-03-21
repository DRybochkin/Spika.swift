//
//  CSStickerCategoryCollectionViewCell.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSStickerCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                backgroundColor = UIColor.white
            } else {
                backgroundColor = UIColor.clear
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
