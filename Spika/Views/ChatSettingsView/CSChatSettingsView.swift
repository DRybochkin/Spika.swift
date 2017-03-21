//
//  ChatSettingsView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSChatSettingsView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var settingsDelegate: CSChatSettingsViewDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var widthOfTable: NSLayoutConstraint!
    @IBOutlet weak var heightOfTable: NSLayoutConstraint!
    @IBOutlet weak var viewForDismiss: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var items: [Any] {
        didSet {
            heightOfTable.constant = menuHeight()
            tableView.reloadData()
        }
    }
    
    override var frame: CGRect {
        didSet {
            if (contentView != nil) {
                contentView.frame = bounds
            }
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            if (contentView != nil) {
                contentView.backgroundColor = backgroundColor
            }
        }
    }
    
    //override var backgroundView: UIToolbar?
    
    required init?(coder aDecoder: NSCoder) {
        items = []
        
        super.init(coder: aDecoder)
        
        initializeView()
    }
    
    override init(frame: CGRect) {
        items = []

        super.init(frame: frame)
        
        initializeView()
    }

    func initializeView() {
        var className: String = String(describing: type(of: self))
        className = className.replacingOccurrences(of: Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String, with: "")
        className = className.replacingOccurrences(of: ".", with: "")
        let path: String! = Bundle.main.path(forResource: className, ofType: "nib")
        if (!FileManager.default.fileExists(atPath: path)) {
            return
        }
        var array: [Any] = Bundle.main.loadNibNamed(className, owner: self, options: nil)!
        assert(array.count == 1, "Invalid number of nibs")
        addSubview(array[0] as! UIView)
        contentView.frame = bounds
        contentView.backgroundColor = backgroundColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        viewForDismiss.addGestureRecognizer(tap)
    }

    func menuHeight() -> CGFloat {
        var height: CGFloat = 0.0
        let count: Int = self.tableView(tableView, numberOfRowsInSection: 0)
        for i in 0..<count {
            height += tableView(tableView, heightForRowAt: IndexPath(row: i, section: 0))
        }
        return height
    }

    func animateTableView(toOpen: Bool, withMenu menu: CSChatSettingsView) {
        if (toOpen) {
            if (originalRect.isEmpty) {
                originalRect = tableView.frame
            }
            menu.isHidden = false
            tableView.frame = CGRect(x: CGFloat(originalRect.origin.x), y: CGFloat(originalRect.origin.y), width: CGFloat(originalRect.size.width), height: CGFloat(0))
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
                self.tableView.frame = CGRect(x: CGFloat(self.tableView.frame.origin.x), y: CGFloat(self.tableView.frame.origin.y), width: CGFloat(self.tableView.frame.size.width), height: CGFloat(self.originalRect.size.height))
            }, completion: { _ in })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
                self.tableView.frame = CGRect(x: CGFloat(self.tableView.frame.origin.x), y: CGFloat(self.tableView.frame.origin.y), width: CGFloat(self.tableView.frame.size.width), height: CGFloat(0))
            }, completion: {(_ b: Bool) -> Void in
                menu.isHidden = true
            })
        }
    }
    var originalRect = CGRect.zero

    func imageViewTapped(_ gr: UITapGestureRecognizer) {
        settingsDelegate?.onDismissClicked()
    }

    func viewDidLayoutSubviews() {
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: KAppCellType.Settings.rawValue)
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: KAppCellType.Settings.rawValue)
            cell?.textLabel?.text = items[indexPath.row] as? String
            cell?.textLabel?.textAlignment = .center
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        settingsDelegate?.onSettingsClickedPosition(indexPath.row)
    }
}
