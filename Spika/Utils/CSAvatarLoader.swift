//
//  CSImageLoaderDelegate.h
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2015 Clover Studio. All rights reserved.
//

import Foundation
import SDWebImage

class CSAvatarLoader: NSObject, SDWebImageManagerDelegate {
    var avatarImageManager: SDWebImageManager!

    static let sharedImage: CSAvatarLoader = {
        let instance = CSAvatarLoader()
        instance.avatarImageManager = SDWebImageManager()
        instance.avatarImageManager?.delegate = instance
        return instance
    }()
    
    class func setImageWith(_ url: URL!, in imageView: UIImageView!) {
        CSAvatarLoader.sharedImage.avatarImageManager.downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: {(_ image: UIImage?, _ error: Error?, _ cacheType: SDImageCacheType, _ finished: Bool, _ imageURL: URL?) -> Void in
            imageView.image = image
        })
    }

    func imageManager(_ imageManager: SDWebImageManager!, image: UIImage!, imageURL: URL!) -> UIImage {
        // Place your image size here
        let width: CGFloat = 256.0
        let height: CGFloat = 256.0
        if (image.size.width < width && image.size.height < height) {
            return image
        }
        let imageSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(imageSize)
        var returnImage: UIImage! = image
        returnImage.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: width, height: height))
        returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnImage
    }
}
