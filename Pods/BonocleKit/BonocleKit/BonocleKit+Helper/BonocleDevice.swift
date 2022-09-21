//
//  BonocleDevice.swift
//  BonocleKit
//
//  Created by Andrew on 2/7/22.
//

import Foundation
import CoreBluetooth
@objc(BonocleDevice)
public class BonocleDevice: NSObject, NSCoding{
    public var peripheral: CBPeripheral?
    public var bonocle_name: String?
    public var reading_spacing: Int?
    public var navigation_spacing: Int?
    public var auto_scroll_speed: Int?
    public var vibration_strength: Int?
    public var languages: [Int]?
    public var UUID: UUID?
    public var hand_preference: HandPreference?
    public var connected: Bool?
    public var bonocleCharacteristic: BonocleCharacteristic?
    
    init(peripheral: CBPeripheral? = nil, bonocle_name: String? = nil, reading_spacing: Int? = nil, navigation_spacing: Int? = nil, auto_scroll_speed: Int? = nil, vibration_strength: Int? = nil, languages: [Int]? = nil, UUID: UUID? = nil, hand_preference: HandPreference? = nil, connected: Bool? = nil, bonocleCharacteristic: BonocleCharacteristic? = nil) {
        self.peripheral = peripheral
        self.bonocle_name = bonocle_name
        self.reading_spacing = reading_spacing
        self.navigation_spacing = navigation_spacing
        self.auto_scroll_speed = auto_scroll_speed
        self.vibration_strength = vibration_strength
        self.languages = languages
        self.UUID = UUID
        self.hand_preference = hand_preference
        self.connected = connected
        self.bonocleCharacteristic = BonocleCharacteristic()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(bonocle_name, forKey: "bonocle_name")
        coder.encode(reading_spacing, forKey: "bonocle_reading_space")
        coder.encode(navigation_spacing, forKey: "bonocle_navigation_spacing")
        coder.encode(auto_scroll_speed, forKey: "bonocle_auto_scroll_speed")
        coder.encode(vibration_strength, forKey: "bonocle_vibration_strength")
        coder.encode(languages, forKey: "bonocle_languages")
        coder.encode(UUID, forKey: "bonocle_UUID")
        coder.encode(hand_preference?.rawValue, forKey: "bonocle_hand_preference")
        coder.encode(connected, forKey: "bonocle_connected")
      }
    
    public required init?(coder: NSCoder) {
      self.bonocle_name = coder.decodeObject(forKey: "bonocle_name") as? String
      self.reading_spacing = coder.decodeObject(forKey: "bonocle_reading_space") as? Int
      self.navigation_spacing = coder.decodeObject(forKey: "bonocle_navigation_spacing") as? Int
      self.auto_scroll_speed = coder.decodeObject(forKey: "bonocle_auto_scroll_speed") as? Int
      self.vibration_strength = coder.decodeObject(forKey: "bonocle_vibration_strength") as? Int
      self.languages = coder.decodeObject(forKey: "bonocle_languages") as? [Int] ?? []
      self.hand_preference = HandPreference(rawValue: coder.decodeObject(forKey: "bonocle_hand_preference") as? String ?? "")
      self.UUID = coder.decodeObject(forKey: "bonocle_UUID") as? UUID
      self.connected = coder.decodeObject(forKey: "bonocle_connected") as? Bool
    }
}
