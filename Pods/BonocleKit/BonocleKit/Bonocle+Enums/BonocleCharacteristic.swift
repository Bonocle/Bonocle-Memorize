//
//  BonocleCharacteristic.swift
//  BonocleKit
//
//  Created by Andrew on 2/7/22.
//

import Foundation
import CoreBluetooth
public struct BonocleCharacteristic{
    var BLE_Characteristic_Haptics: CBCharacteristic?
    var BLE_Characteristic_Buzzer: CBCharacteristic?
    var BLE_Characteristic_Braille: CBCharacteristic?
    var BLE_Characteristic_Optical_Config: CBCharacteristic?
    var BLE_Characteristic_Auto_Scroll: CBCharacteristic?
    var BLE_Characteristic_IMU_Config: CBCharacteristic?
    var BLE_Characteristic_API: CBCharacteristic?
    var BLE_Characteristic_Baro: CBCharacteristic?
    var BLE_Characteristic_Battery: CBCharacteristic?
}
