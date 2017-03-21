//
//  CSNotificationOverlayQueue.swift
//  SpikaEnterprise
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

typealias EmptyFunction = () -> Void

class CSNotificationOverlayQueue: NSObject {
    var overlaysQueue: [Any] = []
    var foregroundWindow: UIWindow?
    var timer: Timer!
    var visibleView: CSNotificationOverlayView!

    static let shared: CSNotificationOverlayQueue = {
        let instance = CSNotificationOverlayQueue()
        return instance
    }()

    func enqueueOverlayView(_ view: CSNotificationOverlayView!) {
        assert(view != nil, "Invalid parameter not satisfying: view")
        if (__queueContains(view)) {
            return
        }
        overlaysQueue.append(view)
        __refreshVisibleOverlay()
    }

    func cancelOverlay(identifier: String) {
        assert(identifier != "", "Invalid parameter not satisfying: identifier")
        let completion = {
            for i in 0..<self.overlaysQueue.count {
                let object: Any? = self.overlaysQueue[i]
                assert((object is CSNotificationOverlayView), "object must be CSNotificationOverlayView class")
                let view: CSNotificationOverlayView? = (object as? CSNotificationOverlayView)
                if (view?.identifier == identifier) {
                    self.overlaysQueue.remove(at: i)
                }
            }
        }
        __dismissVisibleOverlay(true, completion: completion)
    }

    override init() {
        super.init()

        overlaysQueue = [Any]()
        foregroundWindow = UIWindow(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(CSNotificationOverlayViewHeight)))
        foregroundWindow?.backgroundColor = UIColor.clear
        foregroundWindow?.windowLevel = UIWindowLevelStatusBar
        foregroundWindow?.isHidden = true
    }

    func __queueContains(_ view: CSNotificationOverlayView!) -> Bool {
        assert(view != nil, "Invalid parameter not satisfying: view")
        for obj in overlaysQueue {
            assert((obj is CSNotificationOverlayView), "obj must be CSNotificationOverlayView class")
            let overlay: CSNotificationOverlayView? = (obj as? CSNotificationOverlayView)
            if (overlay?.identifier == view.identifier) {
                return true
            }
        }
        return false
    }

    func __refreshVisibleOverlay() {
        if (visibleView != nil || overlaysQueue.count == 0) {
            return
        }
        let view: CSNotificationOverlayView? = overlaysQueue[0] as? CSNotificationOverlayView
        if (view?.superview != nil) {
            foregroundWindow?.addSubview(view!)
            foregroundWindow?.isHidden = false
        }
        self.visibleView = view
        if (view?.identifier == "message_from_chat") {
            view?.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat((foregroundWindow?.frame.width)!), height: CGFloat(CSNotificationOverlayViewHeight))
            view?.alpha = 0
            foregroundWindow?.frame = CGRect(x: CGFloat(0), y: CGFloat(Float(visibleView.verticalPosition) - Float(CSNotificationOverlayViewHeight)), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(CSNotificationOverlayViewHeight))
        } else {
            foregroundWindow?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(CSNotificationOverlayViewHeight))
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            if (view?.identifier == "message_from_chat") {
                view?.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat((self.foregroundWindow?.frame.width)!), height: CGFloat(CSNotificationOverlayViewHeight))
                view?.alpha = 1
            } else {
                view?.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat((self.foregroundWindow?.frame.width)!), height: CGFloat(CSNotificationOverlayViewHeight))
            }
        }, completion: {(_ finished: Bool) -> Void in
            let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: false)
            self.timer = timer
        })
    }

    func __dismissVisibleOverlay(_ canceled: Bool, completion: EmptyFunction!) {
        // We want to dismiss only views which are not selected.
        if (visibleView.isSelected && !canceled) {
            return
        }
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            if (self.visibleView.identifier == "message_from_chat") {
                self.visibleView?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((self.foregroundWindow?.frame.width)!), height: CGFloat(CSNotificationOverlayViewHeight))
                self.visibleView.alpha = 0
            }
            else {
                self.visibleView?.frame = CGRect(x: CGFloat(0), y: CGFloat(-CSNotificationOverlayViewHeight), width: CGFloat((self.foregroundWindow?.frame.width)!), height: CGFloat(CSNotificationOverlayViewHeight))
            }
        }, completion: {(_ finished: Bool) -> Void in
            self.visibleView?.overlayDidDismiss(canceled)
            var indexOf = -1
            for i in 0..<self.overlaysQueue.count {
                if (self.overlaysQueue[i] as? CSNotificationOverlayView == self.visibleView) {
                    indexOf = i
                }
            }
            self.overlaysQueue.remove(at: indexOf)
            self.visibleView?.removeFromSuperview()
            self.visibleView = nil
            if (completion != nil) {
                completion()
            }
            if (self.overlaysQueue.count == 0) {
                self.foregroundWindow?.isHidden = true
            }
            else {
                self.__refreshVisibleOverlay()
            }
        })
    }

    // MARK: - Timer Selector
    func onTimer(_ sender: Any) {
        timer.invalidate()
        timer = nil
        visibleView.isPreviewTimeExpired = true
        __dismissVisibleOverlay(false, completion: nil)
    }
}
