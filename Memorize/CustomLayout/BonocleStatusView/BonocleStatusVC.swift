//
//  BonocleStatusVC.swift
//  Bonocle Alphabet
//
//  Created by Andrew on 1/27/22.
//  Copyright © 2022 Andrew. All rights reserved.
//

import UIKit
import BonocleKit
import CoreBluetooth

class BonocleStatusVC: UIViewController {

    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var bonocleTotalDeviceInfo: UILabel!
    @IBOutlet weak var statusMenuLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var bonocleDevicesList: UITableView!
    @IBOutlet weak var bonocleStatusView: UIView!

    var peripheral: BonocleDevice? = nil
    var connectedPeripherals =  [BonocleDevice]()

    override func viewDidLoad() {
        super.viewDidLoad()
        BonocleCommunicationHelper.shared.deviceDelegate = self
        popUpTitle.text = NSLocalizedString("bonocle_status_popup", comment: "")
        statusMenuLabel.text = NSLocalizedString("bonocle_menu_info", comment: "")
        bonocleDevicesList.dataSource = self
        bonocleDevicesList.delegate = self
        bonocleDevicesList.register(BonocleStatusCell.self)
        connectedPeripherals = BonocleCommunicationHelper.shared.peripherals
        bonocleStatusView.roundCornersFromTop()
        setupAccessibilityElements()
        BonocleCommunicationHelper.shared.searchForBonocle()
    }
    
    private func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        loader.isHidden = false
        loader.startAnimating()
        refreshBtn.alpha = 0
        if let bonocle = UserPrefrences.shared.deviceConfiguration {
            BonocleCommunicationHelper.shared.searchForBonocle(bonocle: bonocle)
        } else {
            BonocleCommunicationHelper.shared.searchForBonocle()
        }
    }
    
    func setupAccessibilityElements(){
        view.accessibilityElements = [popUpTitle!,refreshBtn!,closeBtn!,statusMenuLabel!,bonocleDevicesList!]
        if Locale.current.languageCode == "en"{
            popUpTitle.accessibilityLabel = "Bonocle Connection"
            closeBtn.accessibilityLabel = "close"
            refreshBtn.accessibilityLabel = "refresh"
        }else{
            popUpTitle.accessibilityLabel = "أجهزة بونوكل المتصلة"
            closeBtn.accessibilityLabel = "إلغاء"
            refreshBtn.accessibilityLabel = "تحديث"
        }
    }
}

extension BonocleStatusVC: UITableViewDataSource, UITableViewDelegate, peripheralsCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = bonocleDevicesList.dequeueReusableCell(forIndexPath: indexPath) as BonocleStatusCell
        cell.configureCell(device: connectedPeripherals[indexPath.row])
        cell.delegate = self
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connectOrDisconnect(device: connectedPeripherals[indexPath.row])
        let cell = tableView.cellForRow(at: indexPath) as! BonocleStatusCell
        cell.loadder.isHidden = false
        cell.deviceConnectionBtn.isHidden = true
        cell.loadder.startAnimating()
        cell.deviceStateLabel.text = NSLocalizedString("trying_to_connect", comment: "")
        cell.deviceStateLabel.textColor = .gray
    }
    
    func connect(cell: UITableViewCell) {
        let indexPath = self.bonocleDevicesList.indexPath(for: cell)
        for device in connectedPeripherals {
            if device.peripheral?.identifier.uuidString  == UserPrefrences.shared.deviceConfiguration?.UUID?.uuidString {
                BonocleCommunicationHelper.shared.connectToDevice(device: connectedPeripherals[indexPath!.row].peripheral!)
            }
        }
    }
    
    func connectOrDisconnect(device: BonocleDevice){
        switch device.peripheral?.state {
        case .connected:
            BonocleCommunicationHelper.shared.disconnectFromDevice(device: device.peripheral!)
        case .disconnected:
            BonocleCommunicationHelper.shared.connectToDevice(device: device.peripheral!)
        default:
            return
        }
    }
}

extension BonocleStatusVC: BonocleDelegate{
    func deviceDidConnect(peripheral: BonocleDevice){
        self.peripheral = peripheral
        DispatchQueue.main.async {self.bonocleDevicesList.reloadData()}
    }
    
    func deviceDidDisconnect(peripheral: BonocleDevice){
        self.peripheral = nil
    }
    
    func foundDevices(peripherals: [BonocleDevice]){
        print("All Connected Peripherals Data: ........")
        connectedPeripherals = peripherals
        print("All Peripherals Count:",peripherals.count)
        DispatchQueue.main.async{
            self.bonocleDevicesList.reloadData()
            self.loader.isHidden = true
            self.loader.stopAnimating()
            self.refreshBtn.alpha = 1
        }
    }
}



protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

extension ClassNameProtocol {
    public static var className: String {
        return String(describing: self)
    }

    public var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}

extension UITableViewCell {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.defaultReuseIdentifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        print(T.defaultReuseIdentifier)
        return cell
    }

    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        print(T.defaultReuseIdentifier)
        return cell
    }
}


extension UIView {
    func roundCornersFromTop() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
