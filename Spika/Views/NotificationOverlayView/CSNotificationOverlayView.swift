//
//  CSNotificationOverlayView.swift
//  SpikaEnterprise
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

let CSNotificationOverlayViewHeight: CGFloat = 68.0

protocol CSNotificationOverlayViewDelegate: NSObjectProtocol {
    func notificationOverlayView(_ view: CSNotificationOverlayView, wasSelected: Bool)
}

typealias CSNotificationOverlayCallback = (_ wasSelected: Bool) -> Void

class CSNotificationOverlayView: UIView {
    var message: String = ""
    var isWasAlreadyTapped: Bool = false
    weak var delegate: CSNotificationOverlayViewDelegate?
    var callbackHandler: CSNotificationOverlayCallback!
    var identifier: String = ""
    var isVisible: Bool = false
    var isPreviewTimeExpired: Bool = false
    var verticalPosition: Int = 0
    
    var isSelected: Bool {
        return contentButton.isTouchInside
    }
    
    override var frame: CGRect {
        didSet {
            if (contentView != nil) {
                contentView.frame = frame
            }
        }
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!

    // MARK: - Button Selectors
    @IBAction func onContent(_ sender: Any) {
        if (isWasAlreadyTapped) {
            return
        }
        isWasAlreadyTapped = true
        if (isPreviewTimeExpired) {
            CSNotificationOverlayQueue.shared.cancelOverlay(identifier: identifier)
            return
        }
        delegate?.notificationOverlayView(self, wasSelected: true)
        if ((callbackHandler) != nil) {
            callbackHandler(true)
        }
        callbackHandler = nil
        CSNotificationOverlayQueue.shared.cancelOverlay(identifier: identifier)
    }

    @IBAction func onContentCancel(_ sender: Any) {
        if (isWasAlreadyTapped) {
            return
        }
        CSNotificationOverlayQueue.shared.cancelOverlay(identifier: identifier)
    }

    // MARK: - Initialization
    class func notificationOverlay(message: String, identifier: String, delegate: CSNotificationOverlayViewDelegate) -> CSNotificationOverlayView {
        assert(message != "", "Invalid parameter not satisfying: message != \"\"")
        assert(identifier != "", "Invalid parameter not satisfying: identifier != \"\"")
        let view: CSNotificationOverlayView! = CSNotificationOverlayView(frame: CGRect(x: CGFloat(0), y: CGFloat(-CSNotificationOverlayViewHeight), width: CGFloat(UIScreen.main.bounds.width), height: CSNotificationOverlayViewHeight))
        view.message = message
        view.identifier = identifier
        view.delegate = delegate
        CSNotificationOverlayQueue.shared.enqueueOverlayView(view)
        return view
    }

    class func notificationOverlay(message: String, identifier: String, block: CSNotificationOverlayCallback?) -> CSNotificationOverlayView {
        assert(message != "", "Invalid parameter not satisfying: message != \"\"")
        assert(identifier != "", "Invalid parameter not satisfying: identifier != \"\"")
        let view: CSNotificationOverlayView! = CSNotificationOverlayView(frame: CGRect(x: CGFloat(0), y: CGFloat(-CSNotificationOverlayViewHeight), width: CGFloat(UIScreen.main.bounds.width), height: CSNotificationOverlayViewHeight))
        view.message = message
        view.identifier = identifier
        view.callbackHandler = block
        CSNotificationOverlayQueue.shared.enqueueOverlayView(view)
        return view
    }

    class func notificationOverlayFromChat( message: String, verticalPosition: Int, block: CSNotificationOverlayCallback?) -> CSNotificationOverlayView {
        assert(message != "", "Invalid parameter not satisfying: message != \"\"")
        let view: CSNotificationOverlayView! = CSNotificationOverlayView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.width), height: CSNotificationOverlayViewHeight))
        view.message = message
        view.identifier = "message_from_chat"
        view.callbackHandler = block
        view.verticalPosition = verticalPosition
        CSNotificationOverlayQueue.shared.enqueueOverlayView(view)
        return view
    }

    // MARK: - Apperance
    func overlayDidDismiss(_ canceled: Bool) {
        if (!canceled) {
            delegate?.notificationOverlayView(self, wasSelected: false)
            if (callbackHandler != nil) {
                callbackHandler(false)
            }
            callbackHandler = nil
        }
        delegate = nil
    }

    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    func initialize() {
        var array: [Any]! = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(array[0] as! UIView)
        messageLabel.text = self.message
        contentButton.backgroundColor = kAppBlackColor(0.5)
        contentView.autoresizingMask = ([.flexibleWidth, .flexibleHeight])
    }

    // MARK: - Apperance
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.text = self.message
        contentView.autoresizingMask = ([.flexibleWidth, .flexibleHeight])
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        messageLabel.text = message
        //    self.messageLabel.hidden = YES;
        //    self.iconImageView.hidden = YES;
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
