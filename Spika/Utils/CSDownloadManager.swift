//
//  DownloadManager.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking

typealias fileDownloadFinished = (_ success: Bool) -> Void

class CSDownloadManager: NSObject {
    var progressView: CSProgressLoadingView!

    func downloadFile(with url: URL!, destination: URL!, viewForLoading parentView: UIView!, completition finished: fileDownloadFinished!) {
        if (parentView != nil) {
            progressView = CSProgressLoadingView()
            parentView.addSubview(progressView)
        }
        let request = URLRequest(url: url)
        let operation: AFURLConnectionOperation! = AFHTTPRequestOperation(request: request)
        operation.outputStream = OutputStream(toFileAtPath: destination.path, append: false)
        operation.setDownloadProgressBlock({(_ bytesRead: UInt, _ totalBytesRead: Int64, _ totalBytesExpectedToRead: Int64) -> Void in
            if (parentView != nil) {
                self.progressView.changeProgressLabel(onMainThread: String(format: "%d", totalBytesRead), max: String(format: "%d", totalBytesExpectedToRead))
                self.progressView.changeProgressView(onMainThread: String(format: "%f", Float(Float(totalBytesRead) / Float(totalBytesExpectedToRead))))
            }
        })
        operation.completionBlock = {() -> Void in
            if (parentView != nil) {
                self.progressView.removeFromSuperview()
            }
            finished(true)
        }
        operation.start()
    }
}
