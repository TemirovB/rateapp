//
//  ViewController.swift
//  Rate
//
//  Created by Bakhtiar Temirov on 1/22/19.
//  Copyright © 2019 Bakhtiar Temirov. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    @IBOutlet weak var heartRateLabel: UILabel!
    
    var miBand:miBand2!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charactericsArr = service.characteristics  as [CBCharacteristic]?{
            for cc in charactericsArr{
                switch cc.uuid.uuidString{
                case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                    peripheral.setNotifyValue(true, for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_3_CONFIGURATION.uuidString:
                    // set time format: var rawArray:[UInt8] = [0x06,0x02, 0x00, 0x01]
                    var rawArray:[UInt8] = [0x0a,0x20, 0x00, 0x00]
                    let data = NSData(bytes: &rawArray, length: rawArray.count)
                    peripheral.writeValue(data as Data, for: cc, type: .withoutResponse)
                default:
                    print("Service: "+service.uuid.uuidString+" Characteristic: "+cc.uuid.uuidString)
                    break
                }
            }
            
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString{
        case "FF06":
            var u16:Int
            if (characteristic.value != nil){
                u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int.self, capacity: characteristic.value!.count).pointee
            }else{
                u16 = 0
            }
            print("\(u16) steps")
        case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
            updateHeartRate(miBand.getHeartRate(heartRateData: characteristic.value!))
        default:
            print(characteristic.uuid.uuidString)
        }
    }
    func updateHeartRate(_ heartRate:Int){
        miBand.startVibrate()
        heartRateLabel.text = heartRate.description
    }
    
    @objc func swipeAction(swipe:UISwipeGestureRecognizer){
        miBand.measureHeartRate()
    }


}

