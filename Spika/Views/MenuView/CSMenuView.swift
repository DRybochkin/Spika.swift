//
//  MenuView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

typealias dismissMenu = (_: Void) -> Void

class CSMenuView: UIView, UIGestureRecognizerDelegate {
    var originalRect = CGRect.zero
    var dismiss: dismissMenu?
    weak var delegate: CSMenuViewDelegate?

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var fileButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!

    @IBAction func onCamera(_ sender: Any) {
        delegate?.onCamera()
    }

    @IBAction func onGallery(_ sender: Any) {
        delegate?.onGallery()
    }

    @IBAction func onLocation(_ sender: Any) {
        delegate?.onLocation()
    }

    @IBAction func onFile(_ sender: Any) {
        delegate?.onFile()
    }

    @IBAction func onVideo(_ sender: Any) {
        delegate?.onVideo()
    }

    @IBAction func onContact(_ sender: Any) {
        delegate?.onContact()
    }

    @IBAction func onAudio(_ sender: Any) {
        delegate?.onAudio()
    }

    @IBAction func onCancel(_ sender: Any) {
        animateHide()
    }

    func initialize(parentView: UIView!, dismiss: dismissMenu!) {
        self.dismiss = dismiss
        frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(parentView.frame.size.width), height: CGFloat(parentView.frame.size.height))
        let view: UIView! = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        addSubview(view as UIView)
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        cameraButton.isHidden = true
        galleryButton.isHidden = true
        locationButton.isHidden = true
        fileButton.isHidden = true
        videoButton.isHidden = true
        contactButton.isHidden = true
        originalRect = self.backgroundView.frame
        parentView.addSubview(self)
        animateOpen()
    }

    func animateOpen() {
        backgroundView.alpha = 0.3
        backgroundView.frame = CGRect(x: CGFloat((originalRect.size.width + 8)), y: CGFloat(originalRect.size.height + originalRect.origin.y), width: CGFloat(0), height: CGFloat(0))
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
            self.backgroundView.frame = self.originalRect
            self.backgroundView.alpha = 1.0
        }, completion: {(_ success: Bool) -> Void in
            self.animateButtons()
        })
    }

    func animateHide() {
        animateHideButtons()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
                self.backgroundView.alpha = 0.3
                self.backgroundView.frame = CGRect(x: CGFloat(self.backgroundView.frame.origin.x + self.backgroundView.frame.size.width), y: CGFloat(self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height), width: CGFloat(0), height: CGFloat(0))
            }, completion: {(_ success: Bool) -> Void in
                self.hideButtons()
                self.dismiss!()
            })
        })
    }


    func animateButtons() {
        singleButtonAnimation(cameraButton, delay: 0.0)
        singleButtonAnimation(galleryButton, delay: 0.05)
        singleButtonAnimation(locationButton, delay: 0.1)
        singleButtonAnimation(fileButton, delay: 0.15)
        singleButtonAnimation(videoButton, delay: 0.2)
        singleButtonAnimation(contactButton, delay: 0.25)
    }

    func animateHideButtons() {
        singleButtonHideAnimation(cameraButton, delay: 0.25)
        singleButtonHideAnimation(galleryButton, delay: 0.2)
        singleButtonHideAnimation(locationButton, delay: 0.15)
        singleButtonHideAnimation(fileButton, delay: 0.1)
        singleButtonHideAnimation(videoButton, delay: 0.05)
        singleButtonHideAnimation(contactButton, delay: 0.0)
    }

    func hideButtons() {
        cameraButton.isHidden = true
        galleryButton.isHidden = true
        locationButton.isHidden = true
        fileButton.isHidden = true
        videoButton.isHidden = true
        contactButton.isHidden = true
    }

    func singleButtonAnimation(_ button: UIButton, delay: Float) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(delay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            button.isHidden = false
        })
        button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        button.alpha = 0.3
        UIView.animate(withDuration: 0.3, delay: TimeInterval(delay), options: .curveEaseOut, animations: {() -> Void in
            button.alpha = 0.8
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: {(_ success: Bool) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
                button.alpha = 1.0
                button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in })
        })
    }

    func singleButtonHideAnimation(_ button: UIButton, delay: Float) {
        button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.1, delay: TimeInterval(delay), options: .curveEaseOut, animations: {() -> Void in
            button.alpha = 0.8
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: {(_ success: Bool) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
                button.alpha = 0.0
                button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: {(_ success: Bool) -> Void in
                button.isHidden = true
            })
        })
    }
}
