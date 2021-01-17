//
//  ViewController.swift
//  ON AIR
//
//  Created by Samyak Pawar on 14/01/21.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var mainSwitch: UISwitch!
    @IBOutlet weak var bkimg: UIImageView!
    @IBOutlet weak var nowLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            bkimg.image = #imageLiteral(resourceName: "listen")
            self.getStream()
            tStr = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (t3) in
                self.getStream()
                //t3.invalidate()
            }
            
    }//viewDIDLoad

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func startRecording() {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("audio.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("Recording Started")
            //recordButton.setTitle("Tap to Stop", for: .normal)
            Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { (t) in
                self.finishRecording(success: true)
                print("Recording Finished")
                
                let audiodata = try! Data(contentsOf: audioFilename)
                
                let storage = Storage.storage()
                let ref = storage.reference()
                let audioRef = ref.child("audio.m4a")
                audioRef.putData(audiodata)
                print("Data uploading...")
                
                t.invalidate()
            }
        } catch {
            finishRecording(success: false)
        }
    }
    
    var player : AVPlayer?
    
    func getStream(){
        self.player?.pause()
        let storage = Storage.storage()
        let ref = storage.reference()
        let audioRef = ref.child("audio.m4a")
        audioRef.downloadURL { (url, error) in
            if(error == nil){
                
                print("NOW PLAYING...")
                let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
                self.player = AVPlayer(playerItem: playerItem)
                
                let layer = AVPlayerLayer(player: self.player)
                
                layer.frame = self.view.bounds
                layer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(layer)
                self.player!.play()
                
            }
        }
        
    }
    
    var tRec : Timer?
    var tStr : Timer?
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if mainSwitch.isOn {
            bkimg.image = #imageLiteral(resourceName: "listen")
            nowLabel.text = "LIVE STREAMING..."
            tRec?.invalidate()
            tStr?.invalidate()
            tStr = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (t3) in
                self.getStream()
                //t3.invalidate()
            }
            
        } else {
            bkimg.image = #imageLiteral(resourceName: "Record")
            nowLabel.text = "LIVE BROADCASING..."
            tStr?.invalidate()
            self.player?.pause()
            
            recordingSession = AVAudioSession.sharedInstance()
            tRec = Timer.scheduledTimer(withTimeInterval: 21, repeats: true) { (t1) in
                
                do {
                    try self.recordingSession.setCategory(.playAndRecord, mode: .default)
                    try self.recordingSession.setActive(true)
                    if self.audioRecorder == nil {
                        self.startRecording()
                        } else {
                            self.finishRecording(success: true)
                        }
                } catch {
                    // failed to record!
                }
                
                
                //t1.invalidate()
                
            }
            
            
            //*****
        }
    }//switchdidchangevalue
    
}//VCClass

