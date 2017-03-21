//
//  ChatViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import MobileCoreServices
import Contacts

class CSChatViewController: CSBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CSChatSettingsViewDelegate, CSCellClickedDelegate, UIDocumentInteractionControllerDelegate, CSMenuViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CSChatSocketControllerDelegate, ABPeoplePickerNavigationControllerDelegate, CSStickerDelegate {
    var parameters = [AnyHashable: Any]()
    var isLoading: Bool = false
    var titleView: CSTitleView!
    var indicator: UIActivityIndicatorView!
    var stickerList: CSStickerListModel!
    var token: String = ""
    var messages: [CSMessageModel]! = [CSMessageModel]()
    var tempSentMessagesLocalId: [String] = []
    var typingUsers: [CSUserModel] = []
    var lastDataLoadedFromNet: [CSMessageModel]! = []
    var isTyping: Bool = false
    var documentController: UIDocumentInteractionController!
    var menuView: CSMenuView!
    var stickerView: CSStickerView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var etMessage: UITextField!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var chatsettingsView: CSChatSettingsView!
    @IBOutlet weak var footerView: UIView!

    @IBAction func changedText(inTextField sender: Any) {
        //    if(etMessage.text.length > 0 && isTyping == NO){
        //        isTyping = YES;
        //        [self sendTypingWithType:[NSString stringWithFormat:@"%d", kAppTypingStatusON]];
        //    }else if(etMessage.text.length == 0 && isTyping == YES){
        //        isTyping = NO;
        //        [self sendTypingWithType:[NSString stringWithFormat:@"%d", kAppTypingStatusOFF]];
        //    }
    }

