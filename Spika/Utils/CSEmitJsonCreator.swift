//
//  EmitJsonCreator.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//
import Foundation
class CSEmitJsonCreator: NSObject {
    class func createEmitSendMessage(_ message: CSMessageModel!, andUser user: CSUserModel!, andMessage messageTxt: String, andFile file: CSFileModel!, andLocation locationModel: CSLocationModel!) -> [AnyHashable: Any] {
        var params = [AnyHashable: Any]()
        params[paramRoomID] = user.roomID
        params[paramUserID] = user.userID
        params[paramType] = message.type
        params[paramLocalID] = message.localID
        params[paramMessage] = messageTxt
        if (file != nil) {
            var fileDict = [AnyHashable: Any]()
            let fileInside: [AnyHashable: Any] = [paramId: file.file.id, paramName: file.file.name, paramSize: file.file.size, paramMimeType: file.file.mimeType]
            fileDict[paramFile] = fileInside
            if (file.thumb != nil) {
                let thumbInside: [AnyHashable: Any] = [paramId: file.thumb.id, paramName: file.thumb.name, paramSize: file.thumb.size, paramMimeType: file.thumb.mimeType]
                fileDict[paramThumb] = thumbInside
            }
            params[paramFile] = fileDict
        }
        if (locationModel != nil) {
            let locationDict: [AnyHashable: Any] = [paramLat: NSNumber(value: locationModel.lat), paramLng: NSNumber(value: locationModel.lng)]
            params[paramLocation] = locationDict
        }
        return params
    }
}
