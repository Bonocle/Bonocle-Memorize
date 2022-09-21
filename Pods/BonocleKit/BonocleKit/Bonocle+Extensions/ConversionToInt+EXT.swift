//
//  ConversionToInt+EXT.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
public extension Int {
    func hexadecimal() -> Int {
        return Int(String(self), radix: 16)!
    }
    
    func hexadecimalByte() -> UInt8 {
        return UInt8(Int(String(self), radix: 16)!)
    }
    
    func toUInt8() -> UInt8 {
        return UInt8(String(self, radix: 16), radix: 16)!
    }
    
    func inRange() -> Bool{
        return (0...255).contains(self) ? true : false
    }
}

public extension UInt8 {
    var bin: String {
        String(self, radix: 2).leftPad(with: "0", length: 8)
    }
}
