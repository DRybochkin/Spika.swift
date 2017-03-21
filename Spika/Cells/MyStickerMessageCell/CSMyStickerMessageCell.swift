//
//  CSMyStickerMessageCell.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSMyStickerMessageCell: CSBaseTableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var avatar: CSAvatarView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var peak: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override var message: CSMessageModel! {
        didSet {
            backView.layer.cornerRadius = 8
            backView.layer.masksToBounds = true
            backView.backgroundColor = kAppBubbleRightColor
            loadingIndicator.startAnimating()
            manageLoadingIndicator(toShow: false)
            let dateCreated: String = message.created.toString(format: "H:mm")
            var messageStatus: String
            if (message.seenBy != nil && message.seenBy.count > 0) {
                messageStatus = "Seen"
                timeLabel.text = String(format: "%@, %@", messageStatus, dateCreated)
            } else if (message.messageStatus == KAppMessageStatus.Sent) {
                messageStatus = "Sending..."
                timeLabel.text = messageStatus
            } else {
                messageStatus = "Sent"
                timeLabel.text = String(format: "%@, %@", messageStatus, dateCreated)
            }
            
            timeLabel.textColor = kAppMessageFontColor
            localImage.layer.cornerRadius = 8
            localImage.layer.masksToBounds = true
            localImage.sd_setImage(with: URL(string: message.message))
            if (isShouldShowAvatar) {
                avatar.isHidden = false
                if (message.user != nil && message.user.avatarURL != nil && message.user.avatarURL != "") {
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
                dateLabel.text = message.created.toString(format: "d MMMM yyyy ")
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
            let it1 = UIMenuItem(title: "Details", action: #selector(handleDetails(_:)))
            let it2 = UIMenuItem(title: "Delete", action: #selector(handleDelete(_:)))
            menuController.menuItems = [it1, it2]
            menuController.setTargetRect(localImage.frame, in: localImage as UIView)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    func handleDelete(_ sender: Any) {
        if (delegate != nil && delegate?.onDeleteClicked != nil) {
            delegate?.onDeleteClicked(message)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (message.deleted != nil) {
            return false
        }
        if (action == #selector(handleDetails(_:))) {
            return true
        } else if (action == #selector(handleDelete(_:))) {
            return true
        }

        return false
    }
}
