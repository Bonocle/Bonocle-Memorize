//
//  BonocleStatusService.swift
//  Bonocle Alphabet
//
//  Created by Andrew on 1/27/22.
//  Copyright © 2022 Andrew. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class BonocleStatusService {
    static func showBonocleStatus() -> BonocleStatusVC {
        let bonocleStatusVC =  UIStoryboard(name: "BonocleStatus", bundle: .main).instantiateViewController(withIdentifier: "BonocleStatusVC") as! BonocleStatusVC
        return bonocleStatusVC
    }
}

struct BonocleStatusServiceRepresentable : UIViewControllerRepresentable {

     func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
     }

     func makeUIViewController(context: Context) -> some UIViewController {

         let bonocleStatusVC =  UIStoryboard(name: "BonocleStatus", bundle: .main).instantiateViewController(withIdentifier: "BonocleStatusVC") as! BonocleStatusVC
        return bonocleStatusVC
     }
}
