//
//  UploadManager.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//
import Foundation
import UIKit
import AFNetworking

typealias fileUploadFinished = (_ responseObject: Any) -> Void
typealias fileUploadError = (_ error: Error) -> Void

class CSUploadManager: NSObject {
    var progressView: CSProgressUploadingView!
    
    func uploadImage(_ imageToPost: UIImage!, fileName: String!, mimeType: KAppMediaType!, parentView: UIView!, finished: fileUploadFinished!, errorCallback: fileUploadError? = nil) {
        if (parentView != nil) {
            progressView = CSProgressUploadingView()
            parentView.addSubview(progressView)
        }
        // 1. Create `AFHTTPRequestSerializer` which will create your request.
        let serializer = AFHTTPRequestSerializer()
        let imageData: Data? = UIImageJPEGRepresentation(imageToPost, 1.0)
        let url: String = String(format: "%@%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.FileUpload.rawValue)
        // 2. Create an `NSMutableURLRequest`.
        let request: URLRequest! = serializer.multipartFormRequest(withMethod: "POST", urlString: url, parameters: nil, constructingBodyWith: {(_ formData: AFMultipartFormData) -> Void in
            formData.appendPart(withFileData: imageData!, name: paramFile, fileName: fileName, mimeType: mimeType.rawValue)
        }, error: nil) as URLRequest!
        // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
        let manager = AFHTTPRequestOperationManager()
        let operation: AFHTTPRequestOperation! = manager.httpRequestOperation(with: request, success: {(_ operation: AFHTTPRequestOperation, _ responseObject: Any) -> Void in
                if (parentView != nil) {
                    self.progressView.removeFromSuperview()
                }
                finished(responseObject)
            }, failure: {(_ operation: AFHTTPRequestOperation, _ error: Error) -> Void in
                print("Failure \(error.localizedDescription)")
                if (parentView != nil) {
                    self.progressView.removeFromSuperview()
                }
                if (errorCallback != nil) {
                    errorCallback!(error)
                }
            })
        // 4. Set the progress block of the operation.
        operation.setUploadProgressBlock({ (_ bytesWritten: UInt, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void in
            if (parentView != nil) {
                self.progressView.changeProgressLabel(String(format: "%d", totalBytesWritten), max: String(format: "%d", totalBytesExpectedToWrite))
                self.progressView.changeProgressView(String(format: "%f", Float(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))))
                if totalBytesWritten >= totalBytesExpectedToWrite {
                    self.progressView.chageLabelToWaiting()
                }
            }
        })
        // 5. Begin!
        operation.start()
    }

    func uploadFile(_ data: Data!, fileName: String, mimeType: KAppMediaType, viewForLoading parentView: UIView!, completition finished: fileUploadFinished!, errorCallback: fileUploadError? = nil) {
        if (parentView != nil) {
            progressView = CSProgressUploadingView()
            parentView.addSubview(progressView)
        }
            // 1. Create `AFHTTPRequestSerializer` which will create your request.
        let serializer = AFHTTPRequestSerializer()
        let url: String = String(format: "%@%@", CSCustomConfig.sharedInstance.server_url, KAppAPIMethod.FileUpload.rawValue)
            // 2. Create an `NSMutableURLRequest`.
        let request: URLRequest! = serializer.multipartFormRequest(withMethod: "POST", urlString: url, parameters: nil, constructingBodyWith: {(_ formData: AFMultipartFormData) -> Void in
                formData.appendPart(withFileData: data, name: paramFile, fileName: fileName, mimeType: mimeType.rawValue)
        }, error: nil) as URLRequest!
            // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
        let manager = AFHTTPRequestOperationManager()
        let operation: AFHTTPRequestOperation! = manager.httpRequestOperation(with: request, success: {(_ operation: AFHTTPRequestOperation, _ responseObject: Any) -> Void in
                if (parentView != nil) {
                    self.progressView.removeFromSuperview()
                }
                finished(responseObject)
            }, failure: {(_ operation: AFHTTPRequestOperation, _ error: Error) -> Void in
                print("Failure \(error.localizedDescription)")
                if (parentView != nil)  {
                    self.progressView.removeFromSuperview()
                }
                if (errorCallback != nil) {
                    errorCallback!(error)
                }
            })
        // 4. Set the progress block of the operation.
        operation.setUploadProgressBlock({(_ bytesWritten: UInt, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void in
            if (parentView != nil) {
                self.progressView.changeProgressLabel(String(format: "%d", totalBytesWritten), max: String(format: "%d", totalBytesExpectedToWrite))
                self.progressView.changeProgressView(String(format: "%f", Float(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))))
                if totalBytesWritten >= totalBytesExpectedToWrite {
                    self.progressView.chageLabelToWaiting()
                }
            }
        })
        // 5. Begin!
        operation.start()
    }
}
