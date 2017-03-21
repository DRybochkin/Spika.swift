//
//  SE2AudioPlayerView.swift
//  ios-v2-spika-enterprise
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class SE2MessageModel {
    
}

protocol SE2AudioPlayerViewDelegate: NSObjectProtocol {
    func viewInChatSelected()
}

class SE2AudioPlayerView: UIView, AVAudioPlayerDelegate {
    var message: SE2MessageModel!
    var rect = CGRect.zero
    var filePath: String = ""
    var audioPlayer: AVAudioPlayer!
    var updateTimer: Timer!
    var url: String = "" {
        didSet {
            filePath = url
            initAudio()
        }
    }
    weak var delegate: SE2AudioPlayerViewDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationHolderView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var separator: UIView!

    @IBAction func onPlay(_ sender: Any) {
        if (audioPlayer.isPlaying) {
            pausePlaying()
        } else {
            startPlaying()
        }
    }
    
    @IBAction func onSlider(_ sender: Any) {
        audioPlayer.currentTime = TimeInterval(durationSlider.value)
        let currentTime = Int(audioPlayer.currentTime)
        let time = String(format: "%01d:%02d", currentTime / 60, currentTime % 60)
        durationLabel.text = time
    }
    
    @IBAction func onView(inChat sender: Any) {
        if (delegate?.viewInChatSelected != nil) {
            delegate?.viewInChatSelected()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rect = frame

        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initWithNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //frame = rect
    }
    
    func initWithNib() {
        let array = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        var newView: UIView!
        if (array != nil && (array?.count)! > 0) {
            newView = array?[0] as! UIView
        } else {
            return
        }
        newView.frame = bounds
        addSubview(newView)

        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = kAppDefaultColor(1).cgColor
        clipsToBounds = true
        playButton.alpha = 0
        durationHolderView.layer.cornerRadius = durationHolderView.frame.size.height / 2
        durationHolderView.clipsToBounds = true
        durationHolderView.backgroundColor = kAppGrayLight(1)
        durationSlider.minimumTrackTintColor = UIColor.lightGray
        durationSlider.maximumTrackTintColor = kAppGrayLight(1)
        durationLabel.textColor = UIColor.gray
        separator.backgroundColor = kAppGrayLight(1)
    }
    
    func initAudio() {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.playButton.alpha = 1
        }, completion: {(_ finished: Bool) -> Void in
        })
        let soundFile = URL(fileURLWithPath: filePath)
        audioPlayer = try? AVAudioPlayer(contentsOf: soundFile)
        audioPlayer.delegate = self
        durationSlider.maximumValue = Float(audioPlayer.duration)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }

    func pausePlaying() {
        audioPlayer.pause()
        updateTimer.invalidate()
        updateTimer = nil
        playButton.isSelected = false
    }

    func stopPlaying() {
        audioPlayer.stop()
        durationLabel.text = "0:00"
        durationSlider.value = 0
        updateTimer.invalidate()
        updateTimer = nil
        playButton.isSelected = false
    }

    func startPlaying() {
        audioPlayer.play()
        updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        playButton.isSelected = true
    }

    func updateSlider() {
        let progress: Float = Float(audioPlayer.currentTime)
        durationSlider.value = progress
        let currentTime = Int(progress)
        let time = String(format: "%01d:%02d", currentTime / 60, currentTime % 60)
        durationLabel.text = time
    }
}
