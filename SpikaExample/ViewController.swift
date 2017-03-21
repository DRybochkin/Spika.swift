//
//  ViewController.swift
//  Spika-iOS
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var isOnOld: Bool = false
    
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var socketTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var avatarUrlTextField: UITextField!
    @IBOutlet weak var roomTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CSCustomConfig.sharedInstance.server_url = "http://192.168.20.250:5000/spika/v1/"
        CSCustomConfig.sharedInstance.socket_url = "ws://192.168.20.250:5000/spika/spika"
        serverTextField.text = CSCustomConfig.sharedInstance.server_url
        socketTextField.text = CSCustomConfig.sharedInstance.socket_url
        userIdTextField.text = UIDevice.current.name
        usernameTextField.text = UIDevice.current.name
        avatarUrlTextField.text = ""
        roomTextField.text = "default"
        serverTextField.isEnabled = false
        socketTextField.isEnabled = false
        serverTextField.textColor = UIColor.lightGray
        socketTextField.textColor = UIColor.lightGray
        isOnOld = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        CSCustomConfig.sharedInstance.server_url = serverTextField.text
        CSCustomConfig.sharedInstance.socket_url = socketTextField.text
        let parameters: [AnyHashable: Any] = [paramUserID: userIdTextField.text!, paramName: usernameTextField.text!, paramAvatarURL: avatarUrlTextField.text!, paramRoomID: roomTextField.text!]
        let viewController = CSChatViewController(parameters: parameters)
        //let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
        //presentViewController.(navigationController, animated: true, completion: nil)
        _ = navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func onEnableConfigSwitch(_ sender: UISwitch) {
        if (sender.isOn && !isOnOld) {
            isOnOld = true
            serverTextField.isEnabled = true
            socketTextField.isEnabled = true
            serverTextField.textColor = UIColor.black
            socketTextField.textColor = UIColor.black
        } else if (!sender.isOn && isOnOld) {
            isOnOld = false
            serverTextField.isEnabled = false
            socketTextField.isEnabled = false
            serverTextField.textColor = UIColor.lightGray
            socketTextField.textColor = UIColor.lightGray
        }
        
    }

}