    @IBAction func sendMessage(_ sender: Any) {
        if (!isTyping) {
            openMenu()
            return
        }
        let message: String! = etMessage.text
        let messageModel = CSMessageModel.createMessage(user: activeUser, message: message, type: KAppMessageType.Text, file: nil, location: nil)
        tempSentMessagesLocalId.append(messageModel.localID)
        didSentMessage(messageModel)
        etMessage.text = ""
        changeEditing(etMessage)
        isTyping = false
        let parameters: [AnyHashable: Any] = CSEmitJsonCreator.createEmitSendMessage(messageModel, andUser: activeUser, andMessage: message, andFile: nil, andLocation: nil)
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendMessage, args: array)
    }

    @IBAction func onStickerButton(_ sender: Any) {
        etMessage.resignFirstResponder()
        stickerView = CSStickerView(parentView: view, delegate: self, stickers: stickerList)
    }

    @IBAction func changeEditing(_ sender: Any) {
        if ((etMessage.text?.characters.count)! > 0 && isTyping == false) {
            isTyping = true
            sendTyping(withType: KAppTypingStatus.On)
            sendButton.setImage(UIImage(named: "send_btn"), for: .normal)
        } else if (etMessage.text?.characters.count == 0 && isTyping == true) {
            isTyping = false
            sendTyping(withType: KAppTypingStatus.Off)
            sendButton.setImage(UIImage(named: "attach_btn"), for: .normal)
        }

    }

    convenience init() {
        self.init(parameters: [:])
    }
    
    init(parameters: [AnyHashable: Any]) {
        self.parameters = parameters
        
        super.init(nibName: "CSChatViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //    navigationController.navigationBar.translucent = NO;
        //    navigationController.navigationBar.barTintColor = kAppDefaultColor(1);
        navigationController?.navigationBar.tintColor = kAppBubbleRightColor
        //    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        tableView.estimatedRowHeight = 44
        tableView.transform = CGAffineTransform(rotationAngle: -.pi)
        tableView.register(UINib(nibName: String(describing: CSMyTextMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.MyTextMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSUserInfoTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.UserInfoMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSYourTextMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.YourTextMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSYourImageMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.YourImageMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSMyImageMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.MyImageMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSYourMediaMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.YourMediaMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSMyMediaMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.MyMediaMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSYourStickerMessageCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.YourStickerMessage.rawValue)
        tableView.register(UINib(nibName: String(describing: CSMyStickerMessageCell.self), bundle: nil), forCellReuseIdentifier: KAppCellType.MyStickerMessage.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteMessage), name: NSNotification.Name.SpikaDeleteMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendFileMessage), name: NSNotification.Name.SpikaFileUploadedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLocationMessage), name: NSNotification.Name.SpikaLocationSelectedNotification, object: nil)
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(44), height: CGFloat(44))
        indicator.hidesWhenStopped = true
        tableView.tableFooterView = indicator
        tableView.backgroundColor = UIColor.white
        messages = [CSMessageModel]()
        tempSentMessagesLocalId = [String]()
        typingUsers = [CSUserModel]()
        lastDataLoadedFromNet = [CSMessageModel]()
        stickerList = CSStickerListModel()
        activeUser = try? CSUserModel(dictionary: parameters)
        login(parameters)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleView = CSTitleView()
        titleView?.title = activeUser.roomID
        titleView?.subTitle = activeUser.name
        navigationItem.titleView = titleView
        let anotherButton = UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(onSettingsClicked))
        navigationItem.rightBarButtonItem = anotherButton
        let array: [Any] = kAppMenuSettingsArray
        chatsettingsView.items = array
        chatsettingsView.isHidden = true
        chatsettingsView.settingsDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardIsMoving), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func keyboardIsMoving(_ aNotification: Notification) {
        var info: [AnyHashable: Any]? = aNotification.userInfo
        let kbSize: CGRect! = info?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        if (kbSize.origin.y == kAppHeight) {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.bottomMargin.constant = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.bottomMargin.constant = kbSize.size.height
            })
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if (token.characters.count > 0) {
            connectToSocket()
            let lastMessage: CSMessageModel? = messages.first
            getLatestMessages((lastMessage?.id)!)
        }
    }

    func applicationDidEnterBackground(_ notification: Notification) {
        CSSocketController.shared.close()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
// MARK: - socket method

    func connectToSocket() {
        let parametersLogin: [AnyHashable: Any] = activeUser.toDictionary()
        CSSocketController.shared.register(parametersLogin: parametersLogin, delegate: self)
    }

    func didReceiveNewMessage(_ message: CSMessageModel) {
        if (navigationController == nil || footerView == nil) {
            return
        }
        let navBarHeight: CGFloat! = navigationController?.navigationBar.frame.size.height
        if (tableView.contentOffset.y > 0) {
            let verticalPosition: Int! = Int(navBarHeight + UIApplication.shared.statusBarFrame.size.height + footerView.frame.origin.y)
            _ = CSNotificationOverlayView.notificationOverlayFromChat(message: "new message", verticalPosition: verticalPosition, block: {(_ wasSelected: Bool) -> Void in
                if wasSelected {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
        }
        
        if (message.localID != nil && tempSentMessagesLocalId.contains(message.localID)) {
            tempSentMessagesLocalId.remove(at: tempSentMessagesLocalId.index(of: message.localID) ?? -1)
            for item: CSMessageModel in messages {
                if (item.localID != nil && (item.localID == message.localID)) {
                    item.messageStatus = KAppMessageStatus.Delivered
                    item.id = message.id
                    item.created = message.created
                    break
                }
            }
            tableView.reloadData()
        } else {
            if (tableView.contentOffset.y > 0) {
                tableView.beginUpdates()
                messages.insert(message, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                tableView.endUpdates()
            } else {
                messages.insert(message, at: 0)
                tableView.reloadData()
            }
            if (message.user.userID != activeUser.userID) {
                var openMessage = [Any]()
                openMessage.append(message.id)
                sendOpenMessages(openMessage)
            }
        }
    }

    func didReceiveTyping(_ typing: CSTypingModel) {
        if (typing.user.userID == activeUser.userID) {
            return
        }
        if (typing.typingType == KAppTypingStatus.Off) {
            _ = isUserAlreadyTyping(typing.user)
            generateTypingLabel()
        } else {
            typingUsers.append(typing.user)
            generateTypingLabel()
        }
    }

    func didUserLeft(_ user: CSUserModel) {
        _ = isUserAlreadyTyping(user)
        generateTypingLabel()
    }

    func didSentMessage(_ sentMessage: CSMessageModel) {
        tableView.beginUpdates()
        messages.insert(sentMessage, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        tableView.endUpdates()
    }

    func didMessageUpdated(_ updatedMessages: [CSMessageModel]!) {
        for item: CSMessageModel in messages {
            for itemNew: CSMessageModel in updatedMessages {
                if (item.id == itemNew.id) {
                    item.updateMessage(withData: itemNew)
                    continue
                }
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Sticker Delegate
    func onSticker(_ stickerUrl: String) {
        sendSticker(stickerUrl)
    }
    
    // MARK: - send messages socket api
    func sendSticker(_ stickerUrl: String) {
        let messageModel = CSMessageModel.createMessage(user: activeUser, message: stickerUrl, type: KAppMessageType.Sticker, file: nil, location: nil)
        tempSentMessagesLocalId.append(messageModel.localID)
        didSentMessage(messageModel)
        let parameters: [AnyHashable: Any] = CSEmitJsonCreator.createEmitSendMessage(messageModel, andUser: activeUser, andMessage: stickerUrl, andFile: nil, andLocation: nil)
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendMessage, args: array)
    }

    func sendContact(_ vCard: String) {
        let messageModel = CSMessageModel.createMessage(user: activeUser, message: vCard, type: KAppMessageType.Contact, file: nil, location: nil)
        tempSentMessagesLocalId.append(messageModel.localID)
        didSentMessage(messageModel)
        let parameters: [AnyHashable: Any] = CSEmitJsonCreator.createEmitSendMessage(messageModel, andUser: activeUser, andMessage: vCard, andFile: nil, andLocation: nil)
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendMessage, args: array)
    }

    func sendFileMessage(_ notificationData: Notification) {
        if (menuView != nil) {
            menuView.animateHide()
        }
        var dict: [AnyHashable: Any]! = notificationData.userInfo
        let response: [AnyHashable: Any]! = dict[paramResponseObject] as! [AnyHashable: Any]
        let responseModel = try? CSResponseModel(dictionary: response)
        let resultModel = try? CSFileModel(dictionary: responseModel?.data)
        let messageModel = CSMessageModel.createMessage(user: activeUser, message: "", type: KAppMessageType.File, file: resultModel, location: nil)
        tempSentMessagesLocalId.append(messageModel.localID)
        didSentMessage(messageModel)
        let parameters: [AnyHashable: Any] = CSEmitJsonCreator.createEmitSendMessage(messageModel, andUser: activeUser, andMessage: "", andFile: resultModel, andLocation: nil)
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendMessage, args: array)
    }

    func sendLocationMessage(_ notificationData: Notification) {
        if (menuView != nil) {
            menuView.animateHide()
        }
        var dict: [AnyHashable: Any]! = notificationData.userInfo
        let response: CSLocationModel! = dict[paramLocation] as! CSLocationModel
        let address: String! = dict[paramAddress] as! String
        let messageModel = CSMessageModel.createMessage(user: activeUser, message: address, type: KAppMessageType.Location, file: nil, location: response)
        tempSentMessagesLocalId.append(messageModel.localID)
        didSentMessage(messageModel)
        let parameters: [AnyHashable: Any] = CSEmitJsonCreator.createEmitSendMessage(messageModel, andUser: activeUser, andMessage: address, andFile: nil, andLocation: response)
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendMessage, args: array)
    }

    func deleteMessage(notificationData: Notification) {
        var dict: [AnyHashable: Any]! = notificationData.userInfo
        let messageToDelete: CSMessageModel! = dict[paramMessage] as! CSMessageModel
        if (messageToDelete.id != nil) {
            let parameters: [AnyHashable: Any] = [paramUserID: activeUser.userID, paramMessageID: messageToDelete.id]
            let array: [Any] = [parameters]
            CSSocketController.shared.emit(KAppSocket.DeleteMessage, args: array)
        }
    }

    func sendTyping(withType type: KAppTypingStatus) {
        let parameters: [AnyHashable: Any] = [paramRoomID: activeUser.roomID, paramUserID: activeUser.userID, paramType: type.rawValue]
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.SendTyping, args: array)
    }

    func sendOpenMessages(_ messageIds: [Any]) {
        let parameters: [AnyHashable: Any] = [paramMessageIDs: messageIds, paramUserID: activeUser.userID]
        let array: [Any] = [parameters]
        CSSocketController.shared.emit(KAppSocket.OpenMessage, args: array)
    }

    // MARK: - api data
    func login(_ parameters: [AnyHashable: Any]) {
        let urlLogin: String = String(format: "%@%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.Login.rawValue)
        CSApiManager.shared.apiPOSTCall(url: urlLogin, params: parameters, vc: self, toShow: true, toHide: false, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            if (responseModel != nil) {
                if ((responseModel?.code.intValue)! > 1) {
                    UIAlertController.showResponseError(self, responseModel!)
                    return
                } else if (responseModel?.data != nil) {
                    let login: CSLoginResult! = try? CSLoginResult(dictionary: responseModel?.data)
                    self.token = login.token
                    CSApiManager.shared.accessToken = self.token
                    self.connectToSocket()
                    self.getMessages()
                    self.getStickers()
                } else {
                    //Возможно потребуется показать неизвестную ошибку
                }
                self.tableView.reloadData()
            } else {
                UIAlertController.showError(self, error!)
            }
        })
    }

    func getMessages() {
        let url = String(format: "%@%@/%@/0", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.GetMessages.rawValue, activeUser.roomID)
        CSApiManager.shared.apiGETCall(url: url, vc: self, toShow: false, toHide: true, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            if (responseModel != nil) {
                if ((responseModel?.code.intValue)! > 1) {
                    UIAlertController.showResponseError(self, responseModel!)
                    return
                } else if (responseModel?.data != nil) {
                    let messages: CSGetMessages! = (try? CSGetMessages(dictionary: responseModel?.data))
                    self.lastDataLoadedFromNet.removeAll()
                    self.lastDataLoadedFromNet.append(contentsOf: messages.messages)
                    self.messages.append(contentsOf: messages.messages)
                    self.sortMessages()
                    self.tableView.reloadData()
                    //send unseen messages
                    let unSeenMessages: [Any] = CSUtils.generateUnSeenMessageIds(messages.messages, user: self.activeUser)
                    self.sendOpenMessages(unSeenMessages)
                } else {
                    //Возможно потребуется показать неизвестную ошибку
                }
                self.tableView.reloadData()
            } else {
                UIAlertController.showError(self, error!)
            }
        })
    }

    func getMessagesWithLastMessageId(_ lastMessageId: String) {
        let url = String(format: "%@%@/%@/%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.GetMessages.rawValue, activeUser.roomID, lastMessageId)
        CSApiManager.shared.apiGETCall(url: url, vc: self, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            if (responseModel != nil) {
                if ((responseModel?.code.intValue)! > 1) {
                    UIAlertController.showResponseError(self, responseModel!)
                    return
                } else if (responseModel?.data != nil) {
                    let messages: CSGetMessages! = (try? CSGetMessages(dictionary: responseModel?.data))
                    self.lastDataLoadedFromNet.removeAll()
                    self.lastDataLoadedFromNet.append(contentsOf: messages.messages)
                    self.messages.append(contentsOf: messages.messages)
                    self.sortMessages()
                    self.tableView.reloadData()
                    self.isLoading = false
                    self.indicator.stopAnimating()
                } else {
                    //Возможно потребуется показать неизвестную ошибку
                }
                self.tableView.reloadData()
            } else {
                UIAlertController.showError(self, error!)
            }
        })
    }

    func getLatestMessages(_ lastMessageId: String) {
        let url = String(format: "%@%@/%@/%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.GetLatestMessages.rawValue, activeUser.roomID, lastMessageId)
        CSApiManager.shared.apiGETCall(url: url, vc: self, toShow: false, toHide: true, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            if (responseModel != nil) {
                if ((responseModel?.code.intValue)! > 1) {
                    UIAlertController.showResponseError(self, responseModel!)
                    return
                } else if (responseModel?.data != nil) {
                    let messages: CSGetMessages! = (try? CSGetMessages(dictionary: responseModel?.data))
                    self.lastDataLoadedFromNet.removeAll()
                    self.lastDataLoadedFromNet.append(contentsOf: messages.messages)
                    self.messages.append(contentsOf: messages.messages)
                    self.sortMessages()
                    self.tableView.reloadData()
                    //send unseen messages
                    let unSeenMessages: [Any] = CSUtils.generateUnSeenMessageIds(messages.messages, user: self.activeUser)
                    self.sendOpenMessages(unSeenMessages)
                } else {
                    //Возможно потребуется показать неизвестную ошибку
                }
                self.tableView.reloadData()
            } else {
                UIAlertController.showError(self, error!)
            }
        })
    }

    func sortMessages() {
        let sortDescriptor = NSSortDescriptor(key: paramCreated, ascending: false)
        NSMutableArray(array: messages).sort(using: [sortDescriptor])
        NSMutableArray(array: lastDataLoadedFromNet).sort(using: [sortDescriptor])
    }

    func getStickers() {
        let url = String(format: "%@%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.GetStickers.rawValue)
        CSApiManager.shared.apiGETCall(url: url, finish: {(_ responseModel: CSResponseModel?, _ error: Error?) -> Void in
            if (responseModel != nil) {
                if ((responseModel?.code.intValue)! > 1) {
                    UIAlertController.showResponseError(self, responseModel!)
                    return
                } else if (responseModel?.data != nil) {
                    self.stickerList = try? CSStickerListModel(dictionary: responseModel?.data)
                    if (self.stickerView != nil) {
                        self.stickerView.stickerList = self.stickerList
                    }
                } else {
                    //Возможно потребуется показать неизвестную ошибку
                }
                self.tableView.reloadData()
            } else {
                UIAlertController.showError(self, error!)
            }
        })
    }
// MARK: - UI HELPERS

    func generateTypingLabel() {
        if (typingUsers.count < 1) {
            titleView.subTitle = activeUser.name
        } else if (typingUsers.count == 1) {
            let user: CSUserModel! = typingUsers[0]
            titleView.subTitle = String(format: NSLocalizedString("%@ is typing...", tableName: "CSChatLocalization", comment: ""), user.name)
        } else {
            var text: String = ""
            for item: CSUserModel in typingUsers {
                text = text.appendingFormat("%@, ", item.name)
            }
            text = text.substring(to: text.index(text.endIndex, offsetBy: -2))
            titleView.subTitle = String(format: NSLocalizedString("%@ is typing...", tableName: "CSChatLocalization", comment: ""), text)
        }

    }

    func isUserAlreadyTyping(_ user: CSUserModel) -> Bool {
        for item: CSUserModel in typingUsers {
            if (item.userID == user.userID) {
                typingUsers.remove(at: typingUsers.index(of: item) ?? -1)
                return true
            }
        }
        return false
    }
    
    // MARK: - table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message: CSMessageModel! = messages[indexPath.row]
        var cell: CSBaseTableViewCell!
        if (message.deleted != nil) {
            if (message.user.userID == activeUser.userID) {
                print("identifier-1: kAppMyTextMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.MyTextMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            } else {
                print("identifier-2: kAppYourTextMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.YourTextMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            }
        } else if ((message.user.userID == activeUser.userID) && (message.messageType == KAppMessageType.Text)) {
            print("identifier-3: kAppMyTextMessageCell")
            cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.MyTextMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
        } else if ((message.user.userID == activeUser.userID) && (message.messageType == KAppMessageType.File || message.messageType == KAppMessageType.Location || message.messageType == KAppMessageType.Contact)) {
            if (CSUtils.isMessageAnImage(message)) {
                print("identifier-4: kAppMyImageMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.MyImageMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            } else {
                print("identifier-5: kAppMyMediaMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.MyMediaMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            }
        } else if (message.messageType == KAppMessageType.NewUser || message.messageType == KAppMessageType.LeaveUser) {
            print("identifier-6: kAppUserInfoMessageCell")
            cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.UserInfoMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
        }
        else if (message.messageType == KAppMessageType.Text) {
            print("identifier-7: kAppYourTextMessageCell")
            cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.YourTextMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
        }
        else if (message.messageType == KAppMessageType.File || message.messageType == KAppMessageType.Location || message.messageType == KAppMessageType.Contact) {
            if (CSUtils.isMessageAnImage(message)) {
                print("identifier-8: kAppYourImageMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.YourImageMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            } else {
                print("identifier-9: kAppYourMediaMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.YourMediaMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            }
        } else if (message.messageType == KAppMessageType.Sticker || message.messageType == KAppMessageType.None) {
            print("KAppMessageType.Sticker = \(message.messageType)")
            if (message.user.userID == activeUser.userID) {
                print("identifier-10: kAppMyStickerMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.MyStickerMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            } else {
                print("identifier-11: kAppYourStickerMessageCell")
                cell = tableView.dequeueReusableCell(withIdentifier: KAppCellType.YourStickerMessage.rawValue, for: indexPath) as! CSBaseTableViewCell
            }
        }

        let messageAfter: CSMessageModel! = messages[max(indexPath.row - 1, 0)]
        cell.isShouldShowAvatar = !(message.userID == messageAfter.userID) || indexPath.row == 0 || messageAfter.messageType == KAppMessageType.NewUser || messageAfter.messageType == KAppMessageType.LeaveUser
        let messageBefore: CSMessageModel! = messages[max(min(indexPath.row + 1, messages.count - 1), 0)]
        cell.isShouldShowName = !(message.userID == messageBefore?.userID) || indexPath.row == (messages.count - 1) || messageBefore.messageType == KAppMessageType.NewUser || messageBefore.messageType == KAppMessageType.LeaveUser
        cell.isShouldShowDate = (!Calendar.current.isDate(message.created, inSameDayAs: messageBefore.created) || indexPath.row == messages.count - 1) && message.created != nil
        cell.message = message
        cell.delegate = self
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message: CSMessageModel! = messages[indexPath.row]
        if (message.deleted != nil) {
            return
        }
        if (message.messageType == KAppMessageType.File) {
            navigationController?.navigationBar.isUserInteractionEnabled = false
            let navigationHeight: Float = Float((navigationController?.navigationBar.frame.size.height)!)
            let statusHeight: Float = Float(UIApplication.shared.statusBarFrame.size.height)
            if (CSUtils.isMessageAnImage(message)) {
                let previewView = CSImagePreviewView()
                view.addSubview(previewView)
                previewView.initializeView(message: message, size: (statusHeight + navigationHeight), dismiss: {(_: Void) -> Void in
                    previewView.removeFromSuperview()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                })
            } else if (CSUtils.isMessageAVideo(message)) {
                let previewView = CSVideoPreviewView()
                view.addSubview(previewView)
                previewView.initializeView(message: message, size: (statusHeight + navigationHeight), dismiss: {(_: Void) -> Void in
                    previewView.removeFromSuperview()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                })
            } else if (CSUtils.isMessageAAudio(message)) {
                let previewView = CSAudioPreviewView()
                view.addSubview(previewView)
                previewView.initializeView(message: message, size: (statusHeight + navigationHeight), dismiss: {(_: Void) -> Void in
                    previewView.removeFromSuperview()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                })
            } else {
                let filePath: String! = CSUtils.getFileFrom(message.file)
                if (!CSUtils.isFileExists(withFileName: filePath)) {
                    let downloadManager = CSDownloadManager()
                    downloadManager.downloadFile(with: URL(string: CSUtils.generateDownloadURLFormFileId((message.file.file.id)!)), destination: URL(string: filePath), viewForLoading: view, completition: {(_ succes: Bool) -> Void in
                        self.openDocument(filePath)
                    })
                } else {
                    openDocument(filePath)
                }
            }
        }
        else if (message.messageType == KAppMessageType.Location) {
            let controller = CSMapViewController(message: message)
            navigationController?.pushViewController(controller, animated: true)
        } else if (message.messageType == KAppMessageType.Contact) {
            if #available(iOS 9.0, *) {
                let store = CNContactStore()
                let status = CNContactStore.authorizationStatus(for: .contacts)
                if (status == .notDetermined) {
                    store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: Error?) -> Void in
                        if (authorized) {
                            self.addContact(toAddressBook: indexPath.row)
                        }
                    })
                } else if (status == .authorized) {
                    addContact(toAddressBook: indexPath.row)
                } else {
                    UIAlertController.showError(self, NSLocalizedString("Privacy error", tableName: "CSChatLocalization", comment: ""), NSLocalizedString("Go to\nSettings > Privacy > Contacts\nand enable access", tableName: "CSChatLocalization", comment: ""))
                }
            } else {
                var error : Unmanaged<CFError>? = nil
                let addressBook: ABAddressBook! = ABAddressBookCreateWithOptions(nil, &error) as ABAddressBook
                if (addressBook != nil) {
                    let status = ABAddressBookGetAuthorizationStatus()
                    if (status == ABAuthorizationStatus.notDetermined) {
                        ABAddressBookRequestAccessWithCompletion(nil, {(_ granted: Bool, _ error: CFError?) -> Void in
                            DispatchQueue.main.async {
                                if (granted) {
                                    self.addContact(toAddressBook: indexPath.row)
                                }
                            }
                        })
                    }
                    else if (status == ABAuthorizationStatus.authorized) {
                    } else {
                        UIAlertController.showError(self, NSLocalizedString("Privacy error", tableName: "CSChatLocalization", comment: ""), NSLocalizedString("Go to\nSettings > Privacy > Contacts\nand enable access", tableName: "CSChatLocalization", comment: ""))
                    }
                } else {
                    print("\(error)")
                }
            }
        }

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            if !isLoading {
                onRefresh()
            }
        }
    }

    func openDocument(_ filePath: String) {
        documentController = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
        documentController.delegate = self
        documentController.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)
    }

    func onRefresh() {
        var lastMessageId: String = "0"
        if (lastDataLoadedFromNet.count > 0) {
            isLoading = true
            indicator.startAnimating()
                //        tableView.tableFooterView.hidden = NO;
            let lastMessage: CSMessageModel! = lastDataLoadedFromNet.last! as CSMessageModel
            lastMessageId = lastMessage.id
            getMessagesWithLastMessageId(lastMessageId)
        }
    }

    func onSettingsClicked() {
        chatsettingsView.animateTableView(toOpen: chatsettingsView.isHidden, withMenu: chatsettingsView)
    }

    func onSettingsClickedPosition(_ position: Int) {
        if (position == 0) {
            let viewController = CSUsersViewController(roomID: activeUser.roomID, token: token)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func onDismissClicked() {
        onSettingsClicked()
    }
    
    //delegates from cells
    func onInfoClicked(_ message: CSMessageModel) {
        let messageInfo = CSMessageInfoViewController(message: message, user: activeUser)
        navigationController?.pushViewController(messageInfo, animated: true)
    }
    
    func onDeleteClicked(_ message: CSMessageModel) {
        let alert: UIAlertController = UIAlertController.init(title: "Delete", message: "Are You sure?", preferredStyle: .alert)
        let actionOk: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (_ action: UIAlertAction) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name.SpikaDeleteMessageNotification, object: nil, userInfo: [ paramMessage : message ])
        })
        alert.addAction(actionOk)
        let actionCancel: UIAlertAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }

    func onCopyClicked(_ message: CSMessageModel) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = message.message
    }
    
    // MARK: - menu
    func openMenu() {
        etMessage.resignFirstResponder()
        if (menuView == nil) {
            menuView = CSMenuView()
            menuView.initialize(parentView: view, dismiss: {(_: Void) -> Void in
                self.menuView.removeFromSuperview()
                self.menuView = nil
            })
            menuView.delegate = self
        }
    }

    func onCamera() {
        let controller = CSUploadImagePreviewViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    func onGallery() {
        let controller = CSUploadImagePreviewViewController(type: kAppGalleryType)
        navigationController?.pushViewController(controller, animated: true)
    }

    func onLocation() {
        let controller = CSMapViewController(height: 50)
        navigationController?.pushViewController(controller, animated: true)
    }

    func onFile() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeAudio as String, kUTTypeImage as String, kUTTypeMP3 as String]
        present(picker, animated: true, completion: { _ in })
    }

    func onVideo() {
        let controller = CSUploadVideoPreviewViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    func onContact() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        present(picker, animated: true, completion: { _ in })
    }

    func onAudio() {
        let controller = CSRecordAudioViewController()
        _ = navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - file picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType: String! = (info[UIImagePickerControllerMediaType] as? String)
        if (mediaType == kUTTypeImage as String) {
            uploadImage(info)
        } else if (mediaType == kUTTypeMovie as String) {
            uploadVideo(info)
        } else if (mediaType == kUTTypeVideo as String) {
            uploadVideo(info)
        } else {
            uploadOtherFile(info)
        }

        picker.dismiss(animated: true, completion: {() -> Void in
        })
    }

    func uploadImage(_ data: [AnyHashable: Any]) {
        let imageUrl: URL! = data[UIImagePickerControllerReferenceURL] as! URL
        let extensions: String! = imageUrl.pathExtension
        var mimeType: KAppMediaType
        if ((extensions == "JPG") || (extensions == "jpg")) {
            mimeType = KAppMediaType.ImageJPG
        } else if ((extensions == "PNG") || (extensions == "png")) {
            mimeType = KAppMediaType.ImagePNG
        } else if ((extensions == "GIF") || (extensions == "gif")) {
            mimeType = KAppMediaType.ImageGIF
        } else {
            mimeType = KAppMediaType.ImageJPG
        }

        let fileName: String = String(format:"image_%d%@", Int(Date().timeIntervalSince1970), extensions)
        let image: UIImage! = data[UIImagePickerControllerOriginalImage] as! UIImage
        let uploadManager = CSUploadManager()
        uploadManager.uploadImage(image, fileName: fileName, mimeType: mimeType, parentView: view, finished: {(_ responseObject: Any) -> Void in
            let note = Notification(name: Notification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            self.sendFileMessage(note)
        })
    }

    func uploadVideo(_ data: [AnyHashable: Any]) {
        let videoUrl: URL! = data[UIImagePickerControllerMediaURL] as! URL
        let path: String! = videoUrl.path
        let videoData: Data? = FileManager.default.contents(atPath: path)
        let fileName: String = String(format: "video_%d%.mp4", Int(Date().timeIntervalSince1970))
        let manager = CSUploadManager()
        manager.uploadFile(videoData, fileName: fileName, mimeType: KAppMediaType.VideoMP4, viewForLoading: view, completition: {(_ responseObject: Any) -> Void in
            let note = Notification(name: Notification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            self.sendFileMessage(note)
        }, errorCallback: { (_ error: Error) -> Void in
            UIAlertController.showError(self, error)
        })
    }

    func uploadOtherFile(_ data: [AnyHashable: Any]) {
        let videoUrl: URL! = data[UIImagePickerControllerMediaURL] as! URL
        let path: String! = videoUrl.path
        let videoData: Data? = FileManager.default.contents(atPath: path)
        let fileName: String = String(format: "%d_%@", Int(Date().timeIntervalSince1970), videoUrl.lastPathComponent)
        let manager = CSUploadManager()
        manager.uploadFile(videoData, fileName: fileName, mimeType: KAppMediaType.AnyFile, viewForLoading: view, completition: {(_ responseObject: Any) -> Void in
            let note = Notification(name: Notification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            self.sendFileMessage(note)
        }, errorCallback: { (_ error: Error) -> Void in
            UIAlertController.showError(self, error)
        })
    }
    
    // MARK: - socket delegate
    func socketDidReceiveNewMessage(_ message: CSMessageModel) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.didReceiveNewMessage(message)
        })
    }

    func socketDidReceiveTyping(_ typing: CSTypingModel) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.didReceiveTyping(typing)
        })
    }

    func socketDidReceiveUserLeft(_ userLeft: CSUserModel) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.didUserLeft(userLeft)
        })
    }

    func socketDidReceiveMessageUpdated(_ updatedMessages: [CSMessageModel]) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.didMessageUpdated(updatedMessages)
        })
    }

    func socketDidReceiveError(_ errorCode: NSNumber) {
        DispatchQueue.main.async(execute: {() -> Void in
            UIAlertController.showError(self, NSLocalizedString("Socket error", tableName: "CSChatLocalization", comment: ""), CSChatErrorCodes.error(forCode: errorCode))
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("dealloc: ChatViewController")
    }
    
    // MARK: - adress book delegate

    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        let peopleArray: CFArray = [person] as CFArray
        let vCardData: Data = ABPersonCreateVCardRepresentationWithPeople(peopleArray).takeRetainedValue() as Data
        let vCard = String(data: vCardData, encoding: String.Encoding.utf8)
        print("vCard > \(vCard)")
        sendContact(vCard!)
        if (menuView != nil) {
            menuView.animateHide()
        }
    }

    func peoplePickerNavigationControllerDidCancel(_ peoplePicker: ABPeoplePickerNavigationController) {
        if (menuView != nil) {
            menuView.animateHide()
        }
    }

    func addContact(toAddressBook index: Int) {
        let alert = UIAlertController(title: NSLocalizedString("Add to contacts", tableName: "CSChatLocalization", comment: ""), message: NSLocalizedString("Do you want add this contact to address book?", tableName: "CSChatLocalization", comment: ""), preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: { (_ action: UIAlertAction) -> Void in
            let vCardString = self.messages[index].message
            self.saveVCardContacts(vCard: (vCardString?.data(using: String.Encoding.utf8))!)
        })
        alert.addAction(actionOk)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "CSChatLocalization", comment: ""), style: .default, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveVCardContacts (vCard : Data) {
        if #available(iOS 9.0, *) {
            let contactStore = CNContactStore()
            do {
                let saveRequest = CNSaveRequest()
                let contacts = try CNContactVCardSerialization.contacts(with: vCard)
                var mutablePerson: CNMutableContact
                for person in contacts{
                    let oldPerson = findContact(person)
                    if (oldPerson != nil) {
                        mutablePerson = oldPerson?.mutableCopy() as! CNMutableContact
                        mutablePerson.phoneNumbers.append(contentsOf: person.phoneNumbers)
                        mutablePerson.emailAddresses.append(contentsOf: person.emailAddresses)
                        saveRequest.update(mutablePerson)
                    } else {
                        mutablePerson = person.mutableCopy() as! CNMutableContact
                        saveRequest.add(mutablePerson, toContainerWithIdentifier: nil)
                    }
                }
                try contactStore.execute(saveRequest)
            } catch  {
                UIAlertController.showError(self, NSLocalizedString("Contact error", tableName: "CSChatLocalization", comment: ""), NSLocalizedString("Add or update contact error", tableName: "CSChatLocalization", comment: ""))
                print("Unable to show the new contact")
            }
        } else {
            UIAlertController.showError(self, NSLocalizedString("Contact error", tableName: "CSChatLocalization", comment: ""), NSLocalizedString("CNContact not supported", tableName: "CSChatLocalization", comment: ""))
            print("CNContact not supported.")
            /*
             Падает на ABAddressBookCopyDefaultSource 
             if (alertView.buttonTitle(at: buttonIndex) == NSLocalizedString("OK", comment: "")) {
                let vCardData: CFData! = vCardString!.data(using: String.Encoding.utf8) as! CFData
                var error : Unmanaged<CFError>? = nil
                let addressBook: ABAddressBook! = ABAddressBookCreateWithOptions(nil, &error) as ABAddressBook
                let defaultSource: ABRecord! = ABAddressBookCopyDefaultSource(addressBook).takeRetainedValue()
                let vCardPeople: CFArray = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData) as! CFArray
                for index in 0..<CFArrayGetCount(vCardPeople) {
                    let person: ABRecord = CFArrayGetValueAtIndex(vCardPeople, index) as ABRecord
                    ABAddressBookAddRecord(addressBook, person, nil)
                }
                ABAddressBookSave(addressBook, nil)
             }
             */
        }
    }
    
    @available(iOS 9.0, *)
    func findContact(_ newContact: CNContact) -> CNContact? {
        let contactStore = CNContactStore()
        let request = CNContactFetchRequest(keysToFetch: [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
            ])
        var result: CNContact? = nil
        do {
            
            try contactStore.enumerateContacts(with: request) { contact, stop in
                for email in contact.emailAddresses {
                    let found = newContact.emailAddresses.contains { el in
                        return (el.value == email.value)
                    }
                    if (found) {
                        result = contact
                        return
                    }
                }
                for phone in contact.phoneNumbers {
                    let found = newContact.emailAddresses.contains { el in
                        return (el.value == phone.value)
                    }
                    if (found) {
                        result = contact
                        return
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return result
    }
}
