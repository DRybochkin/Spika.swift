//
//  MyTextMessageTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
class CSMyTextMessageTableViewCell: CSBaseTableViewCell {
    @IBOutlet weak var myTextMessage: UILabel!
    @IBOutlet weak var myBackgroundView: UIView!
    @IBOutlet weak var avatar: CSAvatarView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var peak: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override var message: CSMessageModel! {
        didSet {
            myBackgroundView.layer.cornerRadius = 8
            myBackgroundView.layer.masksToBounds = true
            myBackgroundView.backgroundColor = kAppBubbleRightColor
            if (message.deleted != nil) {
                let dateDeleted: String = message.deleted.toString(format: "yyyy/MM/dd HH:mm:ss")
                myTextMessage.text = String(format: "Message deleted at %@", dateDeleted)
            } else {
                myTextMessage.text = message.message
            }
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
            
            myTextMessage.textColor = UIColor.white
            timeLabel.textColor = kAppMessageFontColor
            if (isShouldShowAvatar) {
                avatar.isHidden = false
                if (message.user != nil && message.user.avatarURL != nil && message.user.avatarURL != "") {
                    avatar.setImageWith(URL(string: message.user.avatarURL)!)
                }
                peak.isHidden = false
            } else {
                avatar.isHidden = true
                peak.isHidden = true
            }
            if (isShouldShowName) {
                nameLabel.text = message.user.name
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
            let it2 = UIMenuItem(title: "Copy", action: #selector(handleCopy(_:)))
            let it3 = UIMenuItem(title: "Delete", action: #selector(handleDelete(_:)))
            menuController.menuItems = [it1, it2, it3]
            menuController.setTargetRect(myTextMessage.frame, in: myTextMessage)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    func handleCopy(_ sender: Any) {
        if (delegate != nil && delegate?.onCopyClicked != nil) {
            delegate?.onCopyClicked(message)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (message.deleted != nil) {
            return false
        }
        if (action == #selector(handleDetails(_:))) {
            return true
        } else if (action == #selector(handleCopy(_:))) {
            return true
        } else if (action == #selector(handleDelete(_:))) {
            return true
        }

        return false
    }

    func handleDelete(_ sender: Any) {
        if (delegate != nil && delegate?.onDeleteClicked != nil) {
            delegate?.onDeleteClicked(message)
        }
    }
}
