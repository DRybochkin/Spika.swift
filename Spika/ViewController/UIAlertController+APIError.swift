//
//  UIAlertController+APIError.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 17.03.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    open class func showError(_ parentController: UIViewController, _ title: String, _ message: String) {
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let actionOk: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOk)
        parentController.present(alert, animated: true, completion: nil)
    }

    open class func showResponseError(_ parentController: UIViewController, _ responseModel: CSResponseModel) {
        showError(parentController, NSLocalizedString("Server Error", tableName: "CSChatLocalization", comment: ""), CSChatErrorCodes.error(forCode: responseModel.code))
    }
    
    open class func showError(_ parentController: UIViewController, _ error: Error) {
        showError(parentController, NSLocalizedString("Server Error", tableName: "CSChatLocalization", comment: ""), error.localizedDescription)
    }
}
