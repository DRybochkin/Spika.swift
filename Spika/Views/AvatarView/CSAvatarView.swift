//
//  CSAvatarView.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSAvatarView: CSCustomView {
    @IBOutlet weak var avatar: UIImageView!

    override func initFromNib() {
        super.initFromNib()
    }
    
    func setImageWith(_ url: URL) {
        CSAvatarLoader.setImageWith(url, in: avatar)
    }

    override func customInit() {
    }

    override func layoutSubviews() {
        avatar.frame = CGRect(x: CGFloat(1), y: CGFloat(1), width: CGFloat(frame.size.width - 2), height: CGFloat(frame.size.height - 2))
        super.layoutSubviews()
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.layer.masksToBounds = true
        //    NSLog(@"frames: %@ %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.avatar.frame));
    }
}
