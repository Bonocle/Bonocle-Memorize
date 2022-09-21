//
//  OpticalSpacing.swift
//  BonocleKit
//
//  Created by Andrew Fakher on 20/06/2022.
//

import Foundation
public enum OpticalSpacing : String{
    case one, two, three, four, five, six, seven
    
    public var description : String {
        switch self {
        case .one:
            return "20"
        case .two:
            return "40"
        case .three:
            return "60"
        case .four:
            return "80"
        case .five:
            return "100"
        case .six:
            return "120"
        case .seven:
            return "140"
        }
    }
}
