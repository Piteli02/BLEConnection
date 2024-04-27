//
//  ContentView.swift
//  BLEConnection
//
//  Created by Caio Gomes Piteli on 24/03/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothController = BluetoothController()
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                //MARK: - Disconnect or Connect title
                VStack{
                    HStack{
                        Spacer()
                        if bluetoothController.isConnected{
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                                .font(.largeTitle)
                            
                            Text("Connected")
                                .font(.largeTitle)
                        }else{
                            Image(systemName: "x.circle")
                                .foregroundColor(.red)
                                .font(.largeTitle)
                            
                            Text("Disconnected")
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        if !bluetoothController.isConnected{
                            Text("Tap on the device name to connect")
                                .font(.body)
                        }
                        Spacer()
                    }
                }
                
                //MARK: - Bluetooth status label
                HStack{
                    Text("Bluetooth status:")
                        .font(.headline)
                        .padding(.leading)
                    
                    Text("\(bluetoothController.bluetoothStatus.rawValue)")
                        .font(.body)
                    
                    Spacer()
                    
                }.padding(.top)
                
                //MARK: - List with bluetooth devices found
                    //This list is only shown if the bluetooth isn't connect
                if !bluetoothController.isConnected{
                    List(bluetoothController.discoveredPeripherals, id: \.self) { peripheral in
                        Button(action: {
                            bluetoothController.connect(peripheral: peripheral)
                        }) {
                            ZStack{
                                //Created rectangle so that if tapped on anywere of the element on the list, the action will happen
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: geometry.size.width)
                                
                                HStack{
                                    Text(peripheral.name ?? "Unknown name")
                                        .font(.body)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    //MARK: - Information of the connected device
                        //These informations are only shown if the device is connected
                }else{
                    VStack{
                        HStack{
                            Text("Connected on:")
                                .font(.headline)
                                .padding(.leading)
                                .padding(.vertical)
                            
                            Text("\(bluetoothController.connectedPeripheral?.name ?? "Unknown name")")
                                .font(.body)
                            
                            Spacer()
                        }
                        
                        HStack{
                            Text("Value received:")
                                .font(.headline)
                                .padding(.leading)
                            
                            Text("\(bluetoothController.valueReceived ?? "Nothing received yet")")
                                .font(.body)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            bluetoothController.disconnect()
                        }) {
                            Text("Disconnect")
                                .font(.body)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
