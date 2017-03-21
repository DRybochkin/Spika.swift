//
//  BaseViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
//import AFNetworking

class CSBaseViewController: UIViewController {
    var loadingIndicator: UIActivityIndicatorView!
    var indicatorBackground: UIView!
    var sizeOfView = CGRect.zero
    var activeUser: CSUserModel!

    func setSelfViewSizeFrom(_ frame: CGRect) {
        sizeOfView = frame
    }

    func showIndicator() {
        if (loadingIndicator == nil) {
            indicatorBackground = UIView()
            indicatorBackground.frame = sizeOfView
            indicatorBackground.backgroundColor = kAppBlackColor(0.4)
            view.addSubview(indicatorBackground)
            indicatorBackground.bringSubview(toFront: view)
            loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            loadingIndicator.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(40.0), height: CGFloat(40.0))
            loadingIndicator.center = indicatorBackground.center
            indicatorBackground.addSubview(loadingIndicator)
            loadingIndicator.bringSubview(toFront: indicatorBackground)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        loadingIndicator.tag = 1
    }

    func hideIndicator() {
        if (loadingIndicator != nil) {
            loadingIndicator.tag = 0
            loadingIndicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            indicatorBackground.isHidden = true
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setSelfViewSizeFrom(UIScreen.main.bounds)
        // Do any additional setup after loading the view.
        edgesForExtendedLayout = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
