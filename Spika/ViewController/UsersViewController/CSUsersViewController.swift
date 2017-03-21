//
//  UsersViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSUsersViewController: CSBaseViewController, UITableViewDelegate, UITableViewDataSource {
    var roomID: String = ""
    var token: String = ""
    var users: [CSUserModel]!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var parentView: UIView!

    convenience init() {
        self.init(roomID: "", token: "")
    }
    
    init(roomID: String, token: String) {
        self.roomID = roomID
        self.token = token
        
        super.init(nibName: "CSUsersViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        parentView.backgroundColor = kAppGrayLight(1)
        tableView.backgroundColor = kAppGrayLight(1)
        tableView.register(UINib(nibName: "CSUsersTableViewCell", bundle: nil), forCellReuseIdentifier: KAppCellType.Users.rawValue)
        getUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        title = String(format: "Users in %@", roomID)
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: CSUserModel! = users[indexPath.row] 
        let cell: CSUsersTableViewCell! = tableView.dequeueReusableCell(withIdentifier: KAppCellType.Users.rawValue, for: indexPath) as! CSUsersTableViewCell
        cell?.user = user
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (users != nil) {
            return users.count
        }
        return 0
    }

    func getUsers() {
        let url = String(format: "%@%@/%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.GetUsersInRoom.rawValue, roomID)
        CSApiManager.shared.apiGETCall(url: url, vc: self, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            self.users = []
            if (responseModel != nil) {
                let respModel = responseModel!
                if (respModel.code.intValue > 1) {
                    let alert: UIAlertController = UIAlertController.init(title: "Error", message: CSChatErrorCodes.error(forCode: respModel.code), preferredStyle: .alert)
                    let actionOk: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                    alert.addAction(actionOk)
                    self.present(alert, animated: true, completion: nil)
                    return
                } else if (responseModel?.data != nil) {
                    let values: [Any] = Array(respModel.data.values.first as! [Any])
                    for item in values {
                        let itemUser = (try? CSUserModel(dictionary: item as! [AnyHashable: Any]))
                        self.users.append(itemUser!)
                    }
                }
                self.tableView.reloadData()
            } else {
                let alert: UIAlertController = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let actionOk: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alert.addAction(actionOk)
                self.present(alert, animated: true, completion: nil)
           }
        })
    }

    deinit {
        print("dealloc: UsersViewController")
    }
}
