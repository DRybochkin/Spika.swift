//
//  CSApiManager.swift
//  ios-v2-spika-enterprise
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2016 Clover Studio. All rights reserved.
//
import Foundation
import AFNetworking

typealias apiCallFinish = (_ responseModel: CSResponseModel?, _ error: Error?) -> Void

class CSApiManager: NSObject {
    var manager: AFHTTPRequestOperationManager!

    var accessToken: String {
        didSet {
            manager.requestSerializer.setValue(accessToken, forHTTPHeaderField: "access-token")
        }
    }

    static let shared: CSApiManager = {
        var instance: CSApiManager! = nil
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if (instance == nil) {
                instance = CSApiManager()
            }
        }
        return instance
    }()

    func apiGETCall(url: String, finish: apiCallFinish!) {
        apiGETCall(url: url, vc: nil, toShow: false, toHide: false, finish: finish)
    }

    func apiGETCall(url: String, vc: CSBaseViewController!, finish: apiCallFinish!) {
        apiGETCall(url: url, vc: vc, toShow: true, toHide: true, finish: finish)
    }

    func apiGETCall(url: String, vc: CSBaseViewController!, toShow: Bool, toHide: Bool, finish: apiCallFinish!) {
        if (toShow) {
            vc.showIndicator()
        }
        manager.get(url, parameters: nil, success: {(_ operation: AFHTTPRequestOperation, _ responseObject: Any) -> Void in
            if (toHide) {
                vc.hideIndicator()
            }
            let responseModel: CSResponseModel! = try? CSResponseModel(dictionary: responseObject as! [AnyHashable: Any])
            if (responseModel.code.intValue > 1) {
                print("error \(url)")
            } else {
                print("success \(url)")
            }
            finish(responseModel, nil)
        }, failure: {(_ operation: AFHTTPRequestOperation?, _ error: Error) -> Void in
            vc.hideIndicator()
            print("fail \(url)")
            finish(nil, error)
        })
    }

    func apiPOSTCall(url: String, params: [AnyHashable: Any], finish: apiCallFinish!) {
        apiPOSTCall(url: url, params: params, vc: nil, toShow: false, toHide: false, finish: finish)
    }

    func apiPOSTCall(url: String, params: [AnyHashable: Any]!, vc: CSBaseViewController!, finish: apiCallFinish!) {
        apiPOSTCall(url: url, params: params, vc: vc, toShow: false, toHide: false, finish: finish)
    }

    func apiPOSTCall(url: String, params: [AnyHashable: Any]!, vc: CSBaseViewController!, toShow: Bool, toHide: Bool, finish: apiCallFinish!) {
        if toShow {
            vc.showIndicator()
        }
        manager.post(url, parameters: params, success: {(_ operation: AFHTTPRequestOperation, _ responseObject: Any) -> Void in
            if toHide {
                vc.hideIndicator()
            }
            let responseModel: CSResponseModel! = try? CSResponseModel(dictionary: responseObject as! [AnyHashable: Any])
            if (responseModel.code.intValue > 1) {
                print("error \(url)")
            } else {
                print("success \(url)")
            }
            finish(responseModel, nil)
        }, failure: {(_ operation: AFHTTPRequestOperation?, _ error: Error) -> Void in
            vc.hideIndicator()
            print("fail \(url)")
            finish(nil, error)
        })
    }


    override init() {
        accessToken = ""
        
        super.init()

        // init code
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
