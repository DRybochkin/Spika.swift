//
//  Utils.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//
import Foundation
import CoreGraphics
import UIKit

class CSUtils: NSObject {
    class func getWidthFor(_ label: UILabel!, withFrameSizeWidth maxWidth: CGFloat) -> CGFloat! {
        let maximumSize = CGSize(width: maxWidth, height: CGFloat(FLT_MAX))
        let newFont: UIFont! = UIFont(name: label.font.fontName, size: CGFloat(label.font.pointSize + 2))
        let stringAttributes: [String: Any] = [NSFontAttributeName: newFont ]
        let textViewSize: CGSize! = label.text?.boundingRect(with: maximumSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: stringAttributes, context: nil).size
        label.numberOfLines = Int(textViewSize.height / label.font.lineHeight)
        return textViewSize?.width
    }

    class func getWidthOneLine(for label: UILabel, withFrameSizeWidth maxWidth: CGFloat) -> CGFloat! {
        let maximumSize = CGSize(width: maxWidth, height: CGFloat(FLT_MAX))
        let newFont: UIFont! = UIFont(name: label.font.fontName, size: CGFloat(label.font.pointSize + 2))
        let stringAttributes: [String: Any] = [ NSFontAttributeName : newFont ]
        let textViewSize: CGSize? = label.text?.boundingRect(with: maximumSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: stringAttributes, context: nil).size
        label.numberOfLines = 1
        return textViewSize?.width
    }

    class func generateDownloadURLFormFileId(_ fileId: String) -> String {
        return String(format: "%@%@/%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.FileDownload.rawValue, fileId)
    }

    class func isMessageAnImage(_ message: CSMessageModel) -> Bool {
        if (message.file != nil && message.file.file != nil) {
            if (message.file.file.fileType == KAppMediaType.ImagePNG) {
                return true
            }
            else if (message.file.file.fileType == KAppMediaType.ImageJPG) {
                return true
            }
            else if (message.file.file.fileType == KAppMediaType.ImageGIF) {
                return true
            }
        }

        return false
    }

    class func isMessageAVideo(_ message: CSMessageModel) -> Bool {
        if (message.file != nil && message.file.file != nil) {
            if (message.file.file.fileType == KAppMediaType.VideoMP4) {
                return true
            }
        }
        return false
    }

    class func isMessageAAudio(_ message: CSMessageModel) -> Bool {
        if (message.file != nil && message.file.file != nil) {
            if (message.file.file.fileType == KAppMediaType.AudioMP3) {
                return true
            }
            else if (message.file.file.fileType == KAppMediaType.AudioWAV) {
                return true
            }
        }
        return false
    }

    class func generateUnSeenMessageIds(_ messages: [CSMessageModel]!, user: CSUserModel!) -> [String] {
        var unSeenIds = [String]()
        for item: CSMessageModel in messages {
            var seen: Bool = false
            if (user.userID == item.user.userID) {
                seen = true
            } else {
                if (item.seenBy != nil) {
                    for model in item.seenBy as [CSSeenByModel] {
                        if (model.user.userID == user.userID) {
                            seen = true
                            continue
                        }
                    }
                }
            }
            if (!seen) {
                if (item.id != nil) {
                    unSeenIds.append(item.id)
                }
            }
        }
        return unSeenIds
    }

    class func readableFileSize(_ size: String) -> String {
        var convertedValue: Double! = Double(size)
        var multiplyFactor: Int = 0
        let tokens = ["B", "KB", "MB", "GB", "TB"]
        while (convertedValue > 1024) {
            convertedValue = convertedValue / 1024.0
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }

    class func getFileFrom(_ file: CSFileModel) -> String {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return URL(fileURLWithPath: paths[0] as! String).appendingPathComponent(String(format:"%@",file.file.id)).path
    }

    class func isFileExists(withFileName path: String) -> Bool {
        if (!FileManager.default.fileExists(atPath: path)) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            return false
        }
        var fileAttributes: [AnyHashable: Any]! = try? FileManager.default.attributesOfItem(atPath: path)
        let fileSizeNumber: NSNumber! = fileAttributes[FileAttributeKey.size] as! NSNumber
        let fileSize: Int64 = fileSizeNumber.int64Value
        if (fileSize < 100) {
            return false
        }
        return true
    }

    class func resize(_ image: UIImage, to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newSize.width), height: CGFloat(newSize.height)))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
