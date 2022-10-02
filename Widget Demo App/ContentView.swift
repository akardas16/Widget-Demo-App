//
//  ContentView.swift
//  Widget Demo App
//
//  Created by Abdullah Kardas on 17.09.2022.
//

import SwiftUI
import Combine
import CoreBluetooth
import LocationWhenInUsePermission
import PermissionsKit


class ObservesData:NSObject, ObservableObject,CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var cancallable = Set<AnyCancellable>()
    var centralManager:CBCentralManager!
    var miBand:MiBand2!
  
    @Published var deviceName:String = ""
    @Published var batteryStatus:String = ""
    @Published var steps:String = ""
    @Published var distance:String = ""
    @Published var calory:String = ""
    @Published var heartRate:Int = 0
    
    override init() {
        super.init()
        Permission.locationWhenInUse.request {
            
        }
        centralManager = CBCentralManager()
        centralManager.delegate = self
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
                    self.updateSteps()
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
        case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
            //stop heart anim
            miBand.startVibrate()
            heartRate = miBand.getHeartRate(heartRateData: characteristic.value!)
        default:
            print(characteristic.uuid.uuidString)
        }
    }
    
    // MARK: methods
    
    func updateSteps(){
        
        if let (step, distnc, calories) = miBand.getSteps(){
            steps = step.description
            distance = "\(distnc.description) m"
            calory = "\(calories.description) kcal"
           
        }
    }
    
   
    
  

    
    func getHeartRate(){
        print(miBand.peripheral.state)
    
        miBand.measureHeartRate()//startAnimation
    }


}

struct ContentView: View {
    @State var txt = ""
    @StateObject var vm = ObservesData()
    var cancallable = Set<AnyCancellable>()
    var body: some View {
        VStack {
            
            Text(vm.deviceName)
            Text(vm.batteryStatus)
            Text(vm.steps)
            Text(vm.distance)
            Text(vm.calory)
            Text("\(vm.heartRate)")
            
            Button("Get heart rate"){
                vm.getHeartRate()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
