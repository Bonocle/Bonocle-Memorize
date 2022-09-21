//
//  BonocleServicesUUID.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import Foundation
import CoreBluetooth

let AdvertisedBLEService_UUID = "E000"

let kBLE_Service_Optical = CBUUID(string: "A000")
let kBLE_Characteristic_Optical_XY = CBUUID(string: "A001")
let kBLE_Characteristic_Optical_Config = CBUUID(string: "A002")

let opticalServiceCharacteristics = [kBLE_Characteristic_Optical_XY, kBLE_Characteristic_Optical_Config]

let kBLE_Service_Haptics = CBUUID(string: "B000")
let kBLE_Characteristic_Haptics = CBUUID(string: "B001")
let kBLE_Characteristic_Buzzer = CBUUID(string: "B002")

let hapticsServiceCharacteristics = [kBLE_Characteristic_Haptics, kBLE_Characteristic_Buzzer]

let kBLE_Service_Buttons = CBUUID(string: "C000")
let kBLE_Characteristic_Buttons = CBUUID(string: "C001")

let buttonsServiceCharacteristics = [kBLE_Service_Buttons, kBLE_Characteristic_Buttons]

let kBLE_Service_IMU = CBUUID(string: "D000")
let kBLE_Characteristic_IMU_XYZ = CBUUID(string: "D001")
let kBLE_Characteristic_IMU_Config = CBUUID(string: "D002")

let IMUServiceCharacteristics = [kBLE_Characteristic_IMU_XYZ, kBLE_Characteristic_IMU_Config]

let kBLE_Service_Braille = CBUUID(string: "E000")
let kBLE_Characteristic_Braille = CBUUID(string: "E001")
let kBLE_Characteristic_Battery = CBUUID(string: "E002")
let kBLE_Characteristic_Device_Config = CBUUID(string: "E003")
                                        
let brailleServiceCharacteristics = [kBLE_Characteristic_Braille, kBLE_Characteristic_Battery, kBLE_Characteristic_Device_Config]


let AdvertisedBLEService = CBUUID(string: AdvertisedBLEService_UUID)

var BLE_Service_Optical : CBService?
var BLE_Characteristic_Optical_XY : CBCharacteristic?
var BLE_Characteristic_Optical_Config : CBCharacteristic?

var BLE_Service_Haptics : CBService?
var BLE_Characteristic_Haptics : CBCharacteristic?
var BLE_Characteristic_Buzzer : CBCharacteristic?

var BLE_Service_Buttons: CBService?
var BLE_Characteristic_Buttons : CBCharacteristic?

var BLE_Service_IMU : CBService?
var BLE_Characteristic_IMU_XYZ : CBCharacteristic?
var BLE_Characteristic_IMU_Config : CBCharacteristic?

var BLE_Service_Braille : CBService?
var BLE_Characteristic_Braille : CBCharacteristic?
var BLE_Characteristic_Battery : CBCharacteristic?
var BLE_Characteristic_Auto_Scroll : CBCharacteristic?
var BLE_Characteristic_Device_Config : CBCharacteristic?

var characteristicASCIIValue = NSString()
