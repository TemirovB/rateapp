
//
//  miBand2.swift
//  Rate
//
//  Created by Bakhtiar Temirov on 4/6/19.
//  Copyright © 2019 Bakhtiar Temirov. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class miBand2: NSObject {
    
    let peripheral: CBPeripheral
    
    init(_ peripheral: CBPeripheral){
        self.peripheral = peripheral
    }
    
    func startVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_VIBRATE_ONLY)
    }
    
    func stopVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_NONE)
    }
    
    func vibrationAction(_ alert: [Int8]){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_ALERT}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_VIBRATION_CONTROL}){
            var vibrationType = alert
            let data = NSData(bytes: &vibrationType, length: vibrationType.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func measureHeartRate(){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_HEART_RATE}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_CONTROL}){
            let data = NSData(bytes: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT, length: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
    }
    
    func getHeartRate(heartRateData:Data) -> Int{
        print("--- UPDATING Heart Rate..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            return Int(actualBpm)
        }else {
            return Int(bpm!)
        }
    }

}
