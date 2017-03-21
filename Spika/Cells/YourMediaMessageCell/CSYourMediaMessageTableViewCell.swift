//
//  YourMediaMessageTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSYourMediaMessageTableViewCell: CSBaseTableViewCell {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var nameOfFile: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var download: UILabel!
    @IBOutlet weak var avatar: CSAvatarView!
    @IBOutlet weak var peak: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateConstraint: NSLayoutConstraint!

    override var message: CSMessageModel! {
        didSet {
            backView.layer.cornerRadius = 8
            backView.layer.masksToBounds = true
            backView.backgroundColor = kAppBubbleLeftColor
            if (message.messageType == KAppMessageType.Location) {
                nameOfFile.text = message.message
                size.text = "Show location on map."
                download.text = ""
            } else if (message.messageType == KAppMessageType.Contact) {
                let subStrings: [String] = message.message.components(separatedBy: "\n")
                for subString: String in subStrings {
                    if (subString.hasPrefix("FN")) {
                        nameOfFile.text = subString.substring(from: subString.index(subString.startIndex, offsetBy: 3))
                    } else {
                        nameOfFile.text = "no name"
                    }
                }
                size.text = ""
                download.text = ""
            } else {
                nameOfFile.text = message.file.file.name
                size.text = CSUtils.readableFileSize(message.file.file.size)
                download.text = "Download"
            }
            
            nameOfFile.numberOfLines = 1
            nameOfFile.textColor = kAppMessageFontColor
            size.numberOfLines = 1
            size.textColor = kAppMessageFontColor
            download.numberOfLines = 1
            download.textColor = kAppMessageFontColor
            if (message.messageType == KAppMessageType.Location) {
                labelImage.image = UIImage(named: "location_color")
            } else if CSUtils.isMessageAVideo(message) {
                labelImage.image = UIImage(named: "video_color")
            } else if (CSUtils.isMessageAAudio(message)) {
                labelImage.image = UIImage(named: "audio_color")
            } else if (message.messageType == KAppMessageType.Contact) {
                labelImage.image = UIImage(named: "contact_color")
            } else {
                labelImage.image = UIImage(named: "file_color")
            }
            
            timeLabel.text = message.created.toString(format: "H:mm")
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
                nameConstraint.constant = 20.0
            } else {
                nameLabel.text = ""
                nameConstraint.constant = 0.0
            }
            if (isShouldShowDate) {
                dateLabel.text = message.created.toString(format: " d MMMM yyyy ")
                dateConstraint.constant = 20.0
            } else {
                dateLabel.text = ""
                dateConstraint.constant = 0.0
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
            let it1 = UIMenuItem(title: "Details", action: #selector(handleDetails))
            menuController.menuItems = [it1]
            menuController.setTargetRect(labelImage.frame, in: labelImage)
            menuController.setMenuVisible(true, animated: true)
        }
    }
}
