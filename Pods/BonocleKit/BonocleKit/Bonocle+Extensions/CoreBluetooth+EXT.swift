//
//  CoreBluetooth+EXT.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
import CoreBluetooth
public extension CBCharacteristic {
    func hasUUID(uuid: String) -> Bool {
        return (self.uuid.uuidString == uuid)
    }
    
    func hasUUID(uuid: CBUUID) -> Bool {
        return (self.uuid.uuidString == uuid.uuidString)
    }
}

public extension CBService {
    func hasUUID(uuid: String) -> Bool {
        return (self.uuid.uuidString == uuid)
    }
    
    func hasUUID(uuid: CBUUID) -> Bool {
        return (self.uuid.uuidString == uuid.uuidString)
    }
}
