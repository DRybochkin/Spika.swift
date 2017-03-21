//
//  ProgressUploadingView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSProgressUploadingView: UIView {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    func changeProgressLabel(_ progress: String, max: String) {
        progressLabel.text = String(format: "%@/%@", CSUtils.readableFileSize(progress), CSUtils.readableFileSize(max))
    }

    func changeProgressView(_ progress: String) {
        progressView.progress = Float(progress)!
    }

    func chageLabelToWaiting() {
        progressView.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        progressLabel.text = "Waiting to response"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeView()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }

    func initializeView() {
        let viewRect: CGRect = UIScreen.main.bounds
        var className: String = String(describing: type(of: self))
        className = className.replacingOccurrences(of: Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String, with: "")
        className = className.replacingOccurrences(of: ".", with: "")
        let path: String? = Bundle.main.path(forResource: className, ofType: "nib")
        if (!FileManager.default.fileExists(atPath: path!)) {
            return
        }
        var array: [UIView]! = Bundle.main.loadNibNamed(className, owner: self, options: nil)! as! [UIView]
        assert(array.count == 1, "Invalid number of nibs")
        frame = viewRect
        let backGR: UIView? = array[0]
        backGR?.frame = viewRect
        addSubview(backGR!)
        uploadingLabel.textColor = kAppDefaultColor(1)
        progressLabel.textColor = kAppDefaultColor(1)
        progressView.progress = 0.0
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        loadingIndicator.color = kAppDefaultColor(1)
        loadingIndicator.isHidden = true
    }
}
