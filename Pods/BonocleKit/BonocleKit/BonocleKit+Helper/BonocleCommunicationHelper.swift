//
//  BonocleCommunicationHelper.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import CoreBluetooth
import UIKit
import Speech

public class BonocleCommunicationHelper:  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    public static let shared = BonocleCommunicationHelper()
    
    public var connectedBonocle = BonocleDevice()
    public var bonocleDevices =  [BonocleDevice]()
    public var peripherals: [BonocleDevice] = []

    public var connectedPeripheral : CBPeripheral?
    public weak var deviceDelegate: BonocleDelegate?
    var tablesArray: TableNamesModel?

    var centralManager : CBCentralManager!
    var RSSIs = [NSNumber]()
    var timer = Timer()
    let speechSynthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    var connectionState = false
    var subscribeToIMU = false
    var subscribeToOptical = false
    var connectFirstBonocle = false
    var autoSrollLoop = false

    public var autoScrollSpeed = 0.7
    var autoSrollIndex = 0
    public var xSpacing = 200
    public var ySpacing = 200
    var IMUConfig = 3
    public var connectedDevicesCount = 0
    var autoSrollText = ""

    var bonocleMode = BonocleModes.discovery
    public var handPreference: HandPreference = .right
    
    private override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillBecomeInActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        tablesArray = Bundle.main.decode(TableNamesModel.self, from: "TableNames.json")
    }
    
    
    @objc func applicationDidBecomeActive() {
        print("APP OPENED")
        setupPerAppConfig()
    }
    
    @objc func applicationWillBecomeInActive() {
        print("APP CLOSED")
    }
    
    
    func setupPerAppConfig(){
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    
    
    // MARK: - Bonocle Communication
    public func searchForBonocle(bonocle: BonocleDevice? = nil){
        searchForConnectedDevices()
        if bonocle != nil {
            centralManager?.scanForPeripherals(withServices: [kBLE_Service_Optical,AdvertisedBLEService] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
            guard let currentBonocle = bonocle else{return}
            connectedBonocle = currentBonocle
            bonocleMode = .idle
        }else{
            centralManager?.scanForPeripherals(withServices: [AdvertisedBLEService] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
            bonocleMode = .discovery
        }
    }
    
    private func searchForConnectedDevices(){
        let connectedDevices = centralManager?.retrieveConnectedPeripherals(withServices: [AdvertisedBLEService])
        for device in connectedDevices!{
            print("Already connected")
            if !peripherals.contains(where: { $0.peripheral?.identifier == device.identifier }){
                self.peripherals.append(BonocleDevice(peripheral: device, bonocle_name: device.name ?? "Bonocle"))
                connectToDevices(devices: peripherals)
                device.delegate = self
                if deviceDelegate != nil{
                    connectionState = true
                }
                return
            }
        }
    }
    
    public func disconnectFromDevice (device : CBPeripheral) {
        centralManager?.cancelPeripheralConnection(device)
    }
    
    public func disconnectAllConnection() {
        for device in peripherals {
            centralManager?.cancelPeripheralConnection(device.peripheral!)
        }
    }

    public func checkDeviceConnectivity() -> Bool {
        peripherals.count > 0 ? true : false
    }
    
    /*We also need to stop scanning at some point so we'll also create a function that calls "stopScan"*/
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        print("HELPER -  Scan Stopped")
        print("HELPER -  Number of Peripherals Found: \(peripherals.count)")
    }
    
    //-Connection
    //Peripheral Connections: Connecting, Connected, Disconnected
    public func connectToDevice (device : CBPeripheral) {
        connectionState = false
        scanningTimer()
        centralManager?.connect(device, options: nil)
    }
    
    func connectToDevices (devices : [BonocleDevice]) {
        for device in devices {
            centralManager?.connect(device.peripheral!, options: nil)
        }
    }
    
    public func getAllTables() -> TableNamesModel?{
        return tablesArray
    }

    func scanningTimer(){
        var runCount = 0
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            print("Timer fired!")
            if self.connectionState{timer.invalidate()}
            else{
                runCount += 1
                if runCount == 2 {
                    print("Bonocle Not Found!")
                    self.cancelScan()
                    timer.invalidate()
                }
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: peripheral))")
        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        print("HELPER -  Scan Stopped")
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([kBLE_Service_Braille, kBLE_Service_IMU,  kBLE_Service_Buttons, kBLE_Service_Haptics, kBLE_Service_Optical])
        connectedPeripheral = peripheral
    }
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("HELPER -  Failed to connect to peripheral")
            return
        }
    }
    
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scan if Bluetooth is turned on.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("HELPER -  Bluetooth Enabled")
            searchForBonocle()
            self.deviceDelegate?.centralManagerState(state: .PowerdON)
        } else {
            self.deviceDelegate?.centralManagerState(state: .PowerdOFF)
            print("HELPER -  Bluetooth Disabled- Make sure your Bluetooth is turned on")
        }
    }
    
    /*
     Called when the central manager discovers a peripheral while scanning. Also, once peripheral is connected, cancel scanning.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let bonocleName = advertisementData["kCBAdvDataLocalName"] as? String ?? "Bonocle"
        print("HELPER -  Found Device: "+(peripheral.name ?? "NaN"))
        print("HELPER -  Found Device UUID: \(peripheral.identifier)")
        print("Peripheral Local name: \(bonocleName)")
        if !peripherals.contains(where: { $0.peripheral?.identifier.uuidString == peripheral.identifier.uuidString }){
            switch bonocleMode {
            case .idle:
                if connectedBonocle.UUID == peripheral.identifier {
                    self.peripherals.append(BonocleDevice(peripheral: peripheral, bonocle_name: bonocleName))
                }
            case .discovery:
                self.peripherals.append(BonocleDevice(peripheral: peripheral, bonocle_name: bonocleName))
            }
        }else if !bonocleName.isEmpty {
            let index = peripherals.firstIndex(where: { $0.peripheral?.identifier.uuidString == peripheral.identifier.uuidString })
            peripherals[index!].bonocle_name = bonocleName
        }
        self.RSSIs.append(RSSI)
        peripheral.delegate = self
        
        if(self.deviceDelegate != nil  && (self.peripherals.count > 0)){
            connectionState = true
            self.deviceDelegate!.foundDevices(peripherals: self.peripherals)
        }
    }
    
    func connectToFirstBonocle(peripheral: CBPeripheral){
        if !connectFirstBonocle {
            connectFirstBonocle = true
            centralManager?.stopScan()
            connectToDevice(device: peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("HELPER -  Disconnected", peripheral.name ?? "")
        connectionState = false
        let connectedBonoclesCount = peripherals.filter {$0.peripheral?.state == .connected}
        connectedDevicesCount = connectedBonoclesCount.count
        NotificationCenter.default.post(name: Notification.Name("DeviceStateNotification"), object: nil)
        //        removeDisconnectedPeripheral(disconnectedPeripheral: peripheral)
        //        startScan()
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.deviceDidDisconnect(peripheral: getCurrentBonocle(peripheral))
            self.deviceDelegate?.foundDevices(peripherals: peripherals)
        }
    }
    
    func restoreCentralManager() {
        centralManager?.delegate = self
    }
    
    func removeDisconnectedPeripheral(disconnectedPeripheral: CBPeripheral){
        for _ in peripherals{
            self.peripherals = peripherals.filter { $0.peripheral?.identifier != disconnectedPeripheral.identifier}
            self.bonocleDevices = bonocleDevices.filter { $0.UUID != disconnectedPeripheral.identifier}
            print("All Peripherals",peripherals)
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            switch service.uuid.uuidString {
            case kBLE_Service_Buttons.uuidString:
                BLE_Service_Buttons = service
                peripheral.discoverCharacteristics(buttonsServiceCharacteristics, for: service)
            case kBLE_Service_Braille.uuidString:
                BLE_Service_Braille = service
                peripheral.discoverCharacteristics(brailleServiceCharacteristics, for: service)
            case kBLE_Service_IMU.uuidString:
                BLE_Service_IMU = service
                peripheral.discoverCharacteristics(IMUServiceCharacteristics, for: service)
            case kBLE_Service_Optical.uuidString:
                BLE_Service_Optical = service
                peripheral.discoverCharacteristics(opticalServiceCharacteristics, for: service)
            case kBLE_Service_Haptics.uuidString:
                BLE_Service_Haptics = service
                peripheral.discoverCharacteristics(hapticsServiceCharacteristics, for: service)
                
            default:
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        print("Discovered Services: \(services)")
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics! in Service \(service.uuid)")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if      (service.hasUUID(uuid: kBLE_Service_Optical) && subscribeToOptical)
                        ||  (service.hasUUID(uuid: kBLE_Service_IMU) && subscribeToIMU)
                        ||  service.hasUUID(uuid: kBLE_Service_Buttons)
                        ||  service.hasUUID(uuid: kBLE_Service_Braille)
                        ||  characteristic.hasUUID(uuid: kBLE_Characteristic_Battery)
                        ||  characteristic.hasUUID(uuid: kBLE_Characteristic_Device_Config){
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to characteristic: \(characteristic.uuid)")
            }
            
            for per in peripherals {
                if per.peripheral?.identifier == peripheral.identifier{
                    if  characteristic.hasUUID(uuid: kBLE_Characteristic_Haptics) {
                        per.bonocleCharacteristic?.BLE_Characteristic_Haptics = characteristic
                        
                        //*********cancelScan()******
                        print("BLE_Characteristic_Haptics: \(characteristic.uuid)")
                    }
                    
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_Buzzer) {
                        per.bonocleCharacteristic?.BLE_Characteristic_Buzzer = characteristic
                        
                        //*********cancelScan()******
                        print("BLE_Characteristic_Buzzer: \(characteristic.uuid)")
                    }
                    
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_Braille) {
                        per.bonocleCharacteristic?.BLE_Characteristic_Braille = characteristic
                        //*********cancelScan()******
                        print("BLE_Characteristic_Braille: \(characteristic.uuid)")
                    }
                    
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_Optical_Config) {
                        per.bonocleCharacteristic?.BLE_Characteristic_Optical_Config = characteristic
                        updateOpticalSpacing(peripheral: getCurrentBonocle(peripheral), x_spacing: self.xSpacing, y_spacing: self.ySpacing)
                        //*********cancelScan()******
                        print("BLE_Characteristic_Optical_Config: \(characteristic.uuid)")
                    }
                    
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_IMU_Config) {
                        per.bonocleCharacteristic?.BLE_Characteristic_IMU_Config = characteristic
                        updateIMUConfig(peripheral: getCurrentBonocle(peripheral), res: self.IMUConfig)
                        //*********cancelScan()******
                        print("BLE_Characteristic_IMU_Config: \(characteristic.uuid)")
                    }
                    
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_Device_Config) {
                        per.bonocleCharacteristic?.BLE_Characteristic_Device_Config = characteristic
                        
                        //*********cancelScan()******
                        peripheral.readValue(for: characteristic)
                        //                saveDeviceConfig(peripheral: peripheral, deviceConfig: bonocleConfigModel)
                        print("BLE_Characteristic_Device_Config: \(characteristic.uuid)")
                    }
                    
                    // battery characteristic
                    if characteristic.hasUUID(uuid: kBLE_Characteristic_Battery){
                        per.bonocleCharacteristic?.BLE_Characteristic_Battery = characteristic
                        
                        peripheral.readValue(for: characteristic)
                        print("BLE_Characteristic_Battery \(characteristic.uuid)")
                    }
                }
            }
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString {
        case kBLE_Characteristic_Buttons.uuidString:
            handleButtonEvent(peripheral: getCurrentBonocle(peripheral), value: characteristic.value)
            return
        case kBLE_Characteristic_Optical_XY.uuidString:
            handleOpticalEvent(peripheral: getCurrentBonocle(peripheral), value: characteristic.value)
            return
        case kBLE_Characteristic_IMU_XYZ.uuidString:
            handleIMUEvent(peripheral: getCurrentBonocle(peripheral), value: characteristic.value)
            return
        case kBLE_Characteristic_Battery.uuidString:
            handleBatteryEvent(peripheral: getCurrentBonocle(peripheral), value: characteristic.value)
            return
        case kBLE_Characteristic_Device_Config.uuidString:
            handleDeviceConfigValues(peripheral: peripheral, value: characteristic.value)
            return
        default:
            return
        }
    }
    
    func getCurrentBonocle(_ peripheral: CBPeripheral) -> BonocleDevice{
        for per in peripherals{
            if per.peripheral?.identifier == peripheral.identifier{
                connectedBonocle = per
            }
        }
        return connectedBonocle
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            if characteristic.uuid.uuidString == "C001" {
                if(self.deviceDelegate != nil){
                    connectionState = true
                    let connectedBonoclesCount = peripherals.filter {$0.peripheral?.state == .connected}
                    connectedDevicesCount = connectedBonoclesCount.count
                    NotificationCenter.default.post(name: Notification.Name("DeviceStateNotification"), object: nil)
                    self.deviceDelegate!.deviceDidConnect(peripheral: getCurrentBonocle(peripheral))
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("HELPER -  Succeeded!")
        
    }

    private func handleButtonEvent(peripheral: BonocleDevice, value: Data?){
        print(peripheral.peripheral?.name ?? "","Buttons Changed")
        
        let byte = value![0]
        let string = byte.bin
        let buttonNumberBinary = string.suffix(3)
        
        var button = Buttons.middle
        var event = ButtonEvents.singleClick
        
        if let buttonNumber = Int(buttonNumberBinary, radix: 2) {
            switch buttonNumber {
            case 0:
                print(peripheral.peripheral?.name ?? "" , "Left Button")
                switch handPreference {
                case .right:
                    button = .left
                case .left:
                    button = .right
                }
            case 1:
                print(peripheral.peripheral?.name ?? "","Right Button")
                switch handPreference {
                case .right:
                    button = .right
                case .left:
                    button = .left
                }
            case 2:
                print(peripheral.peripheral?.name ?? "","Middle Button")
                button = .middle
            case 3:
                print("Bottom Button")
                button = .bottom
            case 4:
                print(peripheral.peripheral?.name ?? "","Left Side Button")
                switch handPreference {
                case .right:
                    button = .action
                case .left:
                    button = .back
                }
            case 5:
                print(peripheral.peripheral?.name ?? "","Right Side Button")
                switch handPreference {
                case .right:
                    button = .back
                case .left:
                    button = .action
                }
            default:
                print(buttonNumber)
            }
        }
        
        if string[4] == "1" {
            //released
            print(peripheral.peripheral?.name ?? "","released")
            event = .released
        }
        
        if string[3] == "1" {
            //pressed
            print(peripheral.peripheral?.name ?? "","Single Click")
            event = .singleClick
        }
        
        if string[2] == "1" {
            //Long
            print(peripheral.peripheral?.name ?? "","Hold")
            event = .hold
        }
        
        if string[1] == "1" {
            //Double
            print(peripheral.peripheral?.name ?? "","Double")
            event = .doubleClick
        }
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.buttonEvent(peripheral: peripheral , button: button, event: event)
        }
    }
    
    private func handleOpticalEvent(peripheral: BonocleDevice, value: Data?){
        
        print("Optical Changed")
        print(value!.hexEncodedString())
        
        let byte0 = Int16(value![0])
        let byte1 = Int16(value![1])
        let byte2 = Int16(value![2])
        let byte3 = Int16(value![3])
        
        let x: Int16 = ((byte1 << 8) | byte0)
        let y: Int16 = ((byte3 << 8) | byte2)

        let deltaX = Int(x)
        let deltaY = Int(y)
        
        print(x)
        print(y)
        
        print("Delata X : ")
        print(deltaX)
        
        print("Delata Y : ")
        print(deltaY)
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.opticalEvent(peripheral: peripheral, x: deltaX, y: deltaY)
        }
        
    }
    
    func handleOpticalValue(peripheral: CBPeripheral, value: Data?){
        print("Optical Value....")
        print(value!.hexEncodedString())
    }
    
    public func handleDeviceConfigValues(peripheral: CBPeripheral, value: Data?){
        print("Get Device Conig Values./././././././././././././././",value?.count as Any)
        if let value = value, value.count >= 7{
            print("Hand Preference:",value[0])
            print("Braille Table:", value[1] , value[2] , value[3])
            print("Auto Scroll Speed:",value[4])
            print("Reading Space:",value[5])
            print("Navigation Space:",value[6])
            switch value[0]{
            case 0:
                handPreference = .right
            case 1:
                handPreference = .left
            default:return
            }
            self.autoScrollSpeed = Double(value[4])
            self.xSpacing = Int(value[5])
            self.ySpacing = Int(value[6])
            
            bonocleDevices.append(BonocleDevice(peripheral: peripheral, reading_spacing: Int(value[5]), navigation_spacing: Int(value[6]), auto_scroll_speed: Int(value[4]), vibration_strength: 1, languages: [], UUID: peripheral.identifier, hand_preference: handPreference, connected: true))
            
            if(self.deviceDelegate != nil){
//                self.deviceDelegate!.foundDevices(bonocleDevice: bonocleDevices)
            }
        }
    }
    
    
    private func handleIMUEvent(peripheral: BonocleDevice, value: Data?){
        print("IMU Changed")
        print(value!.hexEncodedString())
        
        let byte0 = Int16(value![0])
        let byte1 = Int16(value![1])
        let byte2 = Int16(value![2])
        let byte3 = Int16(value![3])
        let byte4 = Int16(value![4])
        let byte5 = Int16(value![5])
        
        let x: Int16 = ((byte1 << 8) | byte0)
        let y: Int16 = ((byte3 << 8) | byte2)
        let z: Int16 = ((byte5 << 8) | byte4)
        
        print(x)
        print(y)
        print(z)
        
        if(self.deviceDelegate != nil){
            self.deviceDelegate!.imuEvent(peripheral: peripheral, X: Int(x), Y: Int(y), Z: Int(z))
        }
    }
    
    private func handleBatteryEvent(peripheral: BonocleDevice, value: Data?){
        print("Battery Changed")
        print(value!.hexEncodedString())
        
        if(self.deviceDelegate != nil){
            let BatteryValue = Int(value![0])
            if BatteryValue > 128 {
                self.deviceDelegate!.batteryState(peripheral: peripheral, value: BatteryValue-128, charging: true)
            }else{
                self.deviceDelegate!.batteryState(peripheral: peripheral, value: BatteryValue, charging: false)
            }
        }
        
    }
    
    private func handleAutoScrollSpeedUpdated(peripheral: BonocleDevice, value: Data?){
        if value == nil {
            return
        }
        print("Auto Scroll Speed Updated")
        print(value!.hexEncodedString())
        print(autoScrollSpeed)
    }
    
    //TRIGGERS
    public func vibrate(peripheral: BonocleDevice, hapticMotor: HapticMotors, with pattern: HapticPatterns){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics != nil{
            var data: [UInt8] = [0x01, 0xF0, 0x00, 0x01]
            
            //TODO: Duration And Pattern to be added in BonocleDevice Object ...
            switch pattern {
            case .positive:
                data[0] = 0x01 // duration
                data[1] = connectedBonocle.vibration_strength?.toUInt8() ?? 0x01 // strength
                data[2] = 0x01 // pattern
            case .negative:
                data[0] = 0x01
                data[1] = connectedBonocle.vibration_strength?.toUInt8() ?? 0x01
                data[2] = 0x01
            case .nudge:
                data[0] = 0x01
                data[1] = connectedBonocle.vibration_strength?.toUInt8() ?? 0x01
                data[2] = 0x01
            case .harsh:
                data[0] = 0x01
                data[1] = connectedBonocle.vibration_strength?.toUInt8() ?? 0x01
                data[2] = 0x01
            }
            switch hapticMotor {
            case .right:
                data[3] = 0x01
            case .left:
                data[3] = 0x02
            case .both:
                data[3] = 0x03
            }
            
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func vibrate(peripheral: BonocleDevice, hapticMotor: HapticMotors, with strenght: Int, for duration: Int, with pattern: Int){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics != nil && duration.inRange() && strenght.inRange() && pattern.inRange(){
            var data: [UInt8] = [0, 1, 2, 3]
            
            data[0] = duration.toUInt8()
            data[1] = strenght.toUInt8()
            data[2] = pattern.toUInt8()
            
            switch hapticMotor {
            case .right:
                data[3] = 0x01
            case .left:
                data[3] = 0x02
            case .both:
                data[3] = 0x3
            }
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateVibrate(peripheral: BonocleDevice, hapticMotor: HapticMotors, with strenght: HapticStrength, for duration: Int, with pattern: Int){
        guard let strengthValue = Int(strenght.description) else {return}
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics != nil && duration.inRange() && strengthValue.inRange() && pattern.inRange(){
            var data: [UInt8] = [0, 1, 2, 3]
            
            data[0] = duration.toUInt8()
            data[1] = strengthValue.toUInt8()
            data[2] = pattern.toUInt8()
            
            switch hapticMotor {
            case .right:
                data[3] = 0x01
            case .left:
                data[3] = 0x02
            case .both:
                data[3] = 0x3
            }
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Haptics)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func buzzer(peripheral: BonocleDevice, for duration: Int, with strenght: Int, with frequency: Int){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Buzzer != nil && duration.inRange() && strenght.inRange() && frequency.inRange(){
            var data: [UInt8] = [0, 1, 2]
            data[0] = duration.toUInt8()
            data[1] = strenght.toUInt8()
            data[2] = frequency.toUInt8()
            let enableBytes = NSData(bytes: &data, length:data.count)
            
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Buzzer)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateBraille(peripheral: BonocleDevice, letter: String){
        endTimer()
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille != nil {
            var data = [brailleMetecMap[letter]]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateBraille(peripheral: BonocleDevice, pins: UInt){
        endTimer()
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille != nil {
            var data = [pins]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func sendBraile(peripheral: BonocleDevice, letter: String){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille != nil {
            var data = [brailleMetecMap[letter]]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Braille)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateOpticalSpacing(peripheral: BonocleDevice, x_spacing: Int, y_spacing: Int){
        self.xSpacing = x_spacing
        self.ySpacing = y_spacing
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config != nil && x_spacing.inRange() && y_spacing.inRange() {
            var data = [x_spacing.toUInt8(), y_spacing.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateOpticalSpacingValue(peripheral: BonocleDevice, optical_value: OpticalSpacing){
        guard let opticalValue = Int(optical_value.description) else {return}
        self.xSpacing = opticalValue
        self.ySpacing = opticalValue
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config != nil && opticalValue.inRange() && opticalValue.inRange() {
            var data = [opticalValue.toUInt8(), opticalValue.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    
    public func updateAutoScrollSpeed(peripheral: BonocleDevice, speed: Int){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll != nil && speed.inRange() {
            var data = [speed.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateAutoScrollSpeedValue(peripheral: BonocleDevice, speed_value: AutoScrollSpeed){
        guard let speedValue = Float(speed_value.description) else {return}
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll != nil {
            var data = [speedValue]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func updateIMUConfig(peripheral: BonocleDevice, res: Int){
        self.IMUConfig = res
        
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_IMU_Config != nil && res.inRange(){
            var data = [res.toUInt8()]
            let enableBytes = NSData(bytes: &data, length:data.count)
            peripheral.peripheral?.writeValue(enableBytes as Data, for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_IMU_Config)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func getAutoScrollSpeed(peripheral: BonocleDevice){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll != nil {
            peripheral.peripheral?.readValue(for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Auto_Scroll)!)
        }
    }
    
    public func getBatteryStatus(peripheral: BonocleDevice){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Battery != nil {
            peripheral.peripheral?.readValue(for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Battery)!)
        }
    }
    
    public func getOpticalConfigValue(peripheral: BonocleDevice){
        if peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config != nil {
            peripheral.peripheral?.readValue(for: (peripheral.bonocleCharacteristic?.BLE_Characteristic_Optical_Config)!)
        }
    }
    
    public func endTimer() {
        timer.invalidate()
    }
    
    public func updateTimer(peripheral: BonocleDevice) {
        endTimer()
        activateAutoScrollTimer(peripheral: peripheral)
    }
    
    public func activateAutoScrollTimer(peripheral: BonocleDevice){
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.autoScrollSpeed), target: self, selector: #selector(self.handleAutoScrollTimer(sender:)), userInfo: peripheral, repeats: true)
    }
    
    @objc func handleAutoScrollTimer(sender: Timer){
        let peripheral = (sender.userInfo as? BonocleDevice)
        
        if self.autoSrollLoop {
            self.autoSrollIndex = self.autoSrollIndex % self.autoSrollText.count
        }
        
        let letterIndex = self.autoSrollIndex
        
        if  peripheral != nil && peripheral?.peripheral?.state == .connected && self.autoSrollIndex < self.autoSrollText.count &&  self.autoSrollIndex >= 0{
            sendBraile(peripheral: peripheral!, letter: String(self.autoSrollText[letterIndex]))
        }
        self.autoSrollIndex = self.autoSrollIndex + 1
    }
    
    public func autoScrollText(peripheral: BonocleDevice, text: String, loop: Bool, scrollSpeed: Double? = nil){
        endTimer()
        self.autoSrollText = text
        self.autoSrollLoop = loop
        self.autoSrollIndex = 0
        self.autoScrollSpeed = scrollSpeed ?? autoScrollSpeed
        if text.count > 1 {
            updateTimer(peripheral: peripheral)
        }else{
            sendBraile(peripheral: peripheral, letter: text)
        }
    }
    
    public func stopAutoScroll(peripheral: BonocleDevice){
        endTimer()
        sendBraile(peripheral: peripheral, letter: " ")
    }
    
    public func setIMUSubscription(peripheral: CBPeripheral?, to: Bool){
        subscribeToIMU = to
        if BLE_Characteristic_IMU_XYZ != nil && peripheral != nil{
            peripheral!.setNotifyValue(to, for: BLE_Characteristic_IMU_XYZ!)
        }
    }
    
    public func setOpticalSubscription(peripheral: CBPeripheral?, to: Bool){
        subscribeToOptical = to
        if BLE_Characteristic_Optical_XY != nil && peripheral != nil{
            peripheral!.setNotifyValue(to, for: BLE_Characteristic_Optical_XY!)
        }
    }
    
    public func saveDeviceConfig(deviceConfig: BonocleDevice){
        if  deviceConfig.bonocleCharacteristic?.BLE_Characteristic_Device_Config != nil && deviceConfig.peripheral != nil{
            var data: [UInt8] = []
            switch deviceConfig.hand_preference {
            case .left:
                data.append(1.toUInt8())
            case .right:
                data.append(0.toUInt8())
            default:
                data.append(0.toUInt8())
            }
            
            if let langs = deviceConfig.languages{
                langs.indices.contains(0) ? data.append(langs[0].toUInt8()) : data.append(0x00)
                langs.indices.contains(1) ? data.append(langs[1].toUInt8()) : data.append(0x00)
                langs.indices.contains(2) ? data.append(langs[2].toUInt8()) : data.append(0x00)
            }
            
            if let autoSpeed = deviceConfig.auto_scroll_speed, (autoSpeed * 10).inRange(){
                data.append(UInt8(autoSpeed))
            }
            
            if let readingSpace = deviceConfig.reading_spacing, (readingSpace * 10).inRange(){
                data.append(UInt8(readingSpace))
            }
            
            if let navSpace = deviceConfig.navigation_spacing, (navSpace * 10).inRange(){
                data.append(UInt8(navSpace))
            }
            
            if let vibrationStrength = deviceConfig.vibration_strength, (vibrationStrength * 10).inRange(){
                data.append(UInt8(vibrationStrength))
            }

            if let bonocleName = deviceConfig.bonocle_name, !bonocleName.isEmpty{
                let name = [UInt8](bonocleName.utf8)
                data.append(name.count.toUInt8())
                data.append(contentsOf: name)
            }
            
            let enableBytes = NSData(bytes: &data, length:data.count)
            deviceConfig.peripheral!.writeValue(enableBytes as Data, for: (deviceConfig.bonocleCharacteristic?.BLE_Characteristic_Device_Config)!, type: CBCharacteristicWriteType.withResponse)
        }
    }
}
