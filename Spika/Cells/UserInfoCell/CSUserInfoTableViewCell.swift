//
//  UserInfoTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSUserInfoTableViewCell: CSBaseTableViewCell {
    @IBOutlet weak var userInfoMessage: UILabel!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var userInfoBackground: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateConstraint: NSLayoutConstraint!

    override var message: CSMessageModel! {
        didSet {
            userInfoMessage.numberOfLines = 0
            userInfoMessage.textColor = kAppInfoUserMessageColor(1)
            let dateCreated: String = message.created != nil ? message.created.toString(format: "dd/MM/yyyy HH:mm:ss") : ""
            var textMessage: String = ""
            if (message.messageType == KAppMessageType.NewUser) {
                textMessage = String(format: "%@\n%@ joined to conversation.", dateCreated, message.user.name)
            } else if (message.messageType == KAppMessageType.LeaveUser) {
                textMessage = String(format: "%@\n%@ left conversation.", dateCreated, message.user.name)
            }
            
            userInfoMessage.text = textMessage
            if (isShouldShowDate) {
                dateLabel.text = message.created != nil ? message.created.toString(format: "d MMMM yyyy") : ""
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
}
