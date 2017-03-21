//
//  VideoPreviewView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import MediaPlayer
//import AFNetworking

class CSVideoPreviewView: CSBasePreviewView {
    var filePath: String = ""
    var moviePlayer: MPMoviePlayerController!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backGroundView: UIView!

    @IBAction func onClose(_ sender: Any) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
        dismiss()
    }

    override func initializeView(message: CSMessageModel!, size: Float, dismiss: dismissPreview!) {
        self.dismiss = dismiss
        self.message = message
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
        filePath = CSUtils.getFileFrom(message.file)
        if (!CSUtils.isFileExists(withFileName: filePath)) {
            let downloadManager = CSDownloadManager()
            downloadManager.downloadFile(with: URL(string: CSUtils.generateDownloadURLFormFileId(message.file.file.id)), destination: URL(string: filePath), viewForLoading: self, completition: {(_ success: Bool) -> Void in
                self.playVideo()
            })
        } else {
            playVideo()
        }
    }

    func playVideo() {
        moviePlayer = MPMoviePlayerController(contentURL: URL(fileURLWithPath: filePath))
        if (moviePlayer != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(moviePlaybackComplete), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
            moviePlayer.allowsAirPlay = true
            var videoViewRect: CGRect = frame
            videoViewRect.origin.x = videoViewRect.origin.x + 20
            videoViewRect.origin.y = videoViewRect.origin.y + 20
            videoViewRect.size.height = videoViewRect.size.height - 90
            videoViewRect.size.width = videoViewRect.size.width - 90
            moviePlayer.view.frame = videoViewRect
            backGroundView.addSubview(moviePlayer.view)
            moviePlayer.play()
        }
    }

    func moviePlaybackComplete(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
    }
}
