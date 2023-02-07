//
//  BonocleDelegate.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import CoreBluetooth

public protocol BonocleDelegate: AnyObject {
    func deviceDidConnect(peripheral: BonocleDevice)
    func deviceDidDisconnect(peripheral: BonocleDevice)
    
    func deviceDidUpdate(peripheral: BonocleDevice)
    func foundDevices(peripherals : [BonocleDevice])
    func opticalEvent(peripheral: BonocleDevice, x: Int, y: Int)
    func imuEvent(peripheral: BonocleDevice, X: Int, Y: Int, Z: Int)
    func buttonEvent(peripheral: BonocleDevice, button: Buttons, event: ButtonEvents)
    func batteryState(peripheral: BonocleDevice, value: Int, charging: Bool)
    func baroState(peripheral: BonocleDevice, value: Int)
    func centralManagerState(state: BluetoothState)
    func UpdateDelegate()
}

public extension BonocleDelegate {
    func deviceDidUpdate(peripheral: BonocleDevice){}
    func foundDevices(peripherals : [BonocleDevice]){}
    func opticalEvent(peripheral: BonocleDevice, x: Int, y: Int){}
    func imuEvent(peripheral: BonocleDevice, X: Int, Y: Int, Z: Int){}
    func buttonEvent(peripheral: BonocleDevice, button: Buttons, event: ButtonEvents){}
    func batteryState(peripheral: BonocleDevice, value: Int, charging: Bool){}
    func baroState(peripheral: BonocleDevice, value: Int){}
    func centralManagerState(state: BluetoothState){}
    func UpdateDelegate(){}
}
