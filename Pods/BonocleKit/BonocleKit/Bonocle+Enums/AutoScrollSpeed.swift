//
//  AutoScrollSpeed.swift
//  BonocleKit
//
//  Created by Andrew Fakher on 20/06/2022.
//

import Foundation
public enum AutoScrollSpeed : String{
    case one, two, three, four, five, six, seven
    
    public var description : String {
        switch self {
        case .one:
            return "0.2"
        case .two:
            return "0.4"
        case .three:
            return "0.6"
        case .four:
            return "0.8"
        case .five:
            return "1"
        case .six:
            return "2"
        case .seven:
            return "3"
        }
    }
}
