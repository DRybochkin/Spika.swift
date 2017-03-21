//
//  MessageInfoViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSMessageInfoViewController: CSBaseViewController, UITableViewDelegate, UITableViewDataSource {
    var message: CSMessageModel!

    @IBOutlet weak var senderValue: UILabel!
    @IBOutlet weak var sentAtValue: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteMessageButton: UIButton!

    @IBAction func deleteMessage(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Delete", tableName: "CSChatLocalization", comment: ""), message: NSLocalizedString("Are You sure?", tableName: "CSChatLocalization", comment: ""), preferredStyle: .alert)
        let actionDelete = UIAlertAction(title: NSLocalizedString("Delete", tableName: "CSChatLocalization", comment: ""), style: .destructive, handler: { (_ action: UIAlertAction) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name.SpikaDeleteMessageNotification, object: nil, userInfo: [ paramMessage : self.message ])
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(actionDelete)
        let actionCancel = UIAlertAction(title: NSLocalizedString("NO", tableName: "CSChatLocalization", comment: ""), style: .default, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    convenience init() {
        self.init(message: nil, user: nil)
    }
    
    init(message: CSMessageModel!, user: CSUserModel!) {
        self.message = message
        
        super.init(nibName: "CSMessageInfoViewController", bundle: Bundle.main)

        self.activeUser = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: CSSeenByTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.SeenBy.rawValue)
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        title = "Info"
    }

    func setData() {
        senderValue.text = message.user?.name
        sentAtValue.text = message.created.toString(format: "yyyy/MM/dd HH:mm:ss")
        if (!(activeUser.userID == message.user.userID) || message.messageType == KAppMessageType.NewUser || message.messageType == KAppMessageType.LeaveUser) {
            deleteMessageButton.isHidden = true
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let seenBy: CSSeenByModel! = message.seenBy[indexPath.row]
        let cell: CSSeenByTableViewCell? = tableView.dequeueReusableCell(withIdentifier: KAppCellType.SeenBy.rawValue, for: indexPath) as? CSSeenByTableViewCell
        cell?.seenBy = seenBy
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (message == nil || message.seenBy == nil) {
            return 0
        }
        return message.seenBy.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
}
