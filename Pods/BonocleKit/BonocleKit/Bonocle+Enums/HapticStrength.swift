//
//  HapticStrength.swift
//  BonocleKit
//
//  Created by Andrew Fakher on 20/06/2022.
//

import Foundation
public enum HapticStrength : String{
    case one, two, three, four, five, six, seven
    
    public var description : String {
        switch self {
        case .one:
            return "140"
        case .two:
            return "160"
        case .three:
            return "180"
        case .four:
            return "200"
        case .five:
            return "220"
        case .six:
            return "240"
        case .seven:
            return "255"
        }
    }
}
