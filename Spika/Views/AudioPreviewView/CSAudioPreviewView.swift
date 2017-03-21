//
//  AudioPreviewView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class CSAudioPreviewView: CSBasePreviewView, AVAudioPlayerDelegate {
    var filePath: String = ""
    var audioPlayer: AVAudioPlayer!
    var updateTimer: Timer!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var fileName: UILabel!

    @IBAction func onPlayClicked(_ sender: Any) {
        if (audioPlayer.isPlaying) {
            stopPlaying()
        } else {
            startPlaying()
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        stopPlaying()
        dismiss()
    }
    
    @IBAction func seekTime(_ sender: Any) {
        if (audioPlayer != nil){
            audioPlayer.currentTime = Double(slider.value)
            let currentTime = Int(audioPlayer.currentTime)
            let time = String(format: "%02d:%02d", currentTime / 60, currentTime % 60)
            timeLabel.text = time
        }
    }

    override func initializeView(message: CSMessageModel!, size: Float, dismiss: dismissPreview!) {
        self.dismiss = dismiss
        self.message = message
        var viewRect: CGRect = UIScreen.main.bounds
        viewRect.size.height = viewRect.size.height - CGFloat(size)
        var className: String = String(describing: type(of: self))
        className = className.replacingOccurrences(of: Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String, with: "")
        className = className.replacingOccurrences(of: ".", with: "")
        let path: String? = Bundle.main.path(forResource: className, ofType: "nib")
        if (!FileManager.default.fileExists(atPath: path!)) {
            return
        }
        var array: [Any]! = Bundle.main.loadNibNamed(className, owner: self, options: nil)!
        assert(array.count == 1, "Invalid number of nibs")
        frame = viewRect
        let backGR: UIView! = array[0] as! UIView
        backGR?.frame = viewRect
        addSubview(backGR)
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2
        closeButton.layer.masksToBounds = true
        closeButton.backgroundColor = kAppDefaultColor(0.8)
        timeLabel.textColor = kAppDefaultColor(0.8)
        fileName.textColor = kAppDefaultColor(0.8)
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        fileName.text = message.file.file.name
        timeLabel.text = "00:00"
        filePath = CSUtils.getFileFrom(message.file)
        playButton.isEnabled = false
        slider.minimumValue = 0
        slider.value = 0
        if (!CSUtils.isFileExists(withFileName: filePath)) {
            let downloadManager = CSDownloadManager()
            downloadManager.downloadFile(with: URL(string: CSUtils.generateDownloadURLFormFileId(message.file.file.id)), destination: URL(string: filePath), viewForLoading: self, completition: {(_ success: Bool) -> Void in
                self.initAudio()
            })
        } else {
            initAudio()
        }
    }

    func initAudio() {
        let soundFile = URL(fileURLWithPath: filePath)
        audioPlayer = try? AVAudioPlayer(contentsOf: soundFile)
        if (audioPlayer != nil) {
            audioPlayer.delegate = self
            slider.maximumValue = Float(audioPlayer.duration)
            playButton.isEnabled = true
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }

    func stopPlaying() {
        if (audioPlayer != nil){
            audioPlayer.stop()
            playButton.setImage(UIImage(named: "play"), for: .normal)
            timeLabel.text = "00:00"
            slider.value = 0
            if (updateTimer != nil) {
                updateTimer.invalidate()
                updateTimer = nil
            }
        }
    }

    func startPlaying() {
        if (audioPlayer != nil){
            audioPlayer.play()
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
    }

    func updateSlider() {
        if (audioPlayer != nil) {
            let progress: Float = Float(audioPlayer.currentTime)
            slider.value = progress
            let currentTime = Int(progress)
            let time = String(format: "%02d:%02d", currentTime / 60, currentTime % 60)
            timeLabel.text = time
        }
    }
}
