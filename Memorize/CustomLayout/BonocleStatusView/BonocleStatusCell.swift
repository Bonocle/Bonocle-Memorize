//
//  BonocleStatusCell.swift
//  Bonocle Alphabet
//
//  Created by Andrew on 2/8/22.
//  Copyright © 2022 Andrew. All rights reserved.
//

import UIKit
import CoreBluetooth
import BonocleKit

protocol peripheralsCellDelegate{
    func connect(cell: UITableViewCell)
}

class BonocleStatusCell: UITableViewCell, NibLoadable {
    @IBOutlet weak var loadder: UIActivityIndicatorView!
    @IBOutlet weak var deviceConnectionBtn: UIButton!
    @IBOutlet weak var deviceStateLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    var delegate: peripheralsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        deviceConnectionBtn.isAccessibilityElement = false
    }
    
    func configureCell(device: BonocleDevice){
        deviceNameLabel.text = device.bonocle_name
        switch device.peripheral?.state {
        case .connected:
            deviceStateLabel.textColor = .systemGreen
            deviceStateLabel.text = NSLocalizedString("bonocle_connected", comment: "")
            deviceConnectionBtn.setImage(UIImage(named: "active-state"), for: .normal)
            deviceConnectionBtn.isUserInteractionEnabled = false
            deviceConnectionBtn.isHidden = false
            loadder.isHidden = true
            loadder.stopAnimating()
        case .disconnected:
            deviceStateLabel.textColor = .systemPink
            deviceStateLabel.text = NSLocalizedString("bonocle_disconnected", comment: "")
            deviceConnectionBtn.setImage(UIImage(named: "refresh"), for: .normal)
            deviceConnectionBtn.isUserInteractionEnabled = true
            deviceConnectionBtn.isHidden = false
            loadder.isHidden = true
            loadder.stopAnimating()
        default:
            return
        }
        isAccessibilityElement = true
        accessibilityLabel = "\(deviceNameLabel.text ?? "") \(deviceStateLabel.text ?? "")"
        if Locale.current.languageCode == "en"{
            accessibilityHint = device.peripheral?.state == .connected ? "Double tap to disconnect" : "Double tap to connect"
        }else{
            accessibilityHint = device.peripheral?.state == .connected ? "اضغط مرتين لقطع الاتصال" : "اضغط مرتين للاتصال"
        }
    }
    
    @IBAction func deviceConnectionTapped(_ sender: Any) {
        delegate?.connect(cell: self)
    }
}


protocol NibLoadable: class {}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}
