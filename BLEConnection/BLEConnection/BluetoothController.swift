//
//  BluetoothController.swift
//  BLEConnection
//
//  Created by Caio Gomes Piteli on 24/03/24.
//

import Foundation
import CoreBluetooth

class BluetoothController: NSObject, ObservableObject, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    
    @Published var connectedPeripheral: CBPeripheral?
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var isConnected = false
    @Published var bluetoothStatus: BluetoothStatus = .off
    @Published var valueReceived: String?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManagerDidUpdateState(centralManager)
    }
    
}

extension BluetoothController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            bluetoothStatus = BluetoothStatus.on
            
        case .poweredOff:
            resetReferences()
            bluetoothStatus = BluetoothStatus.off
            
        case .resetting:
            // Wait for next state update and consider logging interruption of Bluetooth service
            bluetoothStatus = BluetoothStatus.resseting
            
        case .unauthorized:
            // Alert user to enable Bluetooth permission in app Settings
            bluetoothStatus = BluetoothStatus.unathorized
            
        case .unsupported:
            // Alert user their device does not support Bluetooth and app will not work as expected
            bluetoothStatus = BluetoothStatus.unsupported
            
        case .unknown:
            // Wait for next state update
            bluetoothStatus = BluetoothStatus.unknown
            
        @unknown default:
            print("---Unknown default bluetooth state---")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripheralAlreadyRegistered(peripheral: peripheral){
            if peripheral.name != nil{
                discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    func peripheralAlreadyRegistered(peripheral: CBPeripheral) -> Bool{
        return discoveredPeripherals.contains(peripheral)
    }
    
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        self.isConnected = true
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
        print("WARNING: Connection failed")
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else {
            return
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func resetReferences(){
        self.connectedPeripheral = nil
        self.discoveredPeripherals = []
        self.isConnected = false
        self.valueReceived = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        resetReferences()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil else {
            return
        }
        
        discoverCharacteristics(peripheral: peripheral)
    }
    
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                self.connectedPeripheral?.readValue(for: characteristic)
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {

            if let stringValue = String(data: value, encoding: .utf8) {
                valueReceived = stringValue
            }
        }
    }
    
}
