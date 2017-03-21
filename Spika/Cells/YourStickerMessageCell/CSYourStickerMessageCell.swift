//
//  CSYourStickerMessageCell.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

class CSYourStickerMessageCell: CSBaseTableViewCell {
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var avatar: CSAvatarView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var peak: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override var message: CSMessageModel! {
        didSet {
            backView.layer.cornerRadius = 8
            backView.layer.masksToBounds = true
            backView.backgroundColor = kAppBubbleLeftColor
            loadingIndicator.startAnimating()
            manageLoadingIndicator(toShow: false)
            timeLabel.text = message.created.toString(format: "H:mm")
            timeLabel.textColor = kAppMessageFontColor
            localImage.layer.cornerRadius = 8
            localImage.layer.masksToBounds = true
            localImage.sd_setImage(with: URL(string: message.message))
            if (isShouldShowAvatar) {
                avatar.isHidden = false
                if (message.user.avatarURL != nil && message.user.avatarURL != "") {
                    avatar.setImageWith(URL(string: (message.user.avatarURL)!)!)
                }
                peak.isHidden = false
            } else {
                avatar.isHidden = true
                peak.isHidden = true
            }
            if (isShouldShowName) {
                nameLabel.text = message.user?.name
            } else {
                nameLabel.text = ""
            }
            if (isShouldShowDate) {
                dateLabel.text = message.created.toString(format: " d MMMM yyyy ")
            } else {
                dateLabel.text = ""
            }
        }
    }

    func manageLoadingIndicator(toShow: Bool) {
        if (toShow) {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func handleLongPressGestures(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            sender.view?.becomeFirstResponder()
            let menuController = UIMenuController.shared
            let it1 = UIMenuItem(title: "Details", action: #selector(handleDetails))
            menuController.menuItems = [it1]
            menuController.setTargetRect(localImage.frame, in: localImage)
            menuController.setMenuVisible(true, animated: true)
        }
    }
}
