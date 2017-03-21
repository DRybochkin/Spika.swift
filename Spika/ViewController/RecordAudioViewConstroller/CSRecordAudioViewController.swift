//
//  RecordAudioViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import AVFoundation

class CSRecordAudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var recorder: AVAudioRecorder!
    var updateTimer: Timer!
    var recordTimer: Timer!
    var audioData: Data!
    var pulseTimer: Timer!
    var audioPlayer: SE2AudioPlayerView!
    var isRecording: Bool = false
    var isRecordAllowed: Bool = false
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var expandingGreenBackgroundView: UIView!
    @IBOutlet weak var pulastingView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var expandingGreenHeight: NSLayoutConstraint!
    @IBOutlet weak var expandingGreenWidth: NSLayoutConstraint!
    @IBOutlet weak var pulsatingHight: NSLayoutConstraint!
    @IBOutlet weak var pulsatingWidth: NSLayoutConstraint!
    @IBOutlet weak var audioPlayerView: SE2AudioPlayerView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var playLabel: UILabel!

    @IBAction func onRecord(_ sender: Any) {
        if (!isRecordAllowed) {
            if (kAppDeviceVersion >= 8.0) {
                AVAudioSession.sharedInstance().requestRecordPermission( { [unowned self] allowed in
                    self.isRecordAllowed = allowed
                    if (allowed) {
                        self.onRecord(sender)
                    } else {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        } else if (isRecordAllowed) {
            if (!isRecording) {
                isRecording = true
                animateView()
                animateAudioPlayer(false)
                let session = AVAudioSession.sharedInstance()
                try? session.setActive(true)
                // Start recording
                recorder.record()
            } else {
                // Pause recording
                let audioSession = AVAudioSession.sharedInstance()
                try? audioSession.setActive(false)
                if (recordTimer != nil) {
                    recordTimer.invalidate()
                    recordTimer = nil
                }
                if (pulseTimer != nil) {
                    pulseTimer.invalidate()
                    pulseTimer = nil
                }
                animateReverseColor()
                recorder.stop()
                isRecording = false
            }
        }
    }

    @IBAction func onCancelClicked(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func onOkClicked(_ sender: Any) {
        let fileName: String = String(format: "audio_%d.wav", Int(Date().timeIntervalSince1970))
        let data = try? Data(contentsOf: recorder.url)
        let manager = CSUploadManager()
        manager.uploadFile(data!, fileName: fileName, mimeType: KAppMediaType.AudioWAV, viewForLoading: view, completition: {(_ responseObject: Any) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name.SpikaFileUploadedNotification, object: nil, userInfo: [ paramResponseObject : responseObject ])
            _ = self.navigationController?.popViewController(animated: true)
        }, errorCallback: { (_ error: Error) -> Void in
            UIAlertController.showError(self, error)
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let pathComponent = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last?.appending("/MyAudioMemo.m4a")
        let outputFileURL = URL(fileURLWithPath: pathComponent!)
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        // Define the recorder setting
        let recordSetting = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: Int(44100.0), AVNumberOfChannelsKey: Int(2)]
        // Initiate and prepare the recorder
        recorder = try? AVAudioRecorder(url: outputFileURL, settings: recordSetting)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()
        audioView.backgroundColor = UIColor.white
        audioView.layer.masksToBounds = true
        playButton.layer.cornerRadius = playButton.frame.size.height / 2
        playButton.layer.borderWidth = 2.0
        playButton.layer.borderColor = kAppDefaultColor(1).cgColor
        playLabel.textColor = kAppDefaultColor(1)
        playLabel.alpha = 0.0
        expandingGreenBackgroundView.layer.cornerRadius = expandingGreenBackgroundView.frame.size.height / 2
        expandingGreenBackgroundView.backgroundColor = kAppDefaultColor(1)
        pulastingView.layer.cornerRadius = pulastingView.frame.size.height / 2
        pulastingView.layer.borderWidth = 1 / ((audioView.frame.size.height + 50) / 150)
        pulastingView.layer.borderColor = UIColor.white.cgColor
        pulastingView.backgroundColor = UIColor.clear
        audioPlayerView.layer.cornerRadius = 5.0
        audioPlayerView.layer.borderColor = kAppDefaultColor(1).cgColor
        audioPlayerView.layer.borderWidth = 1.0
        audioPlayerView.alpha = 0
        edgesForExtendedLayout = []
        okButton.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (updateTimer != nil) {
            updateTimer.invalidate()
            updateTimer = nil
        }
        if (recordTimer != nil) {
            recordTimer.invalidate()
            recordTimer = nil
        }
        if (pulseTimer != nil) {
            pulseTimer.invalidate()
            pulseTimer = nil
        }
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initAudio() {
        audioData = try? Data(contentsOf: recorder.url)
        if (audioData != nil) {
            let sizeString: String = String(format: "%d", audioData.count)
            okButton.setTitle(String(format: "Ok, %@", CSUtils.readableFileSize(sizeString)), for: .normal)
            okButton.isEnabled = true
        }
    }

    func animateView() {
        UIView.animate(withDuration: 0.7, animations: {() -> Void in
            let scale: CGFloat = sqrt(pow(self.audioView.frame.size.height / 2, 2) + pow(self.audioView.frame.size.width / 2, 2)) / 25
            self.expandingGreenBackgroundView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.playLabel.alpha = 1.0
            self.playImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.view.layoutIfNeeded()
        }, completion: {(_ finished: Bool) -> Void in
            self.pulseAnimation()
            self.pulseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.pulseAnimation), userInfo: nil, repeats: true)
        })
    }

    func pulseAnimation() {
        UIView.animate(withDuration: 0.7, animations: {() -> Void in
            let scale: CGFloat = sqrt(pow(self.audioView.frame.size.height / 2, 2) + pow(self.audioView.frame.size.width / 2, 2)) / 25
            self.pulastingView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: {(_ finished: Bool) -> Void in
            self.pulastingView.alpha = 0
            let scale: CGFloat = 1
            self.pulastingView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.pulastingView.alpha = 1
        })
    }

    func animateReverseColor() {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            let scale: CGFloat = 1
            self.expandingGreenBackgroundView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.playLabel.alpha = 0.0
            self.playImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {(_ finished: Bool) -> Void in
            self.addAudioPlayer()
        })
    }

    func addAudioPlayer() {
        audioPlayerView.url = recorder.url.path
        animateAudioPlayer(true)
    }

    func animateAudioPlayer(_ boolValue: Bool) {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.audioPlayerView.alpha = boolValue ? 1 : 0
        }, completion: {(_ finished: Bool) -> Void in
            if (!boolValue) {
                self.audioPlayer = nil
            }
        })
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        initAudio()
    }

    func updateSlider() {
    }

    func updateRecTime() {
    }
}
