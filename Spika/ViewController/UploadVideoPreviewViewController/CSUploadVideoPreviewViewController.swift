//
//  UploadVideoPreviewViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class CSUploadVideoPreviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var filePath: String = ""
    var moviePlayer: MPMoviePlayerController!
    var videoData: Data!
    var fileName: String = ""
    var mimeType: KAppMediaType = KAppMediaType.None
    
    @IBOutlet weak var firstButtonsView: UIView!
    @IBOutlet weak var secondButtonsView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var okButton: UIButton!
    
    @IBAction func onGalleryClicked(_ sender: Any) {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
            present(picker, animated: true, completion: { _ in })
        } else {
            //TODO Показать сообщение о недоступности камеры
        }
    }

    @IBAction func onCameraClicked(_ sender: Any) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie as String]
            present(picker, animated: true, completion: { _ in })
        } else {
            //TODO Показать сообщение о недоступности камеры
        }
    }

    @IBAction func onCancelClicked(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func onOkClicked(_ sender: Any) {
        let manager = CSUploadManager()
        manager.uploadFile(videoData, fileName: fileName, mimeType: mimeType, viewForLoading: view, completition: {(_ responseObject: Any) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            _ = self.navigationController?.popViewController(animated: true)
        }, errorCallback: { (_ error: Error) -> Void in
            UIAlertController.showError(self, error)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.backgroundColor = kAppDefaultColor(1)
        videoView.layer.cornerRadius = 10
        videoView.layer.masksToBounds = true
        edgesForExtendedLayout = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
        super.viewDidDisappear(animated)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoUrl: URL? = info[UIImagePickerControllerMediaURL] as? URL
        let path: String? = videoUrl?.path
        videoData = FileManager.default.contents(atPath: path!)
        mimeType = KAppMediaType.VideoMP4
        fileName = String(format: "video_%d.mp4",Int(Date().timeIntervalSince1970))
        filePath = path!
        changeButtonsLayout()
        picker.dismiss(animated: true, completion: {() -> Void in
        })
        playVideo()
    }

    func changeButtonsLayout() {
        firstButtonsView.isHidden = true
        secondButtonsView.isHidden = false
        let sizeString: String = String(format: "%d", videoData.count)
        okButton.setTitle(String(format: "Ok, %@", CSUtils.readableFileSize(sizeString)), for: .normal)
    }

    func playVideo() {
        moviePlayer = MPMoviePlayerController(contentURL: URL(fileURLWithPath: filePath))
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlaybackComplete), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
        moviePlayer.allowsAirPlay = true
        var videoViewRect: CGRect = videoView.frame
        videoViewRect.origin.x = videoViewRect.origin.x + 20
        videoViewRect.origin.y = videoViewRect.origin.y + 20
        videoViewRect.size.height = videoViewRect.size.height - 60
        videoViewRect.size.width = videoViewRect.size.width - 60
        moviePlayer.view.frame = videoViewRect
        videoView.addSubview(moviePlayer.view)
        moviePlayer.play()
    }

    func moviePlaybackComplete(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer)
    }
}
