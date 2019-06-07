//
//  SpeechManager.swift
//  NBA Bot
//
//  Created by Jakub Kolodziej on 09/02/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//
import Foundation
import Speech
import AVFoundation

protocol SpeechManagerDelegate
{
    func didReceiveText(text:String)
    func didStartedListening(status:Bool)
}

class SpeechManager
{
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    let audioSession = AVAudioSession.sharedInstance()
    var delegate:SpeechManagerDelegate?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    static let shared:SpeechManager = {
        let instance = SpeechManager()
        return instance
    }()
    
    func startRecording() {
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
           // audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
           stopRecording()
        }
        
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func stopRecording()
    {
        audioRecorder.stop()
        audioRecorder = nil
        
    }
    
    func speak(text: String) {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
    }
}


