//
//  BaseTableViewCell.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
class CSBaseTableViewCell: UITableViewCell {
    var message: CSMessageModel!
    weak var delegate: CSCellClickedDelegate?
    var isShouldShowAvatar: Bool = false
    var isShouldShowName: Bool = false
    var isShouldShowDate: Bool = false
    var lpgr: UILongPressGestureRecognizer!

    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    func handleLongPressGestures(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            sender.view?.becomeFirstResponder()
            let menuController = UIMenuController.shared
            let it = UIMenuItem(title: "Details", action: #selector(handleDetails(_:)))
            menuController.menuItems = [it]
        }
    }

    func handleDetails(_ sender: Any) {
        print("Action triggered, however need some way to refer the tapped cell")
        if (delegate != nil && delegate?.onInfoClicked != nil) {
            delegate?.onInfoClicked(self.message)
        }
    }

    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        
        selectionStyle = UITableViewCellSelectionStyle.none
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestures(_:)))
        addGestureRecognizer(lpgr)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func canPerformAction(_ action: Selector, withSender sender: Any) -> Bool? {
        if (message.deleted != nil) {
            return false
        }
        if (action == #selector(handleDetails(_:))) {
            return true
        }
        return false
    }
}
