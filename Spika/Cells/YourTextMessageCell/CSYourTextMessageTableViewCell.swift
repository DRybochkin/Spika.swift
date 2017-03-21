//
//  YourTextMessageTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import SDWebImage

class CSYourTextMessageTableViewCell: CSBaseTableViewCell, SDWebImageManagerDelegate {
    @IBOutlet weak var yourTextMessage: UILabel!
    @IBOutlet weak var yourBackground: UIView!
    @IBOutlet weak var avatar: CSAvatarView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var peak: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override var message: CSMessageModel! {
        didSet {
            yourBackground.layer.cornerRadius = 8
            yourBackground.layer.masksToBounds = true
            yourBackground.backgroundColor = kAppBubbleLeftColor
            if (message.deleted != nil) {
                let dateDeleted: String = message.deleted.toString(format: "yyyy/MM/dd HH:mm:ss")
                yourTextMessage.text = String(format: "Message deleted at %@", dateDeleted)
            } else {
                yourTextMessage.text = message.message
            }
            timeLabel.text = message.created.toString(format: "H:mm")
            yourTextMessage.textColor = kAppMessageFontColor
            timeLabel.textColor = kAppMessageFontColor
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
            menuController.menuItems = [it1, it2]
            menuController.setTargetRect(yourTextMessage.frame, in: yourTextMessage)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    func handleCopy(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = message.message
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (message.deleted != nil) {
            return false
        }
        if (action == #selector(handleDetails)) {
            return true
        } else if (action == #selector(handleCopy)) {
            return true
        }

        return false
    }
}
