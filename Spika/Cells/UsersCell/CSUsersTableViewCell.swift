//
//  UsersTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
class CSUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var parentView: UIView!
    
    var user: CSUserModel! {
        didSet {
            name.text = user.name
            parentView.backgroundColor = kAppGrayLight(1)
            name.numberOfLines = 1
            background.layer.cornerRadius = 10
            background.layer.masksToBounds = true
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.layer.masksToBounds = true
            avatar.layer.borderColor = kAppDefaultColor(1).cgColor
            avatar.layer.borderWidth = 1.0
            if (user != nil && user.avatarURL != nil && user.avatarURL != "") {
                avatar.sd_setImage(with: URL(string: user.avatarURL))
            }
        }
    }

    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
