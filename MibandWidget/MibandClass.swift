//
//  MibandClass.swift
//  MibandWidgetExtension
//
//  Created by Abdullah Kardas on 1.10.2022.
//

import SwiftUI
import Combine
import CoreBluetooth

struct MibandDataModel:Codable{
    let deviceName:String
    let battery:String
    let batteryDiv:Int //0 --> 0 % - 25 %, 1 --> 25 % - 50 %...
    let steps:String
    let distance:String
    let calory:String
    
    static let exampleModel = MibandDataModel(deviceName: "MiBand", battery: "20 %", batteryDiv: 1, steps: "120", distance: "650 m", calory: "60 kcal")
}
class MibandClass:NSObject, ObservableObject,CBCentralManagerDelegate, CBPeripheralDelegate{
    static var instance = MibandClass()

 
    var cancallable = Set<AnyCancellable>()
    var centralManager:CBCentralManager!
    var miBand:MiBand2!
     var deviceName:String = ""
     var batteryStatus:String = "46"
    
     var steps:String = ""
     var distance:String = ""
     var calory:String = ""
     var heartRate:Int = 0
    
    fileprivate var locationPromise: ((Result<String, Error>) -> Void)?
    
    private typealias LocationCheckedThrowingContinuation = CheckedContinuation<MibandDataModel, Error>
    private var exampleContination: LocationCheckedThrowingContinuation?
    
    override init() {
        super.init()
 
    }
    
    func updateBattery() async throws -> MibandDataModel {
      return try await withCheckedThrowingContinuation({ [weak self] (continuation: LocationCheckedThrowingContinuation) in
        guard let self = self else {
          return
        }

          self.exampleContination = continuation

          self.centralManager = CBCentralManager()
          self.centralManager.delegate = self
      })
    }
    


   
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE])
            
            if lastPeripherals.count > 0{
                let device = lastPeripherals.first! as CBPeripheral;
                miBand = MiBand2(device);
                centralManager.connect(miBand.peripheral, options: nil)
            }
            else {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            
            
            
        default:
            print(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "MI Band 2"){
            miBand = MiBand2(peripheral)
            print("try to connect to \(String(describing: peripheral.name))")
            centralManager.connect(miBand.peripheral, options: nil)
        }else{
            print("discovered: \(String(describing: peripheral.name))")
        }
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        miBand.peripheral.delegate = self
        miBand.peripheral.discoverServices(nil)
        
        deviceName = miBand.peripheral.name ?? ""
    
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]?
        {
            for servicePeripheral in servicePeripherals
            {
                peripheral.discoverCharacteristics(nil, for: servicePeripheral)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Error: \(error.debugDescription)")
        if let charactericsArr = service.characteristics  as [CBCharacteristic]?{
            for cc in charactericsArr{
                switch cc.uuid.uuidString{
                case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                    peripheral.readValue(for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                    peripheral.setNotifyValue(true, for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS.uuidString:
                    if let (step, distnc, calories) = miBand.getSteps(){
                        steps = step.description
                        distance = "\(distnc.description) m"
                        calory = "\(calories.description) kcal"
                       // exampleContination2?.resume(returning: distance)
                        //exampleContination2 = nil
                       
                    }
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
        case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
            batteryStatus = "\(miBand.getBattery(batteryData: characteristic.value!)) %"
            if let (step, distnc, calories) = miBand.getSteps(){
                steps = step.description
                distance = "\(distnc.description) m"
                calory = "\(calories.description) kcal"
                var batteryDiv = 1
                if miBand.getBattery(batteryData: characteristic.value!) <= 25 {
                    batteryDiv = 0
                } else if miBand.getBattery(batteryData: characteristic.value!) <= 50 {
                    batteryDiv = 1
                }else if miBand.getBattery(batteryData: characteristic.value!) <= 75 {
                    batteryDiv = 2
                }else if miBand.getBattery(batteryData: characteristic.value!) <= 100 {
                    batteryDiv = 3
                }
                exampleContination?.resume(returning: MibandDataModel(deviceName: miBand.peripheral.name ?? "", battery: batteryStatus, batteryDiv: batteryDiv, steps: steps, distance: distance, calory: calory))
                exampleContination = nil
               
            }
            
            
            

        case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
            //stop heart anim
            miBand.startVibrate()
            heartRate = miBand.getHeartRate(heartRateData: characteristic.value!)
        default:
            print(characteristic.uuid.uuidString)
        }
    }
    
    
    func getHeartRate(){
        print(miBand.peripheral.state)
    
        miBand.measureHeartRate()//startAnimation
    }


}

