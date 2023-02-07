//
//  UserPrefrences.swift
//  Bonocle_Spelling
//
//  Created by Mahmoud ELDemery on 21/06/2021.
//

import Foundation
import BonocleKit

class UserPrefrences:NSObject,NSCoding {
    
    var englishLanguageType:String = "en-US"
    var brailleCode:String = "unicode.dis,en-ueb-g2.ctb"
    var brailleCodeArabic:String = "unicode.dis,ar-ar-g1.utb"
    var brailleAndAudio:String?
    var navigation_spacing:Int?
    var autoScrollSpeed:Double = 0.7
    var isVibrationEnabled:Bool = true
    var readingMode:String = "motion"
    var readAssist:Bool = false
    var lineNavigation:Bool = false

    var deviceConfiguration:BonocleDevice?
    var voiceOverSpeed:Double?
    var voiceOverSound:String?
    
    private override init(){}
    
    static var shared = UserPrefrences()
    
    static func save(){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: shared)
        UserDefaults.standard.set(encodedData, forKey: "UserPrefrences")
        UserDefaults.standard.synchronize()
    }
    
    static func restore() -> UserPrefrences {
        if let decodedData  = UserDefaults.standard.object(forKey: "UserPrefrences") as? Data {
            if let restoredUser = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? UserPrefrences{
                shared = restoredUser
                return shared
            }
        }
        return shared
    }
    
    
    static func delete() {
        shared.englishLanguageType = "en-US"
        shared.brailleCode = "unicode.dis,en-ueb-g1.ctb"
        shared.brailleAndAudio = nil
        shared.isVibrationEnabled = true
        shared.autoScrollSpeed = 0.7
        shared.readAssist = false
        shared.lineNavigation = false
        shared.readingMode = "motion"
        shared.deviceConfiguration = nil
        shared.voiceOverSound = nil
        shared.voiceOverSpeed = nil
        shared.navigation_spacing = 40

        UserDefaults.standard.set(nil, forKey: "UserPrefrences")
    }
    
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(englishLanguageType, forKey: "englishLanguageType")
        aCoder.encode(brailleCode, forKey: "brailleCode")
        aCoder.encode(brailleAndAudio, forKey: "brailleAndAudio")
        aCoder.encode(isVibrationEnabled, forKey: "isVibrationEnabled")
        aCoder.encode(autoScrollSpeed, forKey: "autoScrollSpeed")
        aCoder.encode(readAssist, forKey: "readAssist")
        aCoder.encode(lineNavigation, forKey: "lineNavigation")
        aCoder.encode(readingMode, forKey: "readingMode")
        aCoder.encode(deviceConfiguration, forKey: "deviceConfiguration")
        aCoder.encode(voiceOverSpeed, forKey: "voiceOverSpeed")
        aCoder.encode(voiceOverSound, forKey: "voiceOverSound")
        aCoder.encode(navigation_spacing, forKey: "navigation_spacing")

    }
    
    required init?(coder aDecoder: NSCoder) {
        self.englishLanguageType = aDecoder.decodeObject(forKey: "englishLanguageType") as! String 
        self.brailleCode = aDecoder.decodeObject(forKey: "brailleCode") as! String
        self.brailleAndAudio = aDecoder.decodeObject(forKey: "brailleAndAudio") as? String
        self.isVibrationEnabled = aDecoder.decodeBool(forKey: "isVibrationEnabled")
        self.navigation_spacing = aDecoder.decodeObject(forKey: "navigation_spacing") as? Int
        self.autoScrollSpeed = aDecoder.decodeDouble(forKey: "autoScrollSpeed")
        self.readingMode = aDecoder.decodeObject(forKey: "readingMode") as? String ?? "motion"
        self.readAssist = aDecoder.decodeBool(forKey: "readAssist")
        self.lineNavigation = aDecoder.decodeBool(forKey: "lineNavigation")
        self.deviceConfiguration = aDecoder.decodeObject(forKey: "deviceConfiguration") as? BonocleDevice
        self.voiceOverSpeed = aDecoder.decodeObject(forKey: "voiceOverSpeed") as? Double
        self.voiceOverSound = aDecoder.decodeObject(forKey: "voiceOverSound") as? String

    }
}
