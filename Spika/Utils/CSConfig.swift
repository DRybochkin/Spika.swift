//
//  Config.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

#if !Spika_CSConfig_h
    
let kAppWidth = UIScreen.main.bounds.size.width
let kAppHeight = UIScreen.main.bounds.size.height
let kAppFont = "HelveticaNeue"
let kAppFontMessageSize = 17
let kAppMaxImageScaledSize = 1024.0
let kAppGalleryType = 1
    //colors
let kAppDefaultColor = UIColor.kAppDefaultColor
let kAppGrayLight = UIColor.kAppGrayLight
let kAppInfoUserMessageColor = UIColor.kAppInfoUserMessageColor
let kAppBlackColor = UIColor.kAppBlackColor
let kAppMessageFontColor = UIColor(red: CGFloat(76 / 255.0), green: CGFloat(76 / 255.0), blue: CGFloat(76 / 255.0), alpha: CGFloat(255 / 255.0))
let kAppBubbleLeftColor = UIColor(red: CGFloat(235 / 255.0), green: CGFloat(235 / 255.0), blue: CGFloat(235 / 255.0), alpha: CGFloat(255 / 255.0))
let kAppBubbleRightColor = UIColor(red: CGFloat(0 / 255.0), green: CGFloat(158 / 255.0), blue: CGFloat(159 / 255.0), alpha: CGFloat(255 / 255.0))
//API
let kAppBaseUrl = "http://192.168.20.250:5000/spika/v1/"
    enum KAppAPIMethod: String {
        case
        FileDownload = "file/download",
        FileUpload = "file/upload",
        Login = "user/login",
        GetMessages = "message/list",
        GetLatestMessages = "message/latest",
        GetUsersInRoom = "user/list",
        GetStickers = "stickers"
    }
//API parameters
let paramUserID = "userID"
let paramRoomID = "roomID"
let paramName = "name"
let paramId = "id"
let paramAvatarURL = "avatarURL"
let paramType = "type"
let paramLocalID = "localID"
let paramMessage = "message"
let paramMessageID = "messageID"
let paramMessageIDs = "messageIDs"
let paramTOKEN = "TOKEN"
let paramCreated = "created"
let paramFile = "file"
let paramThumb = "thumb"
let paramSize = "size"
let paramMimeType = "mimeType"
let paramResponseObject = "responseObject"
let paramLocation = "location"
let paramLat = "lat"
let paramLng = "lng"
let paramAddress = "address"
    //socket
let kAppSocketURL = "ws://192.168.20.250:5000/spika"

    enum KAppSocket: String {
        case
        Login = "login",
        NewMessage = "newMessage",
        SendTyping = "sendTyping",
        UserLeft = "userLeft",
        MessageUpdated = "messageUpdated",
        SendMessage = "sendMessage",
        DeleteMessage = "deleteMessage",
        OpenMessage = "openMessage",
        Error = "socketerror"
    }

//notification name
let kAppDeleteMessageNotification = NSNotification.Name.SpikaDeleteMessageNotification
let kAppFileUploadedNotification = NSNotification.Name.SpikaFileUploadedNotification
let kAppLocationSelectedNotification = NSNotification.Name.SpikaLocationSelectedNotification
//mime Types
    enum KAppMediaType: String {
        case
        None = "",
        ImageJPG = "image/jpeg",
        ImagePNG = "image/png",
        ImageGIF = "image/gif",
        VideoMP4 = "video/mp4",
        AudioWAV = "audio/wav",
        AudioMP3 = "audio/mp3",
        AnyFile = "application/octet-stream"
    }
//table view cell indentifiers
    enum KAppCellType: String {
        case
        Settings = "settings",
        SeenBy = "seenBy",
        Users = "users",
        MyTextMessage = "myTextMessage",
        UserInfoMessage = "userInfo",
        YourTextMessage = "yourTextMessage",
        YourImageMessage = "yourImageMessage",
        MyImageMessage = "myImageMessage",
        YourMediaMessage = "yourMediaMessage",
        MyMediaMessage = "myMediaMessage",
        YourStickerMessage = "yourStickerMessage",
        MyStickerMessage = "myStickerMessage"
    }

//message types
    enum KAppMessageType: Int {
        case
        None = 0,
        Text = 1,
        File = 2,
        Location = 3,
        Contact = 4,
        Sticker = 5,
        LeaveUser = 1001,
        NewUser = 1000,
        ContactType = 999
    }

//message status
    enum KAppMessageStatus: Int {
        case
        Sent = 1,
        Delivered = 2,
        Received = 0
    }
//typing status
    enum KAppTypingStatus: Int {
        case
        On = 1,
        Off = 0
    }
    //arrays
let kAppMenuSettingsArray = ["Users"]
//Current version as Double
let kAppDeviceVersion = UIDevice.getVersion()
    
#endif
