//
//  UploadImagePreviewViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

class CSUploadImagePreviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var mimeType: KAppMediaType = KAppMediaType.None
    var fileName: String = ""
    var type: Int = 0

    private var imageToUpload: UIImage!
    private var scaledImageToUpload: UIImage!

    @IBOutlet weak var imageControllerBackground: UIView!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func onCancel(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func onOk(_ sender: Any) {
        if (scaledImageToUpload != nil) {
            var originalImage = UIImageJPEGRepresentation(imageToUpload, 1)
            let originalButtonTitle: String = String(format: "NO, %d", (originalImage?.count)!)
            var scaledImage = UIImageJPEGRepresentation(scaledImageToUpload, 1)
            let scaledImageSize = Int((scaledImage?.count)!)
            let scaledSizeString: String = CSUtils.readableFileSize(String(format: "%d", scaledImageSize))
            let scaledButtonTitle: String = String(format: "YES, %@", scaledSizeString)
            
            let alert = UIAlertController(title: "Compress image", message: "Do You want to scale image?", preferredStyle: .alert)
            let actionYes = UIAlertAction(title: scaledButtonTitle, style: .default, handler: { (_ action: UIAlertAction) -> Void in
                self.uploadImage(self.scaledImageToUpload)
                })
            alert.addAction(actionYes)
            let actionNo = UIAlertAction(title: originalButtonTitle, style: .default, handler: { (_ action: UIAlertAction) -> Void in
                self.uploadImage(self.imageToUpload)
            })
            alert.addAction(actionNo)
            let actionCancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            uploadImage(imageToUpload)
        }
    }

    convenience init() {
        self.init(type: 0)
    }
    
    init(type: Int) {
        self.type = type
        
        super.init(nibName: "CSUploadImagePreviewViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageControllerBackground.backgroundColor = kAppDefaultColor(1)
        imageControllerBackground.layer.cornerRadius = 10
        imageControllerBackground.layer.masksToBounds = true
        if (type == kAppGalleryType) {
            getImageFromGallery()
        } else {
            getImageFromCamera()
        }
        edgesForExtendedLayout = []
    }

    func getImageFromGallery() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: { _ in })
        } else {
            //TODO Показать диалог о отсутствии разрешения
        }
    }

    func getImageFromCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: { _ in })
        } else {
            //TODO Показать диалог о отсутствии разрешения
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        title = "Preview"
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info.values.count > 0) {
            let imageUrl: URL? = info[UIImagePickerControllerReferenceURL] as? URL
            if (imageUrl != nil) {
                let extensions: String? = imageUrl?.pathExtension
                if ((extensions == "JPG") || (extensions == "jpg")) {
                    mimeType = KAppMediaType.ImageJPG
                } else if ((extensions == "PNG") || (extensions == "png")) {
                    mimeType = KAppMediaType.ImagePNG
                } else if ((extensions == "GIF") || (extensions == "gif")) {
                    mimeType = KAppMediaType.ImageGIF
                } else {
                    mimeType = KAppMediaType.ImageJPG
                }
                fileName = String(format: "image_%ld.%@", Int(Date().timeIntervalSince1970), extensions!);
            } else {
                let imageType: KAppMediaType? = KAppMediaType(rawValue: (info[UIImagePickerControllerMediaType] as? String)!)
                if (imageType != nil && imageType != KAppMediaType.None) {
                    mimeType = imageType!
                }
            }
            
            let image: UIImage! = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageToUpload = image
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            if (Double(image.size.width) > kAppMaxImageScaledSize || Double(image.size.height) > kAppMaxImageScaledSize) {
                let imageWidth: CGFloat! = image?.size.width
                let imageHeight: CGFloat! = image?.size.height
                if (imageWidth >= imageHeight) {
                    let newHeight: CGFloat = CGFloat(kAppMaxImageScaledSize / (Double(imageWidth) / Double(imageHeight)))
                    let newSize = CGSize(width: CGFloat(kAppMaxImageScaledSize), height: newHeight)
                    scaledImageToUpload = CSUtils.resize(image, to: newSize)
                } else {
                    let newWidth: CGFloat = CGFloat(kAppMaxImageScaledSize / (Double(imageHeight) / Double(imageWidth)))
                    let newSize = CGSize(width: newWidth, height: CGFloat(kAppMaxImageScaledSize))
                    scaledImageToUpload = CSUtils.resize(image, to: newSize)
                }
            }
            picker.dismiss(animated: true, completion: {() -> Void in
                print("imagePickerController dissmissed")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func uploadImage(_ image: UIImage) {
        let uploadManager = CSUploadManager()
        uploadManager.uploadImage(image, fileName: fileName, mimeType: mimeType, parentView: view, finished: {(_ responseObject: Any) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
}
