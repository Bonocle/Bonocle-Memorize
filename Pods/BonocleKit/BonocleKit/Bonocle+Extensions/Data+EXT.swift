//
//  Data+EXT.swift
//  BonocleKit
//
//  Created by Andrew on 9/13/21.
//

import Foundation
public extension Data {
    func hexEncodedoneString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%d ", Int($0)) }.joined()
    }
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }

    func toArray<T>(type: T.Type) -> [T] {
        let value = self.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: T.self)
        }
        return [T](UnsafeBufferPointer(start: value, count: self.count / MemoryLayout<T>.stride))
    }
}
