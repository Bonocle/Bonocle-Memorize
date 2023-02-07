//
//  BonocleServicesUUID.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import CoreBluetooth

let FeedbackService_UUID = "A000" // Feedback Service
let kBLE_Characteristic_Optical_XY = CBUUID(string: "A001")
let kBLE_Characteristic_Buttons = CBUUID(string: "A002")
let kBLE_Characteristic_IMU_XYZ = CBUUID(string: "A003")
let kBLE_Characteristic_Baro = CBUUID(string: "A004")
let kBLE_Characteristic_Battery = CBUUID(string: "A005")

let feedbackServiceCharacteristics = [kBLE_Characteristic_Optical_XY, kBLE_Characteristic_Buttons, kBLE_Characteristic_IMU_XYZ, kBLE_Characteristic_Baro, kBLE_Characteristic_Battery]
let FeedbackBLEService = CBUUID(string: FeedbackService_UUID)


let ControlService_UUID = "B000" // Control Service
let kBLE_Characteristic_Haptics = CBUUID(string: "B001")
let kBLE_Characteristic_Buzzer = CBUUID(string: "B002")
let kBLE_Characteristic_Braille = CBUUID(string: "B003")
let kBLE_Characteristic_API = CBUUID(string: "B004")

let controlServiceCharacteristics = [kBLE_Characteristic_Haptics, kBLE_Characteristic_Buzzer, kBLE_Characteristic_Braille, kBLE_Characteristic_API]
let ControlBLEService = CBUUID(string: ControlService_UUID)


var BLE_Feedback_Service : CBService?
var BLE_Characteristic_Optical_XY : CBCharacteristic?
var BLE_Characteristic_Buttons : CBCharacteristic?
var BLE_Characteristic_IMU_XYZ : CBCharacteristic?
var BLE_Characteristic_Baro : CBCharacteristic?
var BLE_Characteristic_Battery : CBCharacteristic?


var BLE_Control_Service : CBService?
var BLE_Characteristic_Haptics : CBCharacteristic?
var BLE_Characteristic_Buzzer : CBCharacteristic?
var BLE_Characteristic_Braille : CBCharacteristic?
var BLE_Characteristic_API : CBCharacteristic?
