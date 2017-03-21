//
//  SeenByTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
class CSSeenByTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var timeWidth: NSLayoutConstraint!
    @IBOutlet weak var nameWidth: NSLayoutConstraint!
    
    var seenBy: CSSeenByModel! {
        didSet {
            let widthWindow: Float? = Float((window?.frame.size.width)!)
            let widthName: Float = 32.0 / 100.0 * widthWindow!
                //32% of cell
            let widthTime: Float = 53.0 / 100.0 * widthWindow!
            //53% of cell
            nameWidth.constant = CGFloat(widthName)
            name.text = seenBy.user?.name
            timeWidth.constant = CGFloat(widthTime)
            let dateSeen: String = seenBy.at.toString(format: "yyyy/MM/dd HH:mm:ss")
            time.text = dateSeen
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.layer.masksToBounds = true
            avatar.layer.borderColor = UIColor.white.cgColor
            avatar.layer.borderWidth = 1.0
            if (seenBy.user.avatarURL != nil && seenBy.user.avatarURL != "") {
                avatar.sd_setImage(with: URL(string: (seenBy.user.avatarURL)!))
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
