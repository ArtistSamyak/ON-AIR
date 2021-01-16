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
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            bkimg.image = #imageLiteral(resourceName: "listen")
            
        
        
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("audio.m4a")
        
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
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (t) in
                    finishRecording(success: true)
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
        
        
        
        recordingSession = AVAudioSession.sharedInstance()
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { (t1) in
            count += 1
            do {
                try self.recordingSession.setCategory(.playAndRecord, mode: .default)
                try self.recordingSession.setActive(true)
                self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            if audioRecorder == nil {
                                    startRecording()
                                } else {
                                    finishRecording(success: true)
                                }
                        } else {
                            // failed to record!
                        }
                    }
                }
            } catch {
                // failed to record!
            }
            
            print(count)
            if(count == 3){
                t1.invalidate()
                
            }
            t1.invalidate()
            
        }
    
        //Getting audio data
            func getStream(){
                let storage = Storage.storage()
                let ref = storage.reference()
                let audioRef = ref.child("audio.m4a")
                audioRef.downloadURL { (url, error) in
                    if(error == nil){
                        
                        print("NOW PLAYING...")
                        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
                        let player = AVPlayer(playerItem: playerItem)
                        
                        let layer = AVPlayerLayer(player: player)
                        
                        layer.frame = self.view.bounds
                        layer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(layer)
                        player.play()
                        
                    }
                }
                
            }
    
        Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { (t3) in
            getStream()
            t3.invalidate()
        }
        
    }//viewDIDLoad

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if mainSwitch.isOn {
            bkimg.image = #imageLiteral(resourceName: "listen")
        } else {
            bkimg.image = #imageLiteral(resourceName: "Record")
            
            
            
            //*****
        }
    }
    
}//VCClass

