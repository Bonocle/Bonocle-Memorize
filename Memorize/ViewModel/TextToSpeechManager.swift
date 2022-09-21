//
//  TextToSpeechManager.swift
//  Bonocle_Spelling
//
//  Created by Mahmoud ELDemery on 11/01/2022.
//

import Foundation
import Speech

class TextToSpeechManager {
    
    public var speechSynthesizer: AVSpeechSynthesizer?
    public var audioSession: AVAudioSession?
    public var speechUtterance: AVSpeechUtterance?
    
    var synthesizerSentence: String?
    var synthesizerVolume: Float?
    var synthesizerLanguage: String?
    
    static let sharedInstance: TextToSpeechManager = {
        let instance = TextToSpeechManager()
        // setup code
        return instance
    }()
    
    private init() {
        audioSession = AVAudioSession.sharedInstance()
        speechSynthesizer = AVSpeechSynthesizer()
    }
        
    func readWord() {
        
        do{
            let _ = try audioSession?.setCategory(.playback,options: .duckOthers)
        }catch{
            print(error)
        }

        self.speechSynthesizer?.stopSpeaking(at: .word)
        
        speechUtterance = AVSpeechUtterance(string: synthesizerSentence ?? "")
//        speechUtterance?.voice = AVSpeechSynthesisVoice(identifier: UserPrefrences.shared.voiceOverSound ?? "")
//        speechUtterance?.rate = Float(UserPrefrences.shared.voiceOverSpeed ?? 0.4)
        speechUtterance?.volume = synthesizerVolume ?? 1.0
        
        self.speechSynthesizer?.speak((self.speechUtterance)!)
    }
    
    
    func stopSpeaking() {
        self.speechSynthesizer?.stopSpeaking(at: .immediate)
    }
}
