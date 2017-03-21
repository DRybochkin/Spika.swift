//
//  ImagePreviewView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSImagePreviewView: CSBasePreviewView {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBAction func onClose(_ sender: Any) {
        dismiss()
    }

    override func initializeView(message: CSMessageModel!, size: Float, dismiss: dismissPreview!) {
        self.dismiss = dismiss
        var viewRect: CGRect = UIScreen.main.bounds
        viewRect.size.height = viewRect.size.height - CGFloat(size)
        var className: String = String(describing: type(of: self))
        className = className.replacingOccurrences(of: Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String, with: "")
        className = className.replacingOccurrences(of: ".", with: "")
        let path: String! = Bundle.main.path(forResource: className, ofType: "nib")
        if (!FileManager.default.fileExists(atPath: path)) {
            return
        }
        var array: [Any]! = Bundle.main.loadNibNamed(className, owner: self, options: nil)
        assert(array.count == 1, "Invalid number of nibs")
        frame = viewRect
        let backGR: UIView! = array[0] as! UIView
        backGR?.frame = viewRect
        addSubview(backGR)
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2
        closeButton.layer.masksToBounds = true
        closeButton.backgroundColor = kAppDefaultColor(0.8)
        backGroundView.layer.cornerRadius = 10
        backGroundView.layer.masksToBounds = true
        setImage(message: message)
    }

    func setImage(path: String) {
        localImage.image = UIImage(contentsOfFile: path)
        localImage.contentMode = .scaleAspectFit
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    
    func setImage(message: CSMessageModel) {
        localImage.layer.cornerRadius = 8
        localImage.layer.masksToBounds = true
        if (message.file.thumb != nil) {
            localImage.sd_setImage(with: URL(string: CSUtils.generateDownloadURLFormFileId(message.file.thumb.id)))
        } else if (message.file.file != nil) {
            localImage.sd_setImage(with: URL(string: CSUtils.generateDownloadURLFormFileId(message.file.file.id)))
        }
    }
}
