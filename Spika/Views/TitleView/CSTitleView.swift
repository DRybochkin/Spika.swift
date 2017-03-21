//
//  CSTitleView.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSTitleView: UILabel {
   var title: String! {
        didSet {
            generateTitleAndSubtitle()
        }
    }
    var subTitle: String! {
        didSet {
            generateTitleAndSubtitle()
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        numberOfLines = 2
        textAlignment = .center
        textColor = UIColor.black
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)

        numberOfLines = 2
        textAlignment = .center
        textColor = UIColor.black
    }

    func generateTitleAndSubtitle() {
        let titleAndSubtitle: NSMutableAttributedString = NSMutableAttributedString(string: "")
        if (title != nil) {
            titleAndSubtitle.append(NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(20.0))]))
        }
        if (subTitle != nil) {
            titleAndSubtitle.append(NSAttributedString(string: subTitle, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(10.0))]))
        }
        attributedText = titleAndSubtitle
        sizeToFit()
        superview?.layoutSubviews()
    }
}
